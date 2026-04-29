import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/droid_theme.dart';
import '../../core/models/local_model_manager.dart';

/// 📥 Local Models Screen — Download & manage on-device AI models
class LocalModelsScreen extends StatefulWidget {
  const LocalModelsScreen({super.key});
  @override
  State<LocalModelsScreen> createState() => _LocalModelsScreenState();
}

class _LocalModelsScreenState extends State<LocalModelsScreen> {
  String _filter = 'All';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DroidTheme.bg,
      appBar: AppBar(
        backgroundColor: DroidTheme.bg,
        title: Row(children: [
          Text('📥', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Local Models', style: TextStyle(color: DroidTheme.txt, fontSize: 18, fontWeight: FontWeight.w700)),
            Text('Download AI models to your phone', style: TextStyle(color: DroidTheme.txt3, fontSize: 11)),
          ]),
        ]),
        actions: [
          IconButton(icon: Icon(Icons.add_link, color: DroidTheme.accent),
            onPressed: () => _importUrl()),
          IconButton(icon: Icon(Icons.file_upload, color: DroidTheme.cyan),
            onPressed: () => _importFile()),
        ],
      ),
      body: Column(children: [
        // Search
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextField(onChanged: (v) => setState(() => _search = v),
            style: TextStyle(color: DroidTheme.txt, fontSize: 13),
            decoration: InputDecoration(
              hintText: '🔍 Search models...', hintStyle: TextStyle(color: DroidTheme.txt3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)))),

        // Filter chips
        SizedBox(height: 38, child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: ['All', 'Downloaded', 'Gemma', 'Llama', 'Phi', 'Qwen', 'Mistral', 'DeepSeek'].map((f) {
            final sel = _filter == f;
            return GestureDetector(onTap: () => setState(() => _filter = f),
              child: Container(margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: sel ? DroidTheme.accent.withValues(alpha: 0.15) : DroidTheme.surface,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: sel ? DroidTheme.accent.withValues(alpha: 0.4) : DroidTheme.border)),
                child: Text(f, style: TextStyle(
                  color: sel ? DroidTheme.accent : DroidTheme.txt2, fontSize: 11,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400))));
          }).toList(),
        )),

        // Model list
        Expanded(child: Consumer<LocalModelManager>(builder: (_, mgr, __) {
          var models = mgr.models;
          if (_filter == 'Downloaded') {
            models = models.where((m) => m.downloaded).toList();
          } else if (_filter != 'All') {
            models = models.where((m) => m.family == _filter).toList();
          }
          if (_search.isNotEmpty) {
            final l = _search.toLowerCase();
            models = models.where((m) => m.name.toLowerCase().contains(l) || m.description.toLowerCase().contains(l)).toList();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: models.length,
            itemBuilder: (_, i) {
              final m = models[i];
              final progress = mgr.downloadProgress[m.id];
              final isActive = mgr.activeLocalModel == m.id;

              return Container(margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isActive ? DroidTheme.accent.withValues(alpha: 0.08) : DroidTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive ? DroidTheme.accent.withValues(alpha: 0.4) : DroidTheme.border, width: 0.5)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    // Icon
                    Container(width: 42, height: 42,
                      decoration: BoxDecoration(color: DroidTheme.card, borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text(m.icon, style: const TextStyle(fontSize: 22)))),
                    const SizedBox(width: 12),
                    // Info
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(m.name, style: TextStyle(
                          color: DroidTheme.txt, fontSize: 14, fontWeight: FontWeight.w600))),
                        if (m.downloaded) Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: DroidTheme.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(3)),
                          child: Text('DOWNLOADED', style: TextStyle(color: DroidTheme.green, fontSize: 8, fontWeight: FontWeight.w800))),
                      ]),
                      Text('${m.family} • ${m.size} • ${m.quantization}',
                        style: TextStyle(color: DroidTheme.txt3, fontSize: 11)),
                    ])),
                  ]),
                  const SizedBox(height: 8),
                  Text(m.description, style: TextStyle(color: DroidTheme.txt2, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 6),
                  // Tags
                  Wrap(spacing: 4, children: [
                    _tag('💾 ${m.size}'),
                    _tag('🧠 ${m.ramRequired} RAM'),
                    ...m.capabilities.map((c) => _tag(c)),
                  ]),
                  const SizedBox(height: 10),
                  // Download progress
                  if (progress != null) ...[
                    ClipRRect(borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: progress,
                        backgroundColor: DroidTheme.card, valueColor: AlwaysStoppedAnimation(DroidTheme.accent),
                        minHeight: 6)),
                    const SizedBox(height: 4),
                    Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(color: DroidTheme.txt3, fontSize: 10)),
                  ],
                  // Action buttons
                  Row(children: [
                    if (!m.downloaded) ...[
                      Expanded(child: ElevatedButton.icon(
                        onPressed: () => mgr.downloadModel(m.id),
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DroidTheme.accent,
                          padding: const EdgeInsets.symmetric(vertical: 10)))),
                    ] else ...[
                      Expanded(child: OutlinedButton.icon(
                        onPressed: () => mgr.setActiveLocalModel(m.id),
                        icon: Icon(isActive ? Icons.check_circle : Icons.play_arrow, size: 16,
                          color: isActive ? DroidTheme.green : DroidTheme.accent),
                        label: Text(isActive ? 'Active' : 'Use Model',
                          style: TextStyle(color: isActive ? DroidTheme.green : DroidTheme.accent)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isActive ? DroidTheme.green : DroidTheme.accent),
                          padding: const EdgeInsets.symmetric(vertical: 10)))),
                      const SizedBox(width: 8),
                      IconButton(icon: Icon(Icons.delete_outline, color: DroidTheme.red, size: 18),
                        onPressed: () => mgr.deleteModel(m.id)),
                    ],
                  ]),
                ]),
              ).animate().fadeIn(delay: Duration(milliseconds: 30 + i * 30));
            });
        })),
      ]),
    );
  }

  Widget _tag(String text) {
    return Container(margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: DroidTheme.card, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: DroidTheme.txt3, fontSize: 9)));
  }

  void _importUrl() {
    final ctrl = TextEditingController();
    final nameCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: DroidTheme.surface,
      title: Text('Import Model from URL 🔗', style: TextStyle(color: DroidTheme.txt)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, style: TextStyle(color: DroidTheme.txt),
          decoration: InputDecoration(hintText: 'Model name', hintStyle: TextStyle(color: DroidTheme.txt3))),
        const SizedBox(height: 8),
        TextField(controller: ctrl, style: TextStyle(color: DroidTheme.txt),
          decoration: InputDecoration(hintText: 'https://huggingface.co/...gguf', hintStyle: TextStyle(color: DroidTheme.txt3))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: DroidTheme.txt3))),
        ElevatedButton(onPressed: () {
          if (ctrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
            LocalModelManager.I.importFromUrl(ctrl.text, nameCtrl.text);
            Navigator.pop(context);
          }
        }, child: const Text('Import')),
      ],
    ));
  }

  void _importFile() {
    // Use file_picker to select .gguf file
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: DroidTheme.surface,
      title: Text('Import GGUF File 📁', style: TextStyle(color: DroidTheme.txt)),
      content: Text('Select a .gguf model file from your device.\n\nSupported formats:\n• .gguf (llama.cpp)\n• .ggml (legacy)', 
        style: TextStyle(color: DroidTheme.txt2, height: 1.5)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: DroidTheme.txt3))),
        ElevatedButton(onPressed: () {
          // file_picker integration
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File picker opened 📁')));
        }, child: const Text('Select File')),
      ],
    ));
  }
}
