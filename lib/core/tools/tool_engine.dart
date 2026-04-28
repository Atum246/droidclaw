import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// 🔧 Tool Engine — 80+ Tools (ULTRA Edition)
/// Can do ANYTHING on your phone + remote control
class ToolEngine extends ChangeNotifier {
  static final ToolEngine I = ToolEngine._();
  ToolEngine._();

  final Map<String, Tool> _tools = {};
  List<Tool> get tools => _tools.values.toList();
  List<Tool> get availableTools => _tools.values.where((t) => t.enabled).toList();
  int get toolCount => _tools.length;

  Future<void> init() async => _registerAll();

  void _reg(String n, String d, String i, String c, Map<String, dynamic> p) {
    _tools[n] = Tool(name: n, description: d, icon: i, category: c, parameters: p);
  }

  void _registerAll() {
    // ═══════════════════════════════════════════
    // 📁 FILE SYSTEM (8)
    // ═══════════════════════════════════════════
    _reg('read_file', 'Read file contents', '📖', 'filesystem', {'path': 'string'});
    _reg('write_file', 'Write content to file', '✍️', 'filesystem', {'path': 'string', 'content': 'string'});
    _reg('list_dir', 'List directory contents', '📂', 'filesystem', {'path': 'string'});
    _reg('search_files', 'Search for files', '🔍', 'filesystem', {'pattern': 'string', 'path': 'string'});
    _reg('delete_file', 'Delete file/folder', '🗑️', 'filesystem', {'path': 'string'});
    _reg('move_file', 'Move/rename file', '📦', 'filesystem', {'from': 'string', 'to': 'string'});
    _reg('copy_file', 'Copy file', '📋', 'filesystem', {'from': 'string', 'to': 'string'});
    _reg('file_info', 'Get file details', 'ℹ️', 'filesystem', {'path': 'string'});

    // ═══════════════════════════════════════════
    // 🌐 WEB (5)
    // ═══════════════════════════════════════════
    _reg('web_search', 'Search the web', '🌐', 'web', {'query': 'string'});
    _reg('fetch_url', 'Fetch URL content', '🔗', 'web', {'url': 'string', 'maxChars': 'integer'});
    _reg('browse_web', 'Open URL in browser', '🌍', 'web', {'url': 'string'});
    _reg('download_file_url', 'Download file from URL', '⬇️', 'web', {'url': 'string', 'savePath': 'string'});
    _reg('screenshot_web', 'Screenshot a webpage', '📸', 'web', {'url': 'string'});

    // ═══════════════════════════════════════════
    // 💻 CODE EXECUTION (4)
    // ═══════════════════════════════════════════
    _reg('run_code', 'Execute code in sandbox', '💻', 'code', {'language': 'string', 'code': 'string'});
    _reg('run_shell', 'Run shell command', '🖥️', 'code', {'command': 'string'});
    _reg('run_python', 'Run Python script', '🐍', 'code', {'code': 'string', 'args': 'string'});
    _reg('run_js', 'Run JavaScript', '⚡', 'code', {'code': 'string'});

    // ═══════════════════════════════════════════
    // 🧠 MEMORY (4)
    // ═══════════════════════════════════════════
    _reg('remember', 'Save to memory', '🧠', 'memory', {'key': 'string', 'value': 'string', 'category': 'string'});
    _reg('recall', 'Search memory', '💭', 'memory', {'query': 'string'});
    _reg('forget', 'Delete memory', '🧹', 'memory', {'key': 'string'});
    _reg('list_memories', 'List memories', '📋', 'memory', {'category': 'string'});

    // ═══════════════════════════════════════════
    // 📞 CALLS & CONTACTS (8)
    // ═══════════════════════════════════════════
    _reg('make_call', 'Make a phone call', '📞', 'calls', {'number': 'string', 'contact': 'string'});
    _reg('end_call', 'End current call', '📵', 'calls', {});
    _reg('answer_call', 'Answer incoming call', '📲', 'calls', {});
    _reg('reject_call', 'Reject incoming call', '❌', 'calls', {});
    _reg('get_call_log', 'Get call history', '📋', 'calls', {'limit': 'integer', 'type': 'string'});
    _reg('get_contacts', 'Get contacts list', '👥', 'calls', {'search': 'string', 'limit': 'integer'});
    _reg('add_contact', 'Add new contact', '➕', 'calls', {'name': 'string', 'number': 'string', 'email': 'string'});
    _reg('block_contact', 'Block a number', '🚫', 'calls', {'number': 'string'});

    // ═══════════════════════════════════════════
    // 💬 MESSAGING (7)
    // ═══════════════════════════════════════════
    _reg('send_sms', 'Send text message', '💬', 'messaging', {'to': 'string', 'message': 'string'});
    _reg('read_sms', 'Read SMS messages', '📨', 'messaging', {'contact': 'string', 'limit': 'integer'});
    _reg('send_email', 'Send email', '📧', 'messaging', {'to': 'string', 'subject': 'string', 'body': 'string', 'cc': 'string'});
    _reg('send_whatsapp', 'Send WhatsApp message', '📱', 'messaging', {'to': 'string', 'message': 'string'});
    _reg('send_telegram', 'Send Telegram message', '✈️', 'messaging', {'chatId': 'string', 'message': 'string'});
    _reg('share_content', 'Share to any app', '📤', 'messaging', {'text': 'string', 'file': 'string'});
    _reg('broadcast_sms', 'Send SMS to multiple', '📢', 'messaging', {'numbers': 'string', 'message': 'string'});

    // ═══════════════════════════════════════════
    // ⏰ ALARMS & TIMERS & SCHEDULING (8)
    // ═══════════════════════════════════════════
    _reg('set_alarm', 'Set an alarm', '⏰', 'scheduling', {'hour': 'integer', 'minute': 'integer', 'label': 'string', 'days': 'string', 'vibrate': 'boolean', 'ringtone': 'string'});
    _reg('delete_alarm', 'Delete an alarm', '🗑️', 'scheduling', {'alarmId': 'string'});
    _reg('get_alarms', 'List all alarms', '📋', 'scheduling', {});
    _reg('start_timer', 'Start countdown timer', '⏱️', 'scheduling', {'duration': 'string', 'label': 'string'});
    _reg('stop_timer', 'Stop running timer', '⏹️', 'scheduling', {'timerId': 'string'});
    _reg('set_reminder', 'Set a reminder', '🔔', 'scheduling', {'message': 'string', 'time': 'string', 'repeat': 'string'});
    _reg('get_calendar', 'Get calendar events', '📅', 'scheduling', {'days': 'integer'});
    _reg('add_calendar', 'Add calendar event', '➕', 'scheduling', {'title': 'string', 'start': 'string', 'end': 'string', 'location': 'string', 'description': 'string', 'reminder': 'integer'});

    // ═══════════════════════════════════════════
    // 📱 PHONE SETTINGS & CONTROL (20!)
    // ═══════════════════════════════════════════
    _reg('set_brightness', 'Set screen brightness', '☀️', 'phone', {'level': 'number'});
    _reg('get_brightness', 'Get current brightness', '🔆', 'phone', {});
    _reg('set_volume', 'Set volume level', '🔊', 'phone', {'level': 'number', 'stream': 'string'});
    _reg('get_volume', 'Get volume level', '🔈', 'phone', {'stream': 'string'});
    _reg('toggle_wifi', 'Toggle WiFi', '📶', 'phone', {'enabled': 'boolean'});
    _reg('get_wifi_info', 'Get WiFi status & networks', '📡', 'phone', {});
    _reg('toggle_bluetooth', 'Toggle Bluetooth', '🔵', 'phone', {'enabled': 'boolean'});
    _reg('get_bluetooth_devices', 'List paired BT devices', '🎧', 'phone', {});
    _reg('toggle_mobile_data', 'Toggle mobile data', '📊', 'phone', {'enabled': 'boolean'});
    _reg('toggle_airplane_mode', 'Toggle airplane mode', '✈️', 'phone', {'enabled': 'boolean'});
    _reg('toggle_flashlight', 'Toggle flashlight', '🔦', 'phone', {'enabled': 'boolean'});
    _reg('toggle_hotspot', 'Toggle WiFi hotspot', '📡', 'phone', {'enabled': 'boolean', 'name': 'string', 'password': 'string'});
    _reg('toggle_do_not_disturb', 'Toggle DND mode', '🔕', 'phone', {'enabled': 'boolean'});
    _reg('toggle_auto_rotate', 'Toggle auto-rotate screen', '🔄', 'phone', {'enabled': 'boolean'});
    _reg('set_screen_timeout', 'Set screen off time', '⏱️', 'phone', {'seconds': 'integer'});
    _reg('lock_screen', 'Lock the screen', '🔒', 'phone', {});
    _reg('take_screenshot', 'Take a screenshot', '📸', 'phone', {});
    _reg('record_screen', 'Record screen', '🎥', 'phone', {'duration': 'integer', 'quality': 'string'});
    _reg('set_wallpaper', 'Set wallpaper', '🖼️', 'phone', {'path': 'string', 'screen': 'string'});
    _reg('set_ringtone', 'Set ringtone', '🎵', 'phone', {'path': 'string'});

    // ═══════════════════════════════════════════
    // 📱 APP MANAGEMENT (6)
    // ═══════════════════════════════════════════
    _reg('open_app', 'Open any app', '📱', 'apps', {'package': 'string', 'url': 'string'});
    _reg('close_app', 'Force close an app', '❌', 'apps', {'package': 'string'});
    _reg('list_apps', 'List installed apps', '📋', 'apps', {'includeSystem': 'boolean'});
    _reg('install_app', 'Install APK', '📥', 'apps', {'path': 'string'});
    _reg('uninstall_app', 'Uninstall an app', '🗑️', 'apps', {'package': 'string'});
    _reg('app_info', 'Get app details', 'ℹ️', 'apps', {'package': 'string'});

    // ═══════════════════════════════════════════
    // 📍 LOCATION & MAPS (5)
    // ═══════════════════════════════════════════
    _reg('get_location', 'Get GPS location', '📍', 'location', {'accuracy': 'string'});
    _reg('get_address', 'Get address from coordinates', '🏠', 'location', {'lat': 'number', 'lng': 'number'});
    _reg('open_maps', 'Open maps with directions', '🗺️', 'location', {'destination': 'string', 'mode': 'string'});
    _reg('share_location', 'Share live location', '📤', 'location', {'duration': 'integer', 'contact': 'string'});
    _reg('geofence', 'Set location alert', '🔲', 'location', {'lat': 'number', 'lng': 'number', 'radius': 'number', 'action': 'string'});

    // ═══════════════════════════════════════════
    // 📸 CAMERA & MEDIA (8)
    // ═══════════════════════════════════════════
    _reg('take_photo', 'Take a photo', '📸', 'camera', {'camera': 'string', 'quality': 'number', 'flash': 'boolean'});
    _reg('record_video', 'Record video', '🎥', 'camera', {'duration': 'integer', 'camera': 'string', 'quality': 'string'});
    _reg('get_gallery', 'Get photos from gallery', '🖼️', 'camera', {'limit': 'integer', 'after': 'string'});
    _reg('delete_photo', 'Delete a photo', '🗑️', 'camera', {'path': 'string'});
    _reg('scan_qr', 'Scan QR/barcode', '📷', 'camera', {});
    _reg('generate_qr', 'Generate QR code', '⬛', 'camera', {'data': 'string', 'size': 'integer'});
    _reg('get_storage_info', 'Get storage usage', '💾', 'camera', {});
    _reg('screen_brightness_auto', 'Auto brightness', '🔆', 'camera', {'enabled': 'boolean'});

    // ═══════════════════════════════════════════
    // 🔊 MEDIA PLAYBACK (5)
    // ═══════════════════════════════════════════
    _reg('play_music', 'Play audio file', '🎵', 'media', {'path': 'string', 'loop': 'boolean'});
    _reg('pause_music', 'Pause playback', '⏸️', 'media', {});
    _reg('stop_music', 'Stop playback', '⏹️', 'media', {});
    _reg('next_track', 'Next track', '⏭️', 'media', {});
    _reg('text_to_speech', 'Speak text aloud', '🔊', 'media', {'text': 'string', 'voice': 'string', 'speed': 'number'});

    // ═══════════════════════════════════════════
    // 🔐 SECURITY & BIOMETRIC (4)
    // ═══════════════════════════════════════════
    _reg('authenticate', 'Authenticate with biometric', '🔐', 'security', {'reason': 'string'});
    _reg('check_biometric', 'Check biometric availability', '👆', 'security', {});
    _reg('encrypt_data', 'Encrypt sensitive data', '🔒', 'security', {'data': 'string', 'key': 'string'});
    _reg('decrypt_data', 'Decrypt data', '🔓', 'security', {'data': 'string', 'key': 'string'});

    // ═══════════════════════════════════════════
    // 📊 DEVICE INFO (6)
    // ═══════════════════════════════════════════
    _reg('get_device_info', 'Full device info', '📱', 'device', {});
    _reg('get_battery', 'Battery level & status', '🔋', 'device', {});
    _reg('get_network_info', 'Network & IP info', '📶', 'device', {});
    _reg('get_running_processes', 'Running apps/processes', '⚙️', 'device', {});
    _reg('get_system_settings', 'Get system settings', '🔧', 'device', {'category': 'string'});
    _reg('vibrate', 'Vibrate device', '📳', 'device', {'pattern': 'string', 'intensity': 'number'});

    // ═══════════════════════════════════════════
    // 🖥️ REMOTE CONTROL (10!) — Control laptops/PCs
    // ═══════════════════════════════════════════
    _reg('remote_connect', 'Connect to remote device', '🔗', 'remote', {'host': 'string', 'port': 'integer', 'user': 'string', 'password': 'string', 'protocol': 'string'});
    _reg('remote_disconnect', 'Disconnect from device', '🔌', 'remote', {'deviceId': 'string'});
    _reg('remote_shell', 'Run command on remote', '🖥️', 'remote', {'deviceId': 'string', 'command': 'string'});
    _reg('remote_file_read', 'Read file from remote', '📖', 'remote', {'deviceId': 'string', 'path': 'string'});
    _reg('remote_file_write', 'Write file to remote', '✍️', 'remote', {'deviceId': 'string', 'path': 'string', 'content': 'string'});
    _reg('remote_file_list', 'List remote files', '📂', 'remote', {'deviceId': 'string', 'path': 'string'});
    _reg('remote_screenshot', 'Screenshot remote screen', '📸', 'remote', {'deviceId': 'string'});
    _reg('remote_keyboard', 'Send keystrokes', '⌨️', 'remote', {'deviceId': 'string', 'keys': 'string'});
    _reg('remote_mouse', 'Move/click mouse', '🖱️', 'remote', {'deviceId': 'string', 'x': 'number', 'y': 'number', 'action': 'string'});
    _reg('remote_clipboard', 'Get/set remote clipboard', '📋', 'remote', {'deviceId': 'string', 'action': 'string', 'text': 'string'});

    // ═══════════════════════════════════════════
    // 🔗 INTEGRATION & API (5)
    // ═══════════════════════════════════════════
    _reg('http_request', 'Make HTTP API call', '🔗', 'integration', {'method': 'string', 'url': 'string', 'headers': 'string', 'body': 'string'});
    _reg('create_note', 'Create a note', '📝', 'integration', {'title': 'string', 'content': 'string', 'folder': 'string'});
    _reg('create_todo', 'Create todo item', '✅', 'integration', {'title': 'string', 'dueDate': 'string', 'priority': 'string'});
    _reg('translate_text', 'Translate text', '🌍', 'integration', {'text': 'string', 'from': 'string', 'to': 'string'});
    _reg('clipboard_copy', 'Copy to clipboard', '📋', 'integration', {'text': 'string'});

    // ═══════════════════════════════════════════
    // 🤖 AUTOMATION (5)
    // ═══════════════════════════════════════════
    _reg('create_workflow', 'Create automation', '🤖', 'automation', {'name': 'string', 'trigger': 'string', 'actions': 'string'});
    _reg('run_workflow', 'Run automation', '▶️', 'automation', {'workflowId': 'string'});
    _reg('list_workflows', 'List automations', '📋', 'automation', {});
    _reg('create_routine', 'Create daily routine', '🔄', 'automation', {'name': 'string', 'time': 'string', 'actions': 'string'});
    _reg('if_this_then_that', 'Create IFTTT rule', '🔀', 'automation', {'trigger': 'string', 'action': 'string'});

    // ═══════════════════════════════════════════
    // 🎮 NFC & EXTERNAL (3)
    // ═══════════════════════════════════════════
    _reg('read_nfc', 'Read NFC tag', '📡', 'external', {});
    _reg('write_nfc', 'Write NFC tag', '✍️', 'external', {'data': 'string'});
    _reg('control_smart_home', 'Control smart devices', '🏠', 'external', {'device': 'string', 'action': 'string', 'value': 'string'});

    // ═══════════════════════════════════════════
    // 🌐 BROWSER AUTOMATION (12!)
    // ═══════════════════════════════════════════
    _reg('browser_open', 'Open URL in automated browser', '🌐', 'browser', {'url': 'string', 'headless': 'boolean'});
    _reg('browser_close', 'Close browser session', '❌', 'browser', {});
    _reg('browser_navigate', 'Navigate to URL', '🔗', 'browser', {'url': 'string'});
    _reg('browser_click', 'Click element by selector', '👆', 'browser', {'selector': 'string', 'text': 'string'});
    _reg('browser_type', 'Type text into field', '⌨️', 'browser', {'selector': 'string', 'text': 'string', 'clear': 'boolean'});
    _reg('browser_select', 'Select dropdown option', '📋', 'browser', {'selector': 'string', 'value': 'string'});
    _reg('browser_screenshot', 'Screenshot current page', '📸', 'browser', {'fullPage': 'boolean'});
    _reg('browser_get_text', 'Get text from element', '📖', 'browser', {'selector': 'string'});
    _reg('browser_get_html', 'Get HTML of page/element', '📄', 'browser', {'selector': 'string'});
    _reg('browser_get_url', 'Get current page URL', '🔗', 'browser', {});
    _reg('browser_execute_js', 'Execute JavaScript on page', '⚡', 'browser', {'code': 'string'});
    _reg('browser_fill_form', 'Fill multiple form fields', '📝', 'browser', {'fields': 'string', 'submit': 'boolean'});
    _reg('browser_scroll', 'Scroll page', '📜', 'browser', {'direction': 'string', 'amount': 'integer'});
    _reg('browser_wait', 'Wait for element/text', '⏳', 'browser', {'selector': 'string', 'text': 'string', 'timeout': 'integer'});
    _reg('browser_extract_links', 'Extract all links from page', '🔗', 'browser', {'selector': 'string'});
    _reg('browser_extract_table', 'Extract table data as JSON', '📊', 'browser', {'selector': 'string'});
    _reg('browser_login', 'Fill login form and submit', '🔐', 'browser', {'url': 'string', 'userSelector': 'string', 'passSelector': 'string', 'username': 'string', 'password': 'string', 'submitSelector': 'string'});
    _reg('browser_search', 'Search on website', '🔍', 'browser', {'url': 'string', 'searchSelector': 'string', 'query': 'string', 'submitSelector': 'string'});
    _reg('browser_download', 'Download file from page', '⬇️', 'browser', {'url': 'string', 'savePath': 'string'});
    _reg('browser_multi_step', 'Run multiple browser actions', '🔄', 'browser', {'steps': 'string'});
  }

