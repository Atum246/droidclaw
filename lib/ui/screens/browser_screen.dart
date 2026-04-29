import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/droid_theme.dart';
import '../../core/browser/browser_engine.dart';

/// 🌐 Browser Viewer — Shows live WebView when browser automation is active
class BrowserViewer extends StatefulWidget {
  const BrowserViewer({super.key});
  @override
  State<BrowserViewer> createState() => _BrowserViewerState();
}

class _BrowserViewerState extends State<BrowserViewer> {
  final _urlCtrl = TextEditingController();
  bool _showConsole = false;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    // Listen to browser events
    BrowserEngine.I.events.listen((event) {
      if (mounted) {
        setState(() {
          _logs.add('[${event.type}] ${event.data}');
          if (_logs.length > 50) _logs.removeAt(0);
        });
      }
    });
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BrowserEngine>(builder: (_, browser, __) {
      if (!browser.isOpen) return _emptyState();
      return Column(children: [
        _toolbar(browser),
        Expanded(child: Stack(children: [
          WebViewWidget(controller: browser.controller),
          if (_showConsole) _consoleOverlay(),
        ])),
      ]);
    });
  }

  Widget _emptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 64, height: 64,
        decoration: BoxDecoration(color: DroidTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('🌍', style: TextStyle(fontSize: 32)))),
      const SizedBox(height: 16),
      Text('Browser Ready', style: TextStyle(color: DroidTheme.txt, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text('Ask me to open any website!\n"Open google.com" or "Search for Flutter"',
        textAlign: TextAlign.center,
        style: TextStyle(color: DroidTheme.txt3, fontSize: 13, height: 1.5)),
      const SizedBox(height: 20),
      // Quick URLs
      Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
        _quickUrl('🔍', 'Google', 'https://google.com'),
        _quickUrl('📰', 'GitHub', 'https://github.com'),
        _quickUrl('🎥', 'YouTube', 'https://youtube.com'),
        _quickUrl('📚', 'Wikipedia', 'https://wikipedia.org'),
      ]),
    ])).animate().fadeIn();
  }

  Widget _quickUrl(String emoji, String label, String url) {
    return GestureDetector(
      onTap: () => BrowserEngine.I.open(url),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: DroidTheme.surface, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DroidTheme.border, width: 0.5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: DroidTheme.txt, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _toolbar(BrowserEngine browser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: DroidTheme.surface,
        border: Border(bottom: BorderSide(color: DroidTheme.border.withOpacity(0.3), width: 0.5))),
      child: Column(children: [
        Row(children: [
          // Back/Forward/Reload
          _toolBtn('⬅️', () => browser.goBack()),
          _toolBtn('➡️', () => browser.goForward()),
          _toolBtn('🔄', () => browser.reload()),
          const SizedBox(width: 6),
          // URL bar
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: DroidTheme.bg, borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DroidTheme.border, width: 0.5)),
            child: Row(children: [
              Text('🔒', style: TextStyle(fontSize: 10, color: browser.currentUrl.startsWith('https') ? DroidTheme.green : DroidTheme.txt3)),
              const SizedBox(width: 5),
              Expanded(child: Text(
                browser.currentUrl.length > 50 ? '${browser.currentUrl.substring(0, 50)}...' : browser.currentUrl,
                style: TextStyle(color: DroidTheme.txt, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              )),
            ]),
          )),
          const SizedBox(width: 6),
          // Console toggle
          _toolBtn('📋', () => setState(() => _showConsole = !_showConsole)),
          // Close
          _toolBtn('❌', () => browser.close()),
        ]),
        // Page title
        if (browser.currentTitle.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 4),
            child: Text(browser.currentTitle, style: TextStyle(color: DroidTheme.txt2, fontSize: 10),
              overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _toolBtn(String emoji, VoidCallback onTap) {
    return GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: DroidTheme.bg, borderRadius: BorderRadius.circular(6)),
        child: Text(emoji, style: const TextStyle(fontSize: 14))));
  }

  Widget _consoleOverlay() {
    return Positioned(bottom: 0, left: 0, right: 0,
      child: Container(
        height: 150,
        decoration: BoxDecoration(color: DroidTheme.bg.withOpacity(0.95),
          border: Border(top: BorderSide(color: DroidTheme.accent.withOpacity(0.3), width: 1))),
        child: Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(children: [
              Text('📋 Console', style: TextStyle(color: DroidTheme.accent, fontSize: 10, fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(onTap: () => setState(() => _logs.clear()),
                child: Text('Clear', style: TextStyle(color: DroidTheme.txt3, fontSize: 10))),
              const SizedBox(width: 8),
              GestureDetector(onTap: () => setState(() => _showConsole = false),
                child: Text('✕', style: TextStyle(color: DroidTheme.txt3, fontSize: 12))),
            ])),
          Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _logs.length,
            itemBuilder: (_, i) => Text(_logs[i], style: TextStyle(color: DroidTheme.txt2, fontSize: 9, fontFamily: 'monospace')),
          )),
        ]),
      ),
    );
  }
}
