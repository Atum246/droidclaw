import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/droid_theme.dart';
import '../../core/gateway/droidclaw_gateway.dart';
import '../../core/agents/sub_agent_manager.dart';
import '../../core/tools/tool_engine.dart';
import '../../core/tools/tool_creator.dart';
import '../../core/skills/skill_engine.dart';
import '../../core/skills/skill_creator.dart';
import '../../core/memory/memory_engine.dart';
import '../../core/heartbeat/heartbeat_engine.dart';
import '../../core/browser/browser_engine.dart';
import '../../core/workflow/workflow_builder.dart';
import '../../core/streaming/streaming_engine.dart';
import '../../core/research/deep_research_engine.dart';

/// 📊 Smart Dashboard — Live Status of Everything
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: DroidTheme.bg, body: SafeArea(
      child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 16),
          _statusRow(),
          const SizedBox(height: 16),
          _agentStatus(),
          const SizedBox(height: 12),
          _quickStats(),
          const SizedBox(height: 12),
          _recentActivity(),
          const SizedBox(height: 12),
          _quickActions(context),
        ],
      )),
    ));
  }

  Widget _header() {
    return Row(children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(gradient: DroidTheme.grad1, borderRadius: BorderRadius.circular(10)),
        child: const Center(child: Text('📊', style: TextStyle(fontSize: 20)))),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Dashboard', style: TextStyle(color: DroidTheme.txt, fontSize: 20, fontWeight: FontWeight.w800)),
        Text('Everything at a glance', style: TextStyle(color: DroidTheme.txt3, fontSize: 12)),
      ]),
    ]).animate().fadeIn();
  }

  Widget _statusRow() {
    return Consumer<DroidClawGateway>(builder: (_, gw, __) {
      return Row(children: [
        _statusCard('🤖', 'Agent', gw.isProcessing ? 'Working...' : 'Ready',
          gw.isProcessing ? DroidTheme.amber : DroidTheme.green),
        const SizedBox(width: 8),
        Consumer<HeartbeatEngine>(builder: (_, hb, __) =>
          _statusCard('💓', 'Heartbeat', hb.isActive ? 'Active' : 'Off',
            hb.isActive ? DroidTheme.green : DroidTheme.txt3)),
        const SizedBox(width: 8),
        Consumer<BrowserEngine>(builder: (_, br, __) =>
          _statusCard('🌐', 'Browser', br.isOpen ? 'Open' : 'Closed',
            br.isOpen ? DroidTheme.cyan : DroidTheme.txt3)),
      ]);
    }).animate().fadeIn(delay: 100.ms);
  }

  Widget _statusCard(String icon, String label, String value, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: DroidTheme.surface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5)),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(color: DroidTheme.txt3, fontSize: 9)),
      ]),
    ));
  }

  Widget _agentStatus() {
    return Consumer<SubAgentManager>(builder: (_, agents, __) {
      final active = agents.activeAgents;
      if (active.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: DroidTheme.surface, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DroidTheme.accent.withOpacity(0.2), width: 0.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('🤖', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text('Active Sub-Agents', style: TextStyle(color: DroidTheme.txt, fontSize: 13, fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: DroidTheme.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
              child: Text('${active.length}', style: TextStyle(color: DroidTheme.accent, fontSize: 10, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 10),
          ...active.take(5).map((a) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            Container(width: 6, height: 6,
              decoration: BoxDecoration(color: a.status == AgentStatus.running ? DroidTheme.amber : DroidTheme.green, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(a.label, style: TextStyle(color: DroidTheme.txt, fontSize: 11))),
            Text(a.statusMessage ?? a.status.name, style: TextStyle(color: DroidTheme.txt3, fontSize: 9)),
          ]))),
        ]),
      ).animate().fadeIn(delay: 200.ms);
    });
  }

  Widget _quickStats() {
    return FutureBuilder<MemoryStats>(
      future: MemoryEngine.I.getStats(),
      builder: (_, snap) {
        final stats = snap.data;
        return Row(children: [
          _statCard('🔧', 'Tools', '${ToolEngine.I.toolCount}', DroidTheme.cyan),
          const SizedBox(width: 8),
          _statCard('⚡', 'Skills', '${SkillEngine.I.skills.length}', DroidTheme.amber),
          const SizedBox(width: 8),
          _statCard('🧠', 'Memories', '${stats?.memories ?? 0}', DroidTheme.purple),
          const SizedBox(width: 8),
          _statCard('💬', 'Messages', '${stats?.messages ?? 0}', DroidTheme.green),
        ]);
      },
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _statCard(String icon, String label, String value, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: DroidTheme.surface, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(color: DroidTheme.txt3, fontSize: 9)),
      ]),
    ));
  }

  Widget _recentActivity() {
    return Consumer<SubAgentManager>(builder: (_, agents, __) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: DroidTheme.surface, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('📋 Recent Activity', style: TextStyle(color: DroidTheme.txt, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _activityItem('🔧', 'Tools Created', '${ToolCreator.I.createdCount}'),
          _activityItem('⚡', 'Skills Created', '${SkillCreator.I.createdSkills.length}'),
          _activityItem('🔬', 'Research Projects', '${DeepResearchEngine.I.projects.length}'),
          _activityItem('🔄', 'Workflows', '${WorkflowBuilder.I.workflows.length}'),
          _activityItem('💓', 'Heartbeats', '${HeartbeatEngine.I.recentEvents.length}'),
        ]),
      );
    }).animate().fadeIn(delay: 400.ms);
  }

  Widget _activityItem(String icon, String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: TextStyle(color: DroidTheme.txt2, fontSize: 12))),
      Text(value, style: TextStyle(color: DroidTheme.accent, fontSize: 12, fontWeight: FontWeight.w600)),
    ]));
  }

  Widget _quickActions(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('⚡ Quick Actions', style: TextStyle(color: DroidTheme.txt, fontSize: 13, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _actionBtn('🔬', 'Deep Research', () {}),
        _actionBtn('🤖', 'Spawn Agent', () {}),
        _actionBtn('🔄', 'New Workflow', () {}),
        _actionBtn('💓', 'Heartbeat', () => HeartbeatEngine.I.triggerNow()),
        _actionBtn('🧹', 'Cleanup', () => SubAgentManager.I.cleanup()),
        _actionBtn('📊', 'Full Report', () {}),
      ]),
    ]).animate().fadeIn(delay: 500.ms);
  }

  Widget _actionBtn(String icon, String label, VoidCallback onTap) {
    return GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: DroidTheme.card, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DroidTheme.border.withOpacity(0.3), width: 0.5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: DroidTheme.txt, fontSize: 12)),
        ]),
      ),
    );
  }
}
