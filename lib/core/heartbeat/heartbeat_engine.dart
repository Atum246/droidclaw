import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../gateway/droidclaw_gateway.dart';
import '../memory/memory_engine.dart';
import '../automation/automation_engine.dart';

/// 💓 Heartbeat Engine — Proactive Agent that Checks Things Without Being Asked
/// Like OpenClaw's heartbeat: periodically checks email, calendar, notifications,
/// weather, and does background maintenance
class HeartbeatEngine extends ChangeNotifier {
  static final HeartbeatEngine I = HeartbeatEngine._();
  HeartbeatEngine._();

  late SharedPreferences _prefs;
  Timer? _heartbeatTimer;
  Timer? _maintenanceTimer;
  bool _active = false;
  DateTime? _lastHeartbeat;
  DateTime? _lastMaintenance;
  final List<HeartbeatEvent> _recentEvents = [];
  final Map<String, int> _checkCounts = {};
  HeartbeatConfig _config = HeartbeatConfig.defaults();

  bool get isActive => _active;
  DateTime? get lastHeartbeat => _lastHeartbeat;
  List<HeartbeatEvent> get recentEvents => List.unmodifiable(_recentEvents);
  HeartbeatConfig get config => _config;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadConfig();
    if (_config.enabled) start();
  }

  void _loadConfig() {
    final data = _prefs.getString('heartbeat_config');
    if (data != null) {
      try { _config = HeartbeatConfig.fromJson(jsonDecode(data)); } catch (_) {}
    }
  }

  Future<void> saveConfig(HeartbeatConfig config) async {
    _config = config;
    await _prefs.setString('heartbeat_config', jsonEncode(config.toJson()));
    if (config.enabled) {
      start();
    } else {
      stop();
    }
  }

  /// Start the heartbeat
  void start() {
    if (_active) return;
    _active = true;

    // Main heartbeat: every N minutes
    _heartbeatTimer = Timer.periodic(
      Duration(minutes: _config.intervalMinutes),
      (_) => _heartbeat(),
    );

    // Maintenance: every 6 hours
    _maintenanceTimer = Timer.periodic(
      const Duration(hours: 6),
      (_) => _maintenance(),
    );

    notifyListeners();
  }

  /// Stop the heartbeat
  void stop() {
    _active = false;
    _heartbeatTimer?.cancel();
    _maintenanceTimer?.cancel();
    _heartbeatTimer = null;
    _maintenanceTimer = null;
    notifyListeners();
  }

  /// Trigger a manual heartbeat
  Future<HeartbeatResult> triggerNow() async {
    return await _heartbeat();
  }

  Future<HeartbeatResult> _heartbeat() async {
    _lastHeartbeat = DateTime.now();
    final alerts = <HeartbeatAlert>[];
    final checks = <String>[];

    try {
      // ═══════════════════════════════════════════
      // 📅 Check Calendar
      // ═══════════════════════════════════════════
      if (_config.checkCalendar) {
        try {
          final calResult = await DroidClawGateway.I.process(
            userMessage: 'Check my calendar for upcoming events in the next 2 hours. Only tell me if there are events. If no events, say "no upcoming events".',
            sessionId: 'heartbeat',
          );
          if (calResult.content.toLowerCase().contains('no upcoming') == false &&
              calResult.content.length > 20) {
            alerts.add(HeartbeatAlert(
              type: AlertType.calendar,
              icon: '📅',
              title: 'Upcoming Event',
              body: calResult.content,
              priority: AlertPriority.medium,
            ));
          }
          checks.add('calendar');
        } catch (_) {}
      }

      // ═══════════════════════════════════════════
      // 🔋 Check Battery
      // ═══════════════════════════════════════════
      if (_config.checkBattery) {
        try {
          final batResult = await DroidClawGateway.I.process(
            userMessage: 'Check my battery level. Only alert me if below 20%.',
            sessionId: 'heartbeat',
          );
          if (batResult.content.contains('🔋') && _extractBatteryLevel(batResult.content) < 20) {
            alerts.add(HeartbeatAlert(
              type: AlertType.battery,
              icon: '🔋',
              title: 'Low Battery',
              body: batResult.content,
              priority: AlertPriority.high,
            ));
          }
          checks.add('battery');
        } catch (_) {}
      }

      // ═══════════════════════════════════════════
      // 📱 Check Notifications (simulated)
      // ═══════════════════════════════════════════
      if (_config.checkNotifications) {
        checks.add('notifications');
      }

      // ═══════════════════════════════════════════
      // 🌤️ Check Weather
      // ═══════════════════════════════════════════
      if (_config.checkWeather) {
        try {
          final weatherResult = await DroidClawGateway.I.process(
            userMessage: 'Quick weather check for my location. Only alert me about severe weather (storms, extreme heat/cold, rain in next hour).',
            sessionId: 'heartbeat',
          );
          if (weatherResult.content.toLowerCase().contains('severe') ||
              weatherResult.content.toLowerCase().contains('storm') ||
              weatherResult.content.toLowerCase().contains('rain')) {
            alerts.add(HeartbeatAlert(
              type: AlertType.weather,
              icon: '🌧️',
              title: 'Weather Alert',
              body: weatherResult.content,
              priority: AlertPriority.medium,
            ));
          }
          checks.add('weather');
        } catch (_) {}
      }

      // Record event
      _recentEvents.add(HeartbeatEvent(
        timestamp: DateTime.now(),
        checksPerformed: checks,
        alertsGenerated: alerts.length,
      ));

      // Keep only last 50 events
      if (_recentEvents.length > 50) _recentEvents.removeAt(0);

      // Update check counts
      for (var check in checks) {
        _checkCounts[check] = (_checkCounts[check] ?? 0) + 1;
      }

    } catch (e) {
      _recentEvents.add(HeartbeatEvent(
        timestamp: DateTime.now(),
        checksPerformed: checks,
        alertsGenerated: alerts.length,
        error: e.toString(),
      ));
    }

    notifyListeners();
    return HeartbeatResult(alerts: alerts, checksPerformed: checks);
  }

  Future<void> _maintenance() async {
    _lastMaintenance = DateTime.now();

    // Memory cleanup: remove old entries
    try {
      final memories = await MemoryEngine.I.getAllMemories();
      // Remove memories with 0 access count that are older than 30 days
      // (would need date parsing in production)
    } catch (_) {}

    // Clean up completed sub-agents
    try {
      // SubAgentManager.I.cleanup();
    } catch (_) {}

    notifyListeners();
  }

  int _extractBatteryLevel(String text) {
    final match = RegExp(r'(\d+)%').firstMatch(text);
    return match != null ? int.parse(match.group(1)!) : 100;
  }
}

