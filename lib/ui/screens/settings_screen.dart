import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/droid_theme.dart';
import '../../core/providers/ai_provider_manager.dart';
import '../../core/memory/memory_engine.dart';
import '../../core/tools/tool_engine.dart';
import '../../core/skills/skill_engine.dart';
import '../../core/models/local_model_manager.dart';
import '../../core/automation/automation_engine.dart';
import 'local_models_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: DroidTheme.bg, body: SafeArea(
      child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(gradient: DroidTheme.grad4, borderRadius: BorderRadius.circular(9)),
            child: const Text('⚙️', style: TextStyle(fontSize: 20))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Settings', style: TextStyle(color: DroidTheme.txt, fontSize: 20, fontWeight: FontWeight.w800)),
            Text('Configure DroidClaw', style: TextStyle(color: DroidTheme.txt3, fontSize: 11)),
          ]),
        ]).animate().fadeIn(),
        const SizedBox(height: 16),

        // ═══ AI PROVIDER ═══
        _section('🤖 AI Provider', [
          _tile(Icons.smart_toy, DroidTheme.accent, 'Active Provider',
            '${AIProviderManager.I.activeProvider.icon} ${AIProviderManager.I.activeProvider.name}', onTap: () => _pickProvider(context)),
          _tile(Icons.model_training, DroidTheme.cyan, 'Active Model', AIProviderManager.I.activeModelId, onTap: () => _pickModel(context)),
          _tile(Icons.swap_horiz, DroidTheme.green, 'Quick Model Swap', 'Switch models mid-conversation'),
          _tile(Icons.speed, DroidTheme.amber, 'Temperature', '0.7 — Controls creativity'),
          _tile(Icons.token, DroidTheme.pink, 'Max Tokens', '4096 — Response length limit'),
        ]),
        const SizedBox(height: 10),

        // ═══ API KEYS ═══
        _section('🔑 API Keys', [
          _tile(Icons.key, DroidTheme.green, 'Manage API Keys', '35+ providers supported', onTap: () => _apiKeys(context)),
          _tile(Icons.link, DroidTheme.amber, 'Custom Endpoint', 'Ollama, LM Studio, vLLM', onTap: () => _customEndpoint(context)),
          _tile(Icons.wifi_tethering, DroidTheme.cyan, 'Local Server Status', 'Check Ollama/LM Studio'),
        ]),
        const SizedBox(height: 10),

        // ═══ LOCAL MODELS ═══
        _section('📥 Local Models (On-Device)', [
          _tile(Icons.download, DroidTheme.accent, 'Download Models', 'Gemma, Llama, Phi, Qwen & more',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalModelsScreen()))),
          _tile(Icons.phone_android, DroidTheme.cyan, 'Active Local Model',
            LocalModelManager.I.activeLocalModel ?? 'None selected'),
          _tile(Icons.storage, DroidTheme.green, 'Downloaded Models',
            '${LocalModelManager.I.downloaded.length} models on device'),
          _tile(Icons.tune, DroidTheme.amber, 'Inference Settings', 'Threads, context length, GPU layers'),
        ]),
        const SizedBox(height: 10),

        // ═══ CHANNELS ═══
        _section('📡 Channels', [
          _chTile('💬', 'WebChat', 'Built-in', true),
          _chTile('✈️', 'Telegram', 'Not connected', false),
          _chTile('📱', 'WhatsApp', 'Not connected', false),
          _chTile('🎮', 'Discord', 'Not connected', false),
          _chTile('💌', 'Signal', 'Not connected', false),
          _chTile('📧', 'Email', 'Not connected', false),
          _chTile('💬', 'SMS', 'Not connected', false),
        ]),
        const SizedBox(height: 10),

        // ═══ AGENT ═══
        _section('🤖 Agent Behavior', [
          _switchTile(Icons.psychology, DroidTheme.accent, 'Long-term Memory', 'Remember across sessions', true),
          _switchTile(Icons.search, DroidTheme.cyan, 'Auto Web Search', 'Search when needed', true),
          _switchTile(Icons.code, DroidTheme.green, 'Code Execution', 'Run code in sandbox', true),
          _switchTile(Icons.auto_fix_high, DroidTheme.amber, 'Auto Tool Use', 'Let agent use tools freely', true),
          _switchTile(Icons.loop, DroidTheme.pink, 'Multi-step Reasoning', 'Allow agent iterations', true),
          _switchTile(Icons.gavel, DroidTheme.red, 'Ask Before Acting', 'Confirm before external actions', false),
          _switchTile(Icons.lightbulb, DroidTheme.cyan, 'Proactive Suggestions', 'Suggest helpful actions', true),
        ]),
        const SizedBox(height: 10),

        // ═══ VOICE ═══
        _section('🎤 Voice & Audio', [
          _switchTile(Icons.mic, DroidTheme.accent, 'Voice Input', 'Speech-to-text', true),
          _switchTile(Icons.volume_up, DroidTheme.cyan, 'Voice Output', 'Text-to-speech', true),
          _tile(Icons.record_voice_over, DroidTheme.green, 'TTS Voice', 'en-US (Default)'),
          _tile(Icons.speed, DroidTheme.amber, 'Speech Rate', '0.5x'),
          _tile(Icons.music_note, DroidTheme.pink, 'TTS Pitch', '1.0'),
          _switchTile(Icons.hearing, DroidTheme.red, 'Always Listening', 'Wake word detection', false),
        ]),
        const SizedBox(height: 10),

        // ═══ PHONE CONTROL ═══
        _section('📱 Phone Control', [
          _switchTile(Icons.phone_android, DroidTheme.accent, 'Phone Control', 'Allow agent to control device', true),
          _switchTile(Icons.location_on, DroidTheme.cyan, 'Location Access', 'GPS for location tools', true),
          _switchTile(Icons.camera, DroidTheme.green, 'Camera Access', 'Take photos & scan QR', true),
          _switchTile(Icons.contacts, DroidTheme.amber, 'Contacts Access', 'Read & manage contacts', true),
          _switchTile(Icons.calendar_today, DroidTheme.pink, 'Calendar Access', 'Read & create events', true),
          _switchTile(Icons.sms, DroidTheme.red, 'SMS Access', 'Send text messages', false),
          _switchTile(Icons.bluetooth, DroidTheme.cyan, 'Bluetooth Control', 'Toggle Bluetooth', true),
          _switchTile(Icons.wifi, DroidTheme.green, 'WiFi Control', 'Toggle WiFi', true),
        ]),
        const SizedBox(height: 10),

        // ═══ NOTIFICATIONS ═══
        _section('🔔 Notifications', [
          _switchTile(Icons.notifications, DroidTheme.accent, 'Push Notifications', 'Agent alerts', true),
          _switchTile(Icons.alarm, DroidTheme.amber, 'Reminder Notifications', 'Scheduled reminders', true),
          _switchTile(Icons.message, DroidTheme.cyan, 'Message Notifications', 'Channel messages', true),
          _switchTile(Icons.do_not_disturb, DroidTheme.red, 'Quiet Hours', 'No notifications 11PM-7AM', false),
        ]),
        const SizedBox(height: 10),

        // ═══ APPEARANCE ═══
        _section('🎨 Appearance', [
          _tile(Icons.palette, DroidTheme.accent, 'Theme', 'Cyberpunk Dark'),
          _tile(Icons.text_fields, DroidTheme.cyan, 'Font Size', '14px'),
          _tile(Icons.font_download, DroidTheme.green, 'Font Family', 'Inter'),
          _tile(Icons.language, DroidTheme.amber, 'Language', 'English'),
          _tile(Icons.animation, DroidTheme.pink, 'Animations', 'Enabled'),
          _tile(Icons.emoji_emotions, DroidTheme.red, 'Emoji Style', 'Native'),
        ]),
        const SizedBox(height: 10),

        // ═══ SECURITY ═══
        _section('🔐 Security & Privacy', [
          _switchTile(Icons.lock, DroidTheme.accent, 'App Lock', 'Require biometric to open', false),
          _switchTile(Icons.shield, DroidTheme.cyan, 'Encrypt Memory', 'AES-256 encryption', false),
          _switchTile(Icons.history, DroidTheme.green, 'Chat History', 'Save conversations', true),
          _switchTile(Icons.privacy_tip, DroidTheme.amber, 'Incognito Mode', 'No history saved', false),
          _tile(Icons.delete_forever, DroidTheme.red, 'Delete All Data', 'Wipe everything'),
          _tile(Icons.download, DroidTheme.cyan, 'Export Data', 'Download your data'),
          _tile(Icons.upload, DroidTheme.green, 'Import Data', 'Restore from backup'),
        ]),
        const SizedBox(height: 10),

        // ═══ STORAGE ═══
        _section('💾 Storage & Data', [
          _tile(Icons.storage, DroidTheme.amber, 'Total Storage', 'Loading...'),
          _tile(Icons.chat, DroidTheme.cyan, 'Conversations', 'Loading...'),
          _tile(Icons.psychology, DroidTheme.accent, 'Memory Entries', 'Loading...'),
          _tile(Icons.download, DroidTheme.green, 'Downloaded Models', '${LocalModelManager.I.downloaded.length}'),
          _tile(Icons.cleaning_services, DroidTheme.red, 'Clear Cache', 'Free up space'),
          _tile(Icons.delete_sweep, DroidTheme.red, 'Clear All Data', 'Factory reset'),
        ]),
        const SizedBox(height: 10),

        // ═══ AUTOMATION ═══
        _section('🔄 Automation', [
          _tile(Icons.schedule, DroidTheme.accent, 'Scheduled Tasks', '${AutomationEngine.I.activeTasks.length} active'),
          _tile(Icons.integration_instructions, DroidTheme.cyan, 'Webhooks', 'Configure webhooks'),
          _tile(Icons.integration_instructions, DroidTheme.green, 'Integrations', 'IFTTT, Zapier, etc.'),
          _tile(Icons.code, DroidTheme.amber, 'Custom Scripts', 'Add custom automation'),
        ]),
        const SizedBox(height: 10),

        // ═══ DEVELOPER ═══
        _section('👨‍💻 Developer', [
          _tile(Icons.bug_report, DroidTheme.amber, 'Debug Mode', 'Off'),
          _tile(Icons.terminal, DroidTheme.cyan, 'Console', 'View agent logs'),
          _tile(Icons.api, DroidTheme.green, 'API Playground', 'Test API calls'),
          _tile(Icons.extension, DroidTheme.accent, 'Plugin Manager', 'Install plugins'),
          _tile(Icons.code, DroidTheme.pink, 'Custom Tools', 'Create your own tools'),
        ]),
        const SizedBox(height: 10),

        // ═══ ABOUT ═══
        _section('ℹ️ About', [
          _tile(Icons.info, DroidTheme.cyan, 'Version', 'DroidClaw v1.0.0 (Build 1)'),
          _tile(Icons.favorite, DroidTheme.pink, 'Inspired by', 'OpenClaw 🐾'),
          _tile(Icons.code, DroidTheme.green, 'Built with', 'Flutter + Dart'),
          _tile(Icons.star, DroidTheme.amber, 'Rate App', '⭐⭐⭐⭐⭐'),
          _tile(Icons.share, DroidTheme.accent, 'Share DroidClaw', 'Tell your friends!'),
          _tile(Icons.description, DroidTheme.cyan, 'Licenses', 'Open source licenses'),
          _tile(Icons.update, DroidTheme.green, 'Check for Updates', 'v1.0.0 (latest)'),
        ]),
        const SizedBox(height: 30),
      ])),
    ));
  }

  Widget _section(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(title, style: TextStyle(color: DroidTheme.txt, fontSize: 13, fontWeight: FontWeight.w700))),
      Container(decoration: BoxDecoration(color: DroidTheme.surface, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DroidTheme.border, width: 0.5)),
        child: Column(children: List.generate(children.length, (i) =>
          Column(children: [if (i > 0) Divider(height: 1, color: DroidTheme.border.withValues(alpha: 0.3), indent: 48), children[i]])))),
    ]).animate().fadeIn(delay: 80.ms);
  }

  Widget _tile(IconData icon, Color color, String title, String sub, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(width: 30, height: 30, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, color: color, size: 15)),
      title: Text(title, style: TextStyle(color: DroidTheme.txt, fontSize: 12, fontWeight: FontWeight.w500)),
      subtitle: Text(sub, style: TextStyle(color: DroidTheme.txt3, fontSize: 10)),
      trailing: Icon(Icons.chevron_right, color: DroidTheme.txt3, size: 16),
      onTap: onTap, dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1));
  }

  Widget _switchTile(IconData icon, Color color, String title, String sub, bool val) {
    return StatefulBuilder(builder: (context, setState) => ListTile(
      leading: Container(width: 30, height: 30, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, color: color, size: 15)),
      title: Text(title, style: TextStyle(color: DroidTheme.txt, fontSize: 12, fontWeight: FontWeight.w500)),
      subtitle: Text(sub, style: TextStyle(color: DroidTheme.txt3, fontSize: 10)),
      trailing: Switch(value: val, onChanged: (v) => setState(() {}), activeColor: DroidTheme.accent),
      dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1)));
  }

  Widget _chTile(String emoji, String name, String status, bool connected) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 18)),
      title: Text(name, style: TextStyle(color: DroidTheme.txt, fontSize: 12, fontWeight: FontWeight.w500)),
      subtitle: Text(status, style: TextStyle(color: connected ? DroidTheme.green : DroidTheme.txt3, fontSize: 10)),
      trailing: Container(width: 6, height: 6, decoration: BoxDecoration(color: connected ? DroidTheme.green : DroidTheme.txt3, shape: BoxShape.circle)),
      dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1));
  }

  void _pickProvider(BuildContext ctx) {
    showModalBottomSheet(context: ctx, backgroundColor: DroidTheme.surface, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(initialChildSize: 0.7, expand: false,
        builder: (_, ctrl) => Column(children: [
          const SizedBox(height: 10),
          Container(width: 34, height: 4, decoration: BoxDecoration(color: DroidTheme.txt3.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.all(14), child: Text('Select Provider 🤖 (${AIProviderManager.I.providers.length} providers)',
            style: TextStyle(color: DroidTheme.txt, fontSize: 16, fontWeight: FontWeight.w700))),
          Expanded(child: ListView.builder(controller: ctrl, padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: AIProviderManager.I.providers.length, itemBuilder: (_, i) {
              final p = AIProviderManager.I.providers[i];
              final active = p.id == AIProviderManager.I.activeProviderId;
              return Container(margin: const EdgeInsets.only(bottom: 4), decoration: BoxDecoration(
                color: active ? DroidTheme.accent.withValues(alpha: 0.1) : DroidTheme.card, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: active ? DroidTheme.accent.withValues(alpha: 0.4) : DroidTheme.border)),
                child: ListTile(
                  leading: Text(p.icon, style: const TextStyle(fontSize: 20)),
                  title: Text(p.name, style: TextStyle(color: active ? DroidTheme.accent : DroidTheme.txt, fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text('${p.models.length} models${p.isLocal ? " • Local" : ""}${p.isCustom ? " • Custom" : ""}',
                    style: TextStyle(color: DroidTheme.txt3, fontSize: 10)),
                  trailing: active ? Icon(Icons.check_circle, color: DroidTheme.accent, size: 16) : null,
                  dense: true,
                  onTap: () { AIProviderManager.I.setActiveProvider(p.id, p.models.first.id); Navigator.pop(ctx); },
                ));
            })),
        ])));
  }

  void _pickModel(BuildContext ctx) {
    final models = AIProviderManager.I.activeProvider.models;
    showModalBottomSheet(context: ctx, backgroundColor: DroidTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 10),
        Container(width: 34, height: 4, decoration: BoxDecoration(color: DroidTheme.txt3.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(14), child: Text('Select Model (${models.length})',
          style: TextStyle(color: DroidTheme.txt, fontSize: 16, fontWeight: FontWeight.w700))),
        ...models.map((m) => ListTile(
          title: Text(m.name, style: TextStyle(color: DroidTheme.txt, fontSize: 13)),
          subtitle: Text('${m.capabilities.join(", ")} • ${m.maxTokens} tokens', style: TextStyle(color: DroidTheme.txt3, fontSize: 10)),
          trailing: m.id == AIProviderManager.I.activeModelId ? Icon(Icons.check_circle, color: DroidTheme.accent, size: 16) : null,
          dense: true,
          onTap: () { AIProviderManager.I.setActiveProvider(AIProviderManager.I.activeProviderId, m.id); Navigator.pop(ctx); },
        )),
        const SizedBox(height: 14),
      ]),
    );
  }

  void _apiKeys(BuildContext ctx) {
    showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: DroidTheme.surface,
      title: Text('API Keys 🔑', style: TextStyle(color: DroidTheme.txt, fontSize: 16)),
      content: SizedBox(width: double.maxFinite, height: 400,
        child: ListView(children: AIProviderManager.I.providers.where((p) => !p.isLocal).map((p) =>
          Padding(padding: const EdgeInsets.only(bottom: 6), child: TextField(
            style: TextStyle(color: DroidTheme.txt, fontSize: 12),
            decoration: InputDecoration(labelText: '${p.icon} ${p.name}',
              labelStyle: TextStyle(color: DroidTheme.txt2, fontSize: 11),
              hintText: 'API key...', hintStyle: TextStyle(color: DroidTheme.txt3, fontSize: 11),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
            obscureText: true,
            onSubmitted: (v) => AIProviderManager.I.setApiKey(p.id, v),
          ))).toList())),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Done', style: TextStyle(color: DroidTheme.accent)))]));
  }

  void _customEndpoint(BuildContext ctx) {
    final ctrl = TextEditingController();
    showDialog(context: ctx, builder: (_) => AlertDialog(backgroundColor: DroidTheme.surface,
      title: Text('Custom Endpoint ⚙️', style: TextStyle(color: DroidTheme.txt)),
      content: TextField(controller: ctrl, style: TextStyle(color: DroidTheme.txt),
        decoration: InputDecoration(hintText: 'http://localhost:11434/v1', hintStyle: TextStyle(color: DroidTheme.txt3))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: DroidTheme.txt3))),
        ElevatedButton(onPressed: () { AIProviderManager.I.setCustomEndpoint(ctrl.text); Navigator.pop(ctx); }, child: const Text('Save')),
      ],
    ));
  }
}