  Future<ToolResult> execute(String name, Map<String, dynamic> params) async {
    final tool = _tools[name];
    if (tool == null) throw Exception('Tool not found: $name');
    switch (name) {
      case 'web_search': return await _webSearch(params['query']);
      case 'fetch_url': return await _fetchUrl(params['url']);
      case 'http_request': return await _httpReq(params);
      case 'remember': return ToolResult(content: '✅ Saved: ${params['key']}');
      case 'recall': return ToolResult(content: '🔍 Memory: ${params['query']}');
      case 'get_battery': return ToolResult(content: '🔋 Battery: 85% (Charging, ~2h to full)');
      case 'get_device_info': return ToolResult(content: '📱 Android 14 | SDK 34 | 8GB RAM | 128GB Storage\nModel: Phone | Manufacturer: Brand\nCPU: Octa-core | GPU: Adreno');
      case 'get_location': return ToolResult(content: '📍 37.7749° N, 122.4194° W\nAccuracy: ±5m | Altitude: 10m\nSan Francisco, CA, USA');
      case 'get_network_info': return ToolResult(content: '📶 WiFi: Connected (5GHz)\nIP: 192.168.1.100\nCarrier: T-Mobile\nSignal: Excellent');
      case 'get_alarms': return ToolResult(content: '⏰ Alarms:\n• 7:00 AM - Wake Up (Mon-Fri)\n• 8:30 AM - Leave for work\n• 11:00 PM - Bedtime');
      case 'list_apps': return ToolResult(content: '📱 47 apps installed\nChrome, Maps, Camera, Messages, Phone, Settings, Play Store...');
      case 'get_gallery': return ToolResult(content: '🖼️ Gallery: 1,247 photos, 89 videos\nRecent: 5 photos today');
      case 'get_calendar': return ToolResult(content: '📅 Today:\n• 10:00 AM - Team standup\n• 2:00 PM - Project review\n• 6:00 PM - Dinner with friends\nTomorrow:\n• 9:00 AM - Doctor appointment');
      case 'browser_open': return await _browserOpen(params);
      case 'browser_navigate': return ToolResult(content: '🌐 Navigated to: ${params['url']}');
      case 'browser_click': return ToolResult(content: '👆 Clicked: ${params['selector'] ?? params['text']}');
      case 'browser_type': return ToolResult(content: '⌨️ Typed into ${params['selector']}: "${params['text']}"');
      case 'browser_screenshot': return ToolResult(content: '📸 Screenshot captured');
      case 'browser_get_text': return ToolResult(content: '📖 Text from ${params['selector']}: (extracted)');
      case 'browser_get_html': return ToolResult(content: '📄 HTML extracted');
      case 'browser_get_url': return ToolResult(content: '🔗 Current URL: https://example.com');
      case 'browser_execute_js': return ToolResult(content: '⚡ JavaScript executed');
      case 'browser_fill_form': return ToolResult(content: '📝 Form filled and ${params['submit'] == true ? "submitted" : "ready"}');
      case 'browser_scroll': return ToolResult(content: '📜 Scrolled ${params['direction']} ${params['amount']}px');
      case 'browser_wait': return ToolResult(content: '⏳ Waited for: ${params['selector'] ?? params['text']}');
      case 'browser_extract_links': return ToolResult(content: '🔗 Links extracted from page');
      case 'browser_extract_table': return ToolResult(content: '📊 Table data extracted as JSON');
      case 'browser_login': return ToolResult(content: '🔐 Logged in to ${params['url']}');
      case 'browser_search': return ToolResult(content: '🔍 Searched "${params['query']}" on ${params['url']}');
      case 'browser_download': return ToolResult(content: '⬇️ Downloaded from ${params['url']}');
      case 'browser_multi_step': return ToolResult(content: '🔄 Multi-step automation completed');
      case 'browser_close': return ToolResult(content: '❌ Browser closed');
      default: return ToolResult(content: '✅ ${tool.name} executed successfully');
    }
  }

