import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/droid_theme.dart';
import '../../core/skills/skill_engine.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});
  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  String _q = '', _cat = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: DroidTheme.bg, body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 6), child: Row(children: [
        Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(gradient: DroidTheme.grad2, borderRadius: BorderRadius.circular(9)),
          child: const Text('⚡', style: TextStyle(fontSize: 20))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Skills', style: TextStyle(color: DroidTheme.txt, fontSize: 20, fontWeight: FontWeight.w800)),
          Consumer<SkillEngine>(builder: (_, e, __) => Text('${e.enabledSkills.length}/${e.skills.length} active',
            style: TextStyle(color: DroidTheme.txt3, fontSize: 11))),
        ])),
      ])).animate().fadeIn(),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: TextField(onChanged: (v) => setState(() => _q = v), style: TextStyle(color: DroidTheme.txt, fontSize: 13),
          decoration: InputDecoration(hintText: '🔍 Search ${SkillEngine.I.skills.length} skills...',
            hintStyle: TextStyle(color: DroidTheme.txt3), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)))),
      SizedBox(height: 36, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ['All', ...SkillEngine.I.skills.map((s) => s.category).toSet()].length,
        itemBuilder: (_, i) {
          final cats = ['All', ...SkillEngine.I.skills.map((s) => s.category).toSet()];
          final c = cats[i]; final sel = _cat == c;
          return GestureDetector(onTap: () => setState(() => _cat = c),
            child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: sel ? DroidTheme.accent.withOpacity(0.15) : DroidTheme.surface,
                borderRadius: BorderRadius.circular(7), border: Border.all(color: sel ? DroidTheme.accent.withOpacity(0.4) : DroidTheme.border)),
              child: Text(c, style: TextStyle(color: sel ? DroidTheme.accent : DroidTheme.txt2, fontSize: 11,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400))));
        })),
      Expanded(child: Consumer<SkillEngine>(builder: (_, eng, __) {
        var skills = eng.skills;
        if (_cat != 'All') skills = skills.where((s) => s.category == _cat).toList();
        if (_q.isNotEmpty) { final l = _q.toLowerCase(); skills = skills.where((s) => s.name.toLowerCase().contains(l) || s.description.toLowerCase().contains(l)).toList(); }
        return GridView.builder(padding: const EdgeInsets.all(14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.4),
          itemCount: skills.length, itemBuilder: (_, i) {
            final s = skills[i]; final on = eng.enabledSkills.any((e) => e.id == s.id);
            return GestureDetector(onTap: () => _detail(s, on, eng),
              child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: DroidTheme.card,
                borderRadius: BorderRadius.circular(10), border: Border.all(color: DroidTheme.border, width: 0.5)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text(s.icon, style: const TextStyle(fontSize: 20)), const Spacer(),
                    if (on) Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: DroidTheme.green.withOpacity(0.15), borderRadius: BorderRadius.circular(3)),
                      child: Text('ON', style: TextStyle(color: DroidTheme.green, fontSize: 8, fontWeight: FontWeight.w800)))]),
                  const SizedBox(height: 6),
                  Text(s.name, style: TextStyle(color: DroidTheme.txt, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Expanded(child: Text(s.description, style: TextStyle(color: DroidTheme.txt3, fontSize: 9, height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis)),
                ]),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 30 + i * 20));
          });
      })),
    ])));
  }

  void _detail(Skill s, bool on, SkillEngine eng) {
    showModalBottomSheet(context: context, backgroundColor: DroidTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(padding: const EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 34, height: 4, decoration: BoxDecoration(color: DroidTheme.txt3.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 14),
        Text(s.icon, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text(s.name, style: TextStyle(color: DroidTheme.txt, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Text(s.description, textAlign: TextAlign.center, style: TextStyle(color: DroidTheme.txt2, fontSize: 13, height: 1.5)),
        const SizedBox(height: 6),
        Wrap(spacing: 4, children: s.triggers.take(5).map((t) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(color: DroidTheme.surfaceLight, borderRadius: BorderRadius.circular(4)),
          child: Text('@$t', style: TextStyle(color: DroidTheme.txt3, fontSize: 9)))).toList()),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity,
          child: ElevatedButton(onPressed: () { on ? eng.skills : null; Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: on ? DroidTheme.red : DroidTheme.accent,
              padding: const EdgeInsets.symmetric(vertical: 12)),
            child: Text(on ? 'Disable ❌' : 'Enable ⚡'))),
      ])));
  }
}
