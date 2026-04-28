import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🔄 Automation Engine — Cron Jobs, Reminders, Task Scheduling
class AutomationEngine extends ChangeNotifier {
  static final AutomationEngine I = AutomationEngine._();
  AutomationEngine._();

  late SharedPreferences _prefs;
  final Map<String, ScheduledTask> _tasks = {};
  final Map<String, Timer> _timers = {};

  List<ScheduledTask> get tasks => _tasks.values.toList();
  List<ScheduledTask> get activeTasks => _tasks.values.where((t) => t.enabled).toList();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadTasks();
  }

  void _loadTasks() {
    final data = _prefs.getString('scheduled_tasks');
    if (data != null) {
      final Map<String, dynamic> map = jsonDecode(data);
      map.forEach((k, v) => _tasks[k] = ScheduledTask.fromJson(v));
    }
    _scheduleAll();
  }

  Future<void> _saveTasks() async {
    final data = _tasks.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs.setString('scheduled_tasks', jsonEncode(data));
  }

  Future<void> addReminder({required String message, required DateTime time}) async {
    final task = ScheduledTask(
      id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
      name: '⏰ $message',
      type: TaskType.oneShot,
      schedule: time.toIso8601String(),
      task: message,
      enabled: true,
      createdAt: DateTime.now(),
    );
    _tasks[task.id] = task;
    _scheduleTask(task);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> addCronJob({required String name, required String cronExpr, required String task}) async {
    final job = ScheduledTask(
      id: 'cron_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: TaskType.recurring,
      schedule: cronExpr,
      task: task,
      enabled: true,
      createdAt: DateTime.now(),
    );
    _tasks[job.id] = job;
    _scheduleTask(job);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> addInterval({required String name, required Duration interval, required String task}) async {
    final job = ScheduledTask(
      id: 'int_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: TaskType.interval,
      schedule: interval.inMinutes.toString(),
      task: task,
      enabled: true,
      createdAt: DateTime.now(),
    );
    _tasks[job.id] = job;
    _scheduleTask(job);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> removeTask(String id) async {
    _tasks.remove(id);
    _timers[id]?.cancel();
    _timers.remove(id);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> toggleTask(String id, bool enabled) async {
    final task = _tasks[id];
    if (task == null) return;
    _tasks[id] = task.copyWith(enabled: enabled);
    if (enabled) {
      _scheduleTask(_tasks[id]!);
    } else {
      _timers[id]?.cancel();
    }
    await _saveTasks();
    notifyListeners();
  }

  void _scheduleAll() {
    for (var task in _tasks.values) {
      if (task.enabled) _scheduleTask(task);
    }
  }

  void _scheduleTask(ScheduledTask task) {
    _timers[task.id]?.cancel();
    switch (task.type) {
      case TaskType.oneShot:
        final time = DateTime.parse(task.schedule);
        final delay = time.difference(DateTime.now());
        if (delay.isNegative) {
          _executeTask(task);
        } else {
          _timers[task.id] = Timer(delay, () => _executeTask(task));
        }
        break;
      case TaskType.interval:
        final mins = int.tryParse(task.schedule) ?? 60;
        _timers[task.id] = Timer.periodic(Duration(minutes: mins), (_) => _executeTask(task));
        break;
      case TaskType.recurring:
        _timers[task.id] = Timer.periodic(const Duration(hours: 1), (_) => _executeTask(task));
        break;
    }
  }

  void _executeTask(ScheduledTask task) {
    // The Gateway handles actual execution
    if (task.type == TaskType.oneShot) {
      _tasks.remove(task.id);
      _saveTasks();
    }
    notifyListeners();
  }
}

enum TaskType { oneShot, interval, recurring }

class ScheduledTask {
  final String id;
  final String name;
  final TaskType type;
  final String schedule;
  final String task;
  final bool enabled;
  final DateTime createdAt;

  ScheduledTask({
    required this.id, required this.name, required this.type,
    required this.schedule, required this.task, required this.enabled,
    required this.createdAt,
  });

  ScheduledTask copyWith({bool? enabled}) => ScheduledTask(
    id: id, name: name, type: type, schedule: schedule,
    task: task, enabled: enabled ?? this.enabled, createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'type': type.name, 'schedule': schedule,
    'task': task, 'enabled': enabled, 'createdAt': createdAt.toIso8601String(),
  };

  factory ScheduledTask.fromJson(Map<String, dynamic> j) => ScheduledTask(
    id: j['id'], name: j['name'], type: TaskType.values.firstWhere((e) => e.name == j['type']),
    schedule: j['schedule'], task: j['task'], enabled: j['enabled'], createdAt: DateTime.parse(j['createdAt']),
  );
}
