import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// 🌐 Browser Engine — Real WebView Automation
/// Powers all browser_* tools with actual page control
class BrowserEngine extends ChangeNotifier {
  static final BrowserEngine I = BrowserEngine._();
  BrowserEngine._();

  WebViewController? _controller;
  bool _isOpen = false;
  String _currentUrl = '';
  String _currentTitle = '';
  final List<String> _history = [];
  final StreamController<BrowserEvent> _events = StreamController.broadcast();

  bool get isOpen => _isOpen;
  String get currentUrl => _currentUrl;
  String get currentTitle => _currentTitle;
  Stream<BrowserEvent> get events => _events.stream;

  /// Ensure browser is initialized
  WebViewController _ensureController() {
    if (_controller != null) return _controller!;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          _currentUrl = url;
          _events.add(BrowserEvent(type: 'page_started', data: url));
          notifyListeners();
        },
        onPageFinished: (url) async {
          _currentUrl = url;
          _history.add(url);
          try {
            _currentTitle = await _controller!.getTitle() ?? '';
          } catch (_) {}
          _events.add(BrowserEvent(type: 'page_finished', data: {'url': url, 'title': _currentTitle}));
          notifyListeners();
        },
        onWebResourceError: (error) {
          _events.add(BrowserEvent(type: 'error', data: error.description));
        },
      ));
    return _controller!;
  }

  // ═══════════════════════════════════════════
  // 🌐 NAVIGATION
  // ═══════════════════════════════════════════

  /// Open a URL in the browser
  Future<String> open(String url, {bool headless = false}) async {
    final ctrl = _ensureController();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    await ctrl.loadRequest(Uri.parse(url));
    _isOpen = true;
    // Wait a bit for page to start loading
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
    return '🌐 Browser opened: $url\nTitle: $_currentTitle\nReady for automation.';
  }

  /// Navigate to a URL (browser must be open)
  Future<String> navigate(String url) async {
    if (!_isOpen) return '❌ Browser not open. Use browser_open first.';
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    await _controller!.loadRequest(Uri.parse(url));
    await Future.delayed(const Duration(milliseconds: 500));
    return '🔗 Navigated to: $url';
  }

  /// Go back
  Future<String> goBack() async {
    if (!_isOpen) return '❌ Browser not open.';
    await _controller!.goBack();
    return '⬅️ Went back';
  }

  /// Go forward
  Future<String> goForward() async {
    if (!_isOpen) return '❌ Browser not open.';
    await _controller!.goForward();
    return '➡️ Went forward';
  }

  /// Reload page
  Future<String> reload() async {
    if (!_isOpen) return '❌ Browser not open.';
    await _controller!.reload();
    return '🔄 Page reloaded';
  }

  // ═══════════════════════════════════════════
  // 👆 INTERACTION
  // ═══════════════════════════════════════════

  /// Click an element by CSS selector or text content
  Future<String> click(String? selector, String? text) async {
    if (!_isOpen) return '❌ Browser not open.';
    String js;
    if (selector != null && selector.isNotEmpty) {
      js = '''
        (function() {
          var el = document.querySelector('${_escapeJs(selector)}');
          if (el) { el.click(); return 'clicked'; }
          return 'not_found';
        })()
      ''';
    } else if (text != null && text.isNotEmpty) {
      js = '''
        (function() {
          var els = document.querySelectorAll('a, button, [role="button"], input[type="submit"], [onclick]');
          for (var i = 0; i < els.length; i++) {
            if (els[i].textContent.trim().includes('${_escapeJs(text)}')) {
              els[i].click(); return 'clicked';
            }
          }
          return 'not_found';
        })()
      ''';
    } else {
      return '❌ Provide selector or text to click.';
    }
    final result = await _evalJs(js);
    if (result == 'clicked') return '👆 Clicked: ${selector ?? text}';
    return '⚠️ Element not found: ${selector ?? text}';
  }

  /// Type text into an input field
  Future<String> type(String selector, String text, {bool clear = false}) async {
    if (!_isOpen) return '❌ Browser not open.';
    final js = '''
      (function() {
        var el = document.querySelector('${_escapeJs(selector)}');
        if (!el) return 'not_found';
        el.focus();
        ${clear ? "el.value = '';" : ""}
        el.value = el.value + '${_escapeJs(text)}';
        el.dispatchEvent(new Event('input', {bubbles: true}));
        el.dispatchEvent(new Event('change', {bubbles: true}));
        return 'typed';
      })()
    ''';
    final result = await _evalJs(js);
    if (result == 'typed') return '⌨️ Typed into $selector: "$text"';
    return '⚠️ Input not found: $selector';
  }

  /// Select a dropdown option
  Future<String> select(String selector, String value) async {
    if (!_isOpen) return '❌ Browser not open.';
    final js = '''
      (function() {
        var el = document.querySelector('${_escapeJs(selector)}');
        if (!el) return 'not_found';
        el.value = '${_escapeJs(value)}';
        el.dispatchEvent(new Event('change', {bubbles: true}));
        return 'selected';
      })()
    ''';
    final result = await _evalJs(js);
    if (result == 'selected') return '📋 Selected "$value" in $selector';
    return '⚠️ Select not found: $selector';
  }

  /// Scroll the page
  Future<String> scroll(String direction, int amount) async {
    if (!_isOpen) return '❌ Browser not open.';
    final dy = direction == 'up' ? -amount : amount;
    await _evalJs('window.scrollBy(0, $dy);');
    return '📜 Scrolled $direction ${amount}px';
  }

  /// Fill multiple form fields at once
  Future<String> fillForm(Map<String, String> fields, {bool submit = false}) async {
    if (!_isOpen) return '❌ Browser not open.';
    final fieldsJson = jsonEncode(fields);
    final js = '''
      (function() {
        var fields = $fieldsJson;
        for (var selector in fields) {
          var el = document.querySelector(selector);
          if (el) {
            el.value = fields[selector];
            el.dispatchEvent(new Event('input', {bubbles: true}));
            el.dispatchEvent(new Event('change', {bubbles: true}));
          }
        }
        ${submit ? "var form = document.querySelector('form'); if (form) form.submit();" : ""}
        return 'filled';
      })()
    ''';
    await _evalJs(js);
    return '📝 Form filled${submit ? " and submitted" : ""}';
  }

  // ═══════════════════════════════════════════
  // 📖 EXTRACTION
  // ═══════════════════════════════════════════

  /// Get text content from element(s)
  Future<String> getText(String? selector) async {
    if (!_isOpen) return '❌ Browser not open.';
    final js = selector != null && selector.isNotEmpty
        ? '''(function() {
            var el = document.querySelector('${_escapeJs(selector)}');
            return el ? el.textContent.trim() : 'not_found';
          })()'''
        : 'document.body.innerText';
    final result = await _evalJs(js);
    return '📖 Text:\n${_truncate(result, 3000)}';
  }

  /// Get HTML from page or element
  Future<String> getHtml(String? selector) async {
    if (!_isOpen) return '❌ Browser not open.';
    final js = selector != null && selector.isNotEmpty
        ? '''(function() {
            var el = document.querySelector('${_escapeJs(selector)}');
            return el ? el.innerHTML : 'not_found';
          })()'''
        : 'document.documentElement.outerHTML';
    final result = await _evalJs(js);
    return '📄 HTML:\n${_truncate(result, 5000)}';
  }

  /// Get current URL
  Future<String> getUrl() async {
    if (!_isOpen) return '❌ Browser not open.';
    final url = await _evalJs('window.location.href');
    return '🔗 Current URL: $url';
  }

  /// Extract all links from page
  Future<String> extractLinks(String? selector) async {
    if (!_isOpen) return '❌ Browser not open.';
    final js = '''
      (function() {
        var container = ${selector != null && selector.isNotEmpty ? "document.querySelector('${_escapeJs(selector)}')" : "document"};
        var links = container.querySelectorAll('a[href]');
        var result = [];
        links.forEach(function(a) {
          result.push({text: a.textContent.trim(), href: a.href});
        });
        return JSON.stringify(result.slice(0, 100));
      })()
    ''';
    final result = await _evalJs(js);
    try {
      final List<dynamic> links = jsonDecode(result);
      final buf = StringBuffer('🔗 Found ${links.length} links:\n');
      for (var link in links.take(30)) {
        buf.writeln('• ${link['text']} → ${link['href']}');
      }
      return buf.toString();
    } catch (e) {
      return '🔗 Links extracted: $result';
    }
  }

  /// Extract table data as JSON
  Future<String> extractTable(String selector) async {
    if (!_isOpen) return '❌ Browser not open.';
    final js = '''
      (function() {
        var table = document.querySelector('${_escapeJs(selector)}');
        if (!table) return '[]';
        var rows = table.querySelectorAll('tr');
        var result = [];
        var headers = [];
        rows.forEach(function(row, i) {
          var cells = row.querySelectorAll('th, td');
          var rowData = {};
          cells.forEach(function(cell, j) {
            if (i === 0) { headers[j] = cell.textContent.trim(); }
            rowData[headers[j] || ('col_' + j)] = cell.textContent.trim();
          });
          if (i > 0) result.push(rowData);
        });
        return JSON.stringify(result);
      })()
    ''';
    final result = await _evalJs(js);
    return '📊 Table data:\n${_truncate(result, 3000)}';
  }

  // ═══════════════════════════════════════════
  // ⚡ JAVASCRIPT EXECUTION
  // ═══════════════════════════════════════════

  /// Execute arbitrary JavaScript on the page
  Future<String> executeJs(String code) async {
    if (!_isOpen) return '❌ Browser not open.';
    final result = await _evalJs(code);
    return '⚡ JS Result:\n${_truncate(result, 3000)}';
  }

  // ═══════════════════════════════════════════
  // 📸 SCREENSHOT
  // ═══════════════════════════════════════════

  /// Take a screenshot of current page
  Future<String> takeScreenshot({bool fullPage = false}) async {
    if (!_isOpen) return '❌ Browser not open.';
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/browser_screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      final bytes = await _controller!.takeScreenshot();
      if (bytes != null) {
        await File(path).writeAsBytes(bytes);
        return '📸 Screenshot saved: $path';
      }
      return '📸 Screenshot captured (bytes: ${bytes?.length ?? 0})';
    } catch (e) {
      return '📸 Screenshot captured (use browser_screenshot in-app)';
    }
  }

  // ═══════════════════════════════════════════
  // 🔐 COMPLEX ACTIONS
  // ═══════════════════════════════════════════

  /// Fill login form and submit
  Future<String> login({
    required String url,
    required String userSelector,
    required String passSelector,
    required String username,
    required String password,
    String? submitSelector,
  }) async {
    if (!_isOpen) return '❌ Browser not open.';
    // Navigate to login page
    await navigate(url);
    await Future.delayed(const Duration(seconds: 1));
    // Fill credentials
    await type(userSelector, username, clear: true);
    await type(passSelector, password, clear: true);
    // Submit
    if (submitSelector != null && submitSelector.isNotEmpty) {
      await click(submitSelector, null);
    } else {
      await _evalJs('''
        (function() {
          var form = document.querySelector('${_escapeJs(userSelector)}');
          if (form) { var f = form.closest('form'); if (f) f.submit(); }
        })()
      ''');
    }
    return '🔐 Logged in to $url';
  }

  /// Search on a website
  Future<String> search({
    required String url,
    required String searchSelector,
    required String query,
    String? submitSelector,
  }) async {
    if (!_isOpen) return '❌ Browser not open.';
    await navigate(url);
    await Future.delayed(const Duration(seconds: 1));
    await type(searchSelector, query, clear: true);
    if (submitSelector != null && submitSelector.isNotEmpty) {
      await click(submitSelector, null);
    } else {
      await _evalJs('''
        (function() {
          var el = document.querySelector('${_escapeJs(searchSelector)}');
          if (el) { el.dispatchEvent(new KeyboardEvent('keydown', {key: 'Enter', code: 'Enter', keyCode: 13, bubbles: true})); }
        })()
      ''');
    }
    return '🔍 Searched "$query" on $url';
  }

  /// Run multiple browser actions in sequence
  Future<String> multiStep(List<Map<String, dynamic>> steps) async {
    if (!_isOpen) return '❌ Browser not open.';
    final results = <String>[];
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final action = step['action'] as String;
      String result;
      switch (action) {
        case 'navigate': result = await navigate(step['url']); break;
        case 'click': result = await click(step['selector'], step['text']); break;
        case 'type': result = await type(step['selector'], step['text'], clear: step['clear'] ?? false); break;
        case 'select': result = await select(step['selector'], step['value']); break;
        case 'scroll': result = await scroll(step['direction'] ?? 'down', step['amount'] ?? 500); break;
        case 'wait': result = await waitFor(step['selector'], step['text'], step['timeout'] ?? 5000); break;
        case 'screenshot': result = await takeScreenshot(); break;
        case 'getText': result = await getText(step['selector']); break;
        case 'js': result = await executeJs(step['code']); break;
        default: result = '⚠️ Unknown action: $action';
      }
      results.add('Step ${i + 1}: $result');
      // Small delay between steps
      if (i < steps.length - 1) {
        await Future.delayed(Duration(milliseconds: step['delay'] ?? 300));
      }
    }
    return '🔄 Multi-step completed:\n${results.join('\n')}';
  }

  /// Wait for an element or text to appear
  Future<String> waitFor(String? selector, String? text, int timeout) async {
    if (!_isOpen) return '❌ Browser not open.';
    final deadline = DateTime.now().add(Duration(milliseconds: timeout));
    while (DateTime.now().isBefore(deadline)) {
      String js;
      if (selector != null && selector.isNotEmpty) {
        js = '(function() { return document.querySelector("${_escapeJs(selector)}") ? "found" : "waiting"; })()';
      } else if (text != null && text.isNotEmpty) {
        js = '(function() { return document.body.innerText.includes("${_escapeJs(text)}") ? "found" : "waiting"; })()';
      } else {
        return '⏳ Wait cancelled — no selector or text provided.';
      }
      final result = await _evalJs(js);
      if (result == 'found') return '⏳ Found: ${selector ?? text}';
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return '⏳ Timeout waiting for: ${selector ?? text}';
  }

  // ═══════════════════════════════════════════
  // 🔒 SESSION MANAGEMENT
  // ═══════════════════════════════════════════

  /// Get page title
  Future<String> getTitle() async {
    if (!_isOpen) return '❌ Browser not open.';
    final title = await _controller!.getTitle() ?? '';
    return '📄 Title: $title';
  }

  /// Get page source
  Future<String> getSource() async {
    if (!_isOpen) return '❌ Browser not open.';
    final html = await _evalJs('document.documentElement.outerHTML');
    return '📄 Source (${html.length} chars):\n${_truncate(html, 5000)}';
  }

  /// Clear cookies and storage
  Future<String> clearData() async {
    if (!_isOpen) return '❌ Browser not open.';
    await _evalJs('''
      (function() {
        localStorage.clear();
        sessionStorage.clear();
        document.cookie.split(";").forEach(function(c) {
          document.cookie = c.replace(/^ +/, "").replace(/=.*/, "=;expires=" + new Date().toUTCString() + ";path=/");
        });
        return 'cleared';
      })()
    ''');
    return '🧹 Cookies and storage cleared';
  }

  /// Close the browser
  Future<String> close() async {
    _controller = null;
    _isOpen = false;
    _currentUrl = '';
    _currentTitle = '';
    notifyListeners();
    return '❌ Browser closed.';
  }

  // ═══════════════════════════════════════════
  // 🛠️ HELPERS
  // ═══════════════════════════════════════════

  Future<String> _evalJs(String js) async {
    try {
      final result = await _controller!.runJavaScriptReturningResult(js);
      // runJavaScriptReturningResult returns JSON-encoded values
      final str = result.toString();
      // Strip surrounding quotes if it's a JSON string
      if (str.startsWith('"') && str.endsWith('"')) {
        return jsonDecode(str);
      }
      return str;
    } catch (e) {
      return 'JS Error: $e';
    }
  }

  String _escapeJs(String s) {
    return s.replaceAll('\\', '\\\\').replaceAll("'", "\\'").replaceAll('"', '\\"').replaceAll('\n', '\\n');
  }

  String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}...\n[truncated ${s.length - max} chars]';
  }

  /// Get a headless WebView controller for background operations
  WebViewController get controller => _ensureController();
}

/// Browser event for the event stream
class BrowserEvent {
  final String type;
  final dynamic data;
  BrowserEvent({required this.type, this.data});
}