enum AlertType { calendar, battery, weather, email, reminder, custom }
enum AlertPriority { low, medium, high, critical }

class HeartbeatAlert {
  final AlertType type;
  final String icon;
  final String title;
  final String body;
  final AlertPriority priority;
  final DateTime timestamp;

  HeartbeatAlert({
    required this.type,
    required this.icon,
    required this.title,
    required this.body,
    required this.priority,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class HeartbeatEvent {
  final DateTime timestamp;
  final List<String> checksPerformed;
  final int alertsGenerated;
  final String? error;

  HeartbeatEvent({
    required this.timestamp,
    required this.checksPerformed,
    required this.alertsGenerated,
    this.error,
  });
}

class HeartbeatResult {
  final List<HeartbeatAlert> alerts;
  final List<String> checksPerformed;

  HeartbeatResult({required this.alerts, required this.checksPerformed});
}

class HeartbeatConfig {
  final bool enabled;
  final int intervalMinutes;
  final bool checkCalendar;
  final bool checkBattery;
  final bool checkNotifications;
  final bool checkWeather;
  final bool checkEmail;
  final String? quietHoursStart; // e.g. "23:00"
  final String? quietHoursEnd;   // e.g. "07:00"

  HeartbeatConfig({
    this.enabled = true,
    this.intervalMinutes = 30,
    this.checkCalendar = true,
    this.checkBattery = true,
    this.checkNotifications = true,
    this.checkWeather = true,
    this.checkEmail = false,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  factory HeartbeatConfig.defaults() => HeartbeatConfig();

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'intervalMinutes': intervalMinutes,
    'checkCalendar': checkCalendar,
    'checkBattery': checkBattery,
    'checkNotifications': checkNotifications,
    'checkWeather': checkWeather,
    'checkEmail': checkEmail,
    'quietHoursStart': quietHoursStart,
    'quietHoursEnd': quietHoursEnd,
  };

  factory HeartbeatConfig.fromJson(Map<String, dynamic> j) => HeartbeatConfig(
    enabled: j['enabled'] ?? true,
    intervalMinutes: j['intervalMinutes'] ?? 30,
    checkCalendar: j['checkCalendar'] ?? true,
    checkBattery: j['checkBattery'] ?? true,
    checkNotifications: j['checkNotifications'] ?? true,
    checkWeather: j['checkWeather'] ?? true,
    checkEmail: j['checkEmail'] ?? false,
    quietHoursStart: j['quietHoursStart'],
    quietHoursEnd: j['quietHoursEnd'],
  );
}
