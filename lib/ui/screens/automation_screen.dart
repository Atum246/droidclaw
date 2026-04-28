import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/droid_theme.dart';
import '../../core/automation/automation_engine.dart';

class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: DroidTheme.bg, body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 6), child: Row(children: [
        Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(gradient: DroidTheme.grad1, borderRadius: BorderRadius.circular(9)),
          child: const Text('🔄', style: TextStyle(fontSize: 20))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Automation', style: TextStyle(color: DroidTheme.txt, fontSize: 20, fontWeight: FontWeight.w800)),
          Consumer<AutomationEngine>(builder: (_, e, __) => Text('${e.activeTasks.length} active tasks',
            style: TextStyle(color: DroidTheme.txt3, fontSize: 11))),
        ])),
      ])).animate().fadeIn(),
      Expanded(child: Consumer<AutomationEngine>(builder: (_, eng, __) {
        if (eng.tasks.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('🔄', style: TextStyle(fontSize: 44)), const SizedBox(height: 10),
          Text('No automation tasks', style: TextStyle(color: DroidTheme.txt2, fontSize: 14)),
          Text('Create reminders & scheduled tasks', style: TextStyle(color: DroidTheme.txt3, fontSize: 11)),
        ]));
        return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), itemCount: eng.tasks.length,
          itemBuilder: (_, i) { final t = eng.tasks[i]; return Container(margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: DroidTheme.surface, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DroidTheme.border, width: 0.5)),
            child: Row(children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(
                color: t.enabled ? DroidTheme.accent.withOpacity(0.12) : DroidTheme.txt3.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(t.type == TaskType.oneShot ? '⏰' : '🔄', style: const TextStyle(fontSize: 18)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.name, style: TextStyle(color: DroidTheme.txt, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(t.task, style: TextStyle(color: DroidTheme.txt3, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              Switch(value: t.enabled, onChanged: (v) => eng.toggleTask(t.id, v), activeColor: DroidTheme.accent),
              IconButton(icon: Icon(Icons.delete_outline, color: DroidTheme.red, size: 16),
                onPressed: () => eng.removeTask(t.id), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ]),
          ); });
      })),
      Padding(padding: const EdgeInsets.all(14), child: Row(children: [
        Expanded(child: ElevatedButton.icon(onPressed: () => _addReminder(context),
          icon: const Icon(Icons.alarm, size: 16), label: const Text('Reminder'),
          style: ElevatedButton.styleFrom(backgroundColor: DroidTheme.amber, padding: const EdgeInsets.symmetric(vertical: 11)))),
        const SizedBox(width: 8),
        Expanded(child: ElevatedButton.icon(onPressed: () => _addCron(context),
          icon: const Icon(Icons.schedule, size: 16), label: const Text('Recurring'),
          style: ElevatedButton.styleFrom(backgroundColor: DroidTheme.accent, padding: const EdgeInsets.symmetric(vertical: 11)))),
      ])),
    ])));
  }

  void _addReminder(BuildContext context) {
    final msgCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: DroidTheme.surface,
      title: Text('Set Reminder ⏰', style: TextStyle(color: DroidTheme.txt)),
      content: TextField(controller: msgCtrl, style: TextStyle(color: DroidTheme.txt),
        decoration: InputDecoration(hintText: 'What to remind?', hintStyle: TextStyle(color: DroidTheme.txt3))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: DroidTheme.txt3))),
        ElevatedButton(onPressed: () {
          if (msgCtrl.text.isNotEmpty) {
            AutomationEngine.I.addReminder(message: msgCtrl.text, time: DateTime.now().add(const Duration(hours: 1)));
            Navigator.pop(context);
          }
        }, child: const Text('Set')),
      ],
    ));
  }

  void _addCron(BuildContext context) {
    final nameCtrl = TextEditingController(), taskCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: DroidTheme.surface,
      title: Text('Recurring Task 🔄', style: TextStyle(color: DroidTheme.txt)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, style: TextStyle(color: DroidTheme.txt),
          decoration: InputDecoration(hintText: 'Task name', hintStyle: TextStyle(color: DroidTheme.txt3))),
        const SizedBox(height: 8),
        TextField(controller: taskCtrl, style: TextStyle(color: DroidTheme.txt),
          decoration: InputDecoration(hintText: 'What to do', hintStyle: TextStyle(color: DroidTheme.txt3))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: DroidTheme.txt3))),
        ElevatedButton(onPressed: () {
          if (nameCtrl.text.isNotEmpty && taskCtrl.text.isNotEmpty) {
            AutomationEngine.I.addCronJob(name: nameCtrl.text, cronExpr: '0 * * * *', task: taskCtrl.text);
            Navigator.pop(context);
          }
        }, child: const Text('Create')),
      ],
    ));
  }
}