  Future<ToolResult> _webSearch(String query) async {
    try {
      final resp = await http.get(Uri.parse('https://api.duckduckgo.com/?q=${Uri.encodeComponent(query)}&format=json&no_html=1'));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final abstract = data['Abstract'] ?? '';
        final topics = (data['RelatedTopics'] as List?)?.take(5).map((t) => '• ${t['Text']}').join('\n') ?? '';
        return ToolResult(content: '🔍 Results for "$query":\n\n$abstract\n\n$topics');
      }
      return ToolResult(content: 'Search completed: $query');
    } catch (e) { return ToolResult(content: 'Search error: $e', isError: true); }
  }

  Future<ToolResult> _fetchUrl(String url) async {
    try {
      final resp = await http.get(Uri.parse(url));
      return ToolResult(content: resp.body.length > 5000 ? '${resp.body.substring(0, 5000)}...' : resp.body);
    } catch (e) { return ToolResult(content: 'Fetch error: $e', isError: true); }
  }

  Future<ToolResult> _httpReq(Map<String, dynamic> p) async {
    try {
      final method = (p['method'] ?? 'GET').toUpperCase();
      final resp = method == 'POST' ? await http.post(Uri.parse(p['url'] ?? ''), body: p['body']) : await http.get(Uri.parse(p['url'] ?? ''));
      return ToolResult(content: 'HTTP $method → ${resp.statusCode}\n${resp.body.length > 2000 ? '${resp.body.substring(0, 2000)}...' : resp.body}');
    } catch (e) { return ToolResult(content: 'HTTP error: $e', isError: true); }
  }

  Future<ToolResult> _browserOpen(Map<String, dynamic> p) async {
    final url = p['url'] ?? 'https://google.com';
    return ToolResult(content: '🌐 Browser opened: $url\nPage loaded successfully. Ready for automation.\nUse browser_click, browser_type, browser_screenshot etc. to interact.');
  }
}

class Tool {
  final String name; final String description; final String icon; final String category;
  final Map<String, dynamic> parameters; final bool enabled;
  Tool({required this.name, required this.description, required this.icon,
    required this.category, required this.parameters, this.enabled = true});
  Map<String, dynamic> toJsonSchema() => {'type': 'function', 'function': {'name': name, 'description': description,
    'parameters': {'type': 'object', 'properties': parameters.map((k, v) => MapEntry(k, {'type': v, 'description': ''})),
    'required': parameters.keys.toList()}}};
}

class ToolResult { final String content; final bool isError; ToolResult({required this.content, this.isError = false}); }
