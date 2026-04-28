import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/droid_theme.dart';
import '../../core/memory/memory_engine.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});
  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  MemoryStats? _stats;
  List<MemoryEntry> _memories = [];

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final stats = await MemoryEngine.I.getStats();
    final mems = await MemoryEngine.I.getAllMemories();
    setState(() { _stats = stats; _memories = mems; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: DroidTheme.bg, body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 6), child: Row(children: [
        Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(gradient: DroidTheme.grad4, borderRadius: BorderRadius.circular(9)),
          child: const Text('🧠', style: TextStyle(fontSize: 20))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Memory', style: TextStyle(color: DroidTheme.txt, fontSize: 20, fontWeight: FontWeight.w800)),
          Text('Long-term memory & knowledge', style: TextStyle(color: DroidTheme.txt3, fontSize: 11)),
        ])),
        IconButton(icon: Icon(Icons.delete_outline, color: DroidTheme.red, size: 18),
          onPressed: () async { await MemoryEngine.I.clearAll(); _load(); }),
      ])).animate().fadeIn(),
      if (_stats != null) Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6), child: Row(children: [
        _stat('💬', 'Chats', _stats!.conversations.toString()), const SizedBox(width: 6),
        _stat('🧠', 'Memories', _stats!.memories.toString()), const SizedBox(width: 6),
        _stat('📚', 'Knowledge', _stats!.knowledge.toString()), const SizedBox(width: 6),
        _stat('💬', 'Messages', _stats!.messages.toString()),
      ])).animate().fadeIn(delay: 100.ms),
      Expanded(child: _memories.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('🧠', style: TextStyle(fontSize: 44)), const SizedBox(height: 10),
            Text('No memories yet', style: TextStyle(color: DroidTheme.txt2, fontSize: 14)),
            Text('Use "remember" to save things', style: TextStyle(color: DroidTheme.txt3, fontSize: 11)),
          ]))
        : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), itemCount: _memories.length,
          itemBuilder: (_, i) { final m = _memories[i]; return Container(margin: const EdgeInsets.only(bottom: 5), padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: DroidTheme.surface, borderRadius: BorderRadius.circular(9), border: Border.all(color: DroidTheme.border, width: 0.5)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(color: DroidTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(3)),
                child: Text(m.category, style: TextStyle(color: DroidTheme.accent, fontSize: 8, fontWeight: FontWeight.w600)))]),
              const SizedBox(height: 4),
              Text(m.key, style: TextStyle(color: DroidTheme.txt, fontSize: 12, fontWeight: FontWeight.w600)),
              Text(m.value, style: TextStyle(color: DroidTheme.txt2, fontSize: 11, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ); })),
      FloatingActionButton(onPressed: () => _add(), backgroundColor: DroidTheme.accent,
        child: const Icon(Icons.add, color: Colors.white)),
    ])));
  }

  Widget _stat(String e, String l, String v) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: DroidTheme.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: DroidTheme.border, width: 0.5)),
      child: Column(children: [Text(e, style: const TextStyle(fontSize: 16)), const SizedBox(height: 2),
        Text(v, style: TextStyle(color: DroidTheme.txt, fontSize: 14, fontWeight: FontWeight.w700)),
        Text(l, style: TextStyle(color: DroidTheme.txt3, fontSize: 8))])));
  }

  void _add() {
    final kCtrl = TextEditingController(), vCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: DroidTheme.surface,
      title: Text('Add Memory 🧠', style: TextStyle(color: DroidTheme.txt)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: kCtrl, style: TextStyle(color: DroidTheme.txt),
          decoration: InputDecoration(hintText: 'Key', hintStyle: TextStyle(color: DroidTheme.txt3))),
        const SizedBox(height: 8),
        TextField(controller: vCtrl, style: TextStyle(color: DroidTheme.txt), maxLines: 3,
          decoration: InputDecoration(hintText: 'Value', hintStyle: TextStyle(color: DroidTheme.txt3))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: DroidTheme.txt3))),
        ElevatedButton(onPressed: () async {
          if (kCtrl.text.isNotEmpty && vCtrl.text.isNotEmpty) {
            await MemoryEngine.I.saveMemory(kCtrl.text, vCtrl.text);
            Navigator.pop(context); _load();
          }
        }, child: const Text('Save')),
      ],
    ));
  }
}
