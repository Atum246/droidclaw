import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/droid_theme.dart';
import '../../core/tools/tool_engine.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: DroidTheme.bg, body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 6), child: Row(children: [
        Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(gradient: DroidTheme.grad3, borderRadius: BorderRadius.circular(9)),
          child: const Text('🔧', style: TextStyle(fontSize: 20))),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tools', style: TextStyle(color: DroidTheme.txt, fontSize: 20, fontWeight: FontWeight.w800)),
          Consumer<ToolEngine>(builder: (_, e, __) => Text('${e.tools.length} tools available',
            style: TextStyle(color: DroidTheme.txt3, fontSize: 11))),
        ]),
      ])).animate().fadeIn(),
      Expanded(child: Consumer<ToolEngine>(builder: (_, eng, __) {
        final cats = <String, List<Tool>>{};
        for (var t in eng.tools) { cats.putIfAbsent(t.category, () => []).add(t); }
        return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          itemCount: cats.length, itemBuilder: (_, i) {
            final cat = cats.keys.elementAt(i);
            final tools = cats[cat]!;
            final icons = {'filesystem':'📁','web':'🌐','code':'💻','memory':'🧠','phone':'📱','scheduling':'⏰','integration':'🔗','media':'🎨','browser':'🌍','calls':'📞','messaging':'💬','apps':'📲','location':'📍','camera':'📸','security':'🔐','device':'📊','remote':'🖥️','automation':'🤖','external':'📡'};
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.only(left: 4, top: 10, bottom: 6),
                child: Row(children: [Text(icons[cat] ?? '🔧', style: const TextStyle(fontSize: 14)), const SizedBox(width: 5),
                  Text(cat.toUpperCase(), style: TextStyle(color: DroidTheme.txt2, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1))])),
              ...tools.map((t) => Container(margin: const EdgeInsets.only(bottom: 3), decoration: BoxDecoration(color: DroidTheme.surface, borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  leading: Container(width: 32, height: 32, decoration: BoxDecoration(color: DroidTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
                    child: Center(child: Text(t.icon, style: const TextStyle(fontSize: 16)))),
                  title: Text(t.name, style: TextStyle(color: DroidTheme.txt, fontSize: 12, fontWeight: FontWeight.w500)),
                  subtitle: Text(t.description, style: TextStyle(color: DroidTheme.txt3, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: DroidTheme.green.withOpacity(0.12), borderRadius: BorderRadius.circular(3)),
                    child: Text('ON', style: TextStyle(color: DroidTheme.green, fontSize: 8, fontWeight: FontWeight.w700))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                ))),
            ]);
          });
      })),
    ])));
  }
}
