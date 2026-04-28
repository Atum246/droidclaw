import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/droid_theme.dart';
import '../../core/gateway/droidclaw_gateway.dart';
import '../../core/providers/ai_provider_manager.dart';
import '../../core/voice/voice_engine.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <ChatMsg>[];
  bool _loading = false;
  String _sessionId = 'main';

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() { _msgs.add(ChatMsg(text, true)); _loading = true; _ctrl.clear(); });
    _scrollDown();

    try {
      final resp = await DroidClawGateway.I.process(
        userMessage: text, sessionId: _sessionId,
        history: _msgs.map((m) => ChatMessage(role: m.isUser ? 'user' : 'assistant', content: m.text)).toList(),
      );
      setState(() { _msgs.add(ChatMsg(resp.content, false, toolsUsed: resp.toolsUsed)); _loading = false; });
    } catch (e) {
      setState(() { _msgs.add(ChatMsg('❌ $e', false, isError: true)); _loading = false; });
    }
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: 300.ms, curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = AIProviderManager.I;
    return Scaffold(
      backgroundColor: DroidTheme.bg,
      body: SafeArea(
        child: Column(children: [
          _header(provider),
          Expanded(child: _msgs.isEmpty ? _welcome() : _list()),
          _input(provider),
        ]),
      ),
    );
  }

  Widget _header(AIProviderManager p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: BoxDecoration(
        color: DroidTheme.bg,
        border: Border(bottom: BorderSide(color: DroidTheme.border.withOpacity(0.3), width: 0.5)),
      ),
      child: Row(children: [
        Container(width: 34, height: 34,
          decoration: BoxDecoration(gradient: DroidTheme.grad1, borderRadius: BorderRadius.circular(9)),
          child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('DroidClaw', style: TextStyle(color: DroidTheme.txt, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(width: 5),
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(gradient: DroidTheme.grad1, borderRadius: BorderRadius.circular(3)),
              child: const Text('AGENT', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
            ),
          ]),
          Text('${p.activeProvider.icon} ${p.activeModelId}', style: TextStyle(color: DroidTheme.txt3, fontSize: 10)),
        ])),
        _statusDot(),
        const SizedBox(width: 8),
        IconButton(
          icon: Container(padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: DroidTheme.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(7)),
            child: const Icon(Icons.add, color: DroidTheme.accent, size: 18)),
          onPressed: () => setState(() { _msgs.clear(); _sessionId = 'main'; }),
          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
        ),
      ]),
    ).animate().fadeIn();
  }

  Widget _statusDot() {
    return Consumer<DroidClawGateway>(builder: (_, gw, __) {
      final busy = gw.isProcessing;
      return Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: busy ? DroidTheme.amber.withOpacity(0.15) : DroidTheme.green.withOpacity(0.15),
          borderRadius: BorderRadius.circular(5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 5, height: 5, decoration: BoxDecoration(
            color: busy ? DroidTheme.amber : DroidTheme.green, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(busy ? 'Working...' : 'Ready', style: TextStyle(
            color: busy ? DroidTheme.amber : DroidTheme.green, fontSize: 9, fontWeight: FontWeight.w600)),
        ]),
      );
    });
  }

  Widget _welcome() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 68, height: 68,
            decoration: BoxDecoration(gradient: DroidTheme.grad1, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: DroidTheme.accent.withOpacity(0.25), blurRadius: 24, spreadRadius: 2)]),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 34))),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text('What can I help you with?', style: TextStyle(
            color: DroidTheme.txt, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text('I\'m your AI agent. I can search, code, manage files,\nautomate tasks, control your phone, and much more.',
            textAlign: TextAlign.center,
            style: TextStyle(color: DroidTheme.txt2, fontSize: 13, height: 1.6),
          ).animate().fadeIn(delay: 350.ms),
          const SizedBox(height: 32),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
            _suggestion('🔍', 'Search the web'),
            _suggestion('💻', 'Write Python code'),
            _suggestion('📧', 'Draft an email'),
            _suggestion('⏰', 'Set a reminder'),
            _suggestion('📁', 'Manage my files'),
            _suggestion('🧠', 'Remember this'),
            _suggestion('📊', 'Analyze data'),
            _suggestion('🌍', 'Translate text'),
          ]).animate().fadeIn(delay: 500.ms).slideY(begin: 0.15),
        ]),
      ),
    );
  }

  Widget _suggestion(String emoji, String text) {
    return GestureDetector(
      onTap: () { _ctrl.text = text; _send(); },
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(color: DroidTheme.surface, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DroidTheme.border, width: 0.5)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: DroidTheme.txt, fontSize: 13)),
        ]),
      ),
    );
  }

  Widget _list() {
    return ListView.builder(controller: _scroll, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: _msgs.length + (_loading ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == _msgs.length) return _typing();
        return _bubble(_msgs[i], i);
      },
    );
  }

  Widget _bubble(ChatMsg m, int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: m.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!m.isUser) ...[
            Container(width: 26, height: 26,
              decoration: BoxDecoration(gradient: DroidTheme.grad1, borderRadius: BorderRadius.circular(7)),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 13))),
            ),
            const SizedBox(width: 7),
          ],
          Flexible(child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: m.isUser ? DroidTheme.accent : m.isError ? DroidTheme.red.withOpacity(0.2) : DroidTheme.card,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14), topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(m.isUser ? 14 : 4), bottomRight: Radius.circular(m.isUser ? 4 : 14)),
              border: m.isUser ? null : Border.all(color: DroidTheme.border.withOpacity(0.3), width: 0.5),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (m.toolsUsed != null && m.toolsUsed!.isNotEmpty) ...[
                Wrap(spacing: 4, children: m.toolsUsed!.map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: DroidTheme.cyan.withOpacity(0.12), borderRadius: BorderRadius.circular(3)),
                  child: Text('🔧 $t', style: TextStyle(color: DroidTheme.cyan, fontSize: 9)),
                )).toList()),
                const SizedBox(height: 5),
              ],
              Text(m.text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
            ]),
          )),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.04);
  }

  Widget _typing() {
    return Padding(padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: DroidTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('⚡', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            _dot(0), const SizedBox(width: 3), _dot(1), const SizedBox(width: 3), _dot(2),
          ]),
        ),
      ]),
    ).animate().fadeIn();
  }

  Widget _dot(int i) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.3, end: 1), duration: Duration(milliseconds: 400 + i * 100),
    builder: (_, v, __) => Container(width: 5, height: 5,
      decoration: BoxDecoration(color: DroidTheme.accent.withOpacity(v), shape: BoxShape.circle)),
  );

  Widget _input(AIProviderManager p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(color: DroidTheme.bg,
        border: Border(top: BorderSide(color: DroidTheme.border.withOpacity(0.3), width: 0.5))),
      child: SafeArea(child: Row(children: [
        // Voice button
        Consumer<VoiceEngine>(builder: (_, voice, __) {
          return GestureDetector(
            onTap: () async {
              if (voice.isListening) {
                await voice.stopListening();
                if (voice.lastWords.isNotEmpty) { _ctrl.text = voice.lastWords; }
              } else {
                await voice.startListening(onResult: (words) { _ctrl.text = words; });
              }
            },
            child: Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: voice.isListening ? DroidTheme.red.withOpacity(0.2) : DroidTheme.surface,
                borderRadius: BorderRadius.circular(9)),
              child: Icon(voice.isListening ? Icons.stop : Icons.mic,
                color: voice.isListening ? DroidTheme.red : DroidTheme.txt3, size: 18)),
          );
        }),
        const SizedBox(width: 8),
        Expanded(child: Container(
          decoration: BoxDecoration(color: DroidTheme.surface, borderRadius: BorderRadius.circular(11),
            border: Border.all(color: DroidTheme.border, width: 0.5)),
          child: Row(children: [
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _ctrl, style: TextStyle(color: DroidTheme.txt, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Ask me anything...', hintStyle: TextStyle(color: DroidTheme.txt3, fontSize: 14),
                border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 10)),
              onSubmitted: (_) => _send())),
            IconButton(icon: Text('📎', style: TextStyle(fontSize: 16)),
              onPressed: () => _showAttach(), padding: const EdgeInsets.all(4), constraints: const BoxConstraints()),
          ]),
        )),
        const SizedBox(width: 8),
        GestureDetector(onTap: _send, child: Container(padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: _ctrl.text.isNotEmpty ? DroidTheme.grad1 : null,
            color: _ctrl.text.isEmpty ? DroidTheme.surface : null,
            borderRadius: BorderRadius.circular(9)),
          child: Icon(Icons.arrow_upward, color: _ctrl.text.isNotEmpty ? Colors.white : DroidTheme.txt3, size: 18)),
        ),
      ])),
    ).animate().fadeIn().slideY(begin: 0.04);
  }

  void _showAttach() {
    showModalBottomSheet(context: context, backgroundColor: DroidTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Attach Content 📎', style: TextStyle(color: DroidTheme.txt, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _attachOpt('📸', 'Photo'), _attachOpt('📷', 'Camera'),
          _attachOpt('📄', 'File'), _attachOpt('🎤', 'Voice'),
        ]),
        const SizedBox(height: 12),
      ])),
    );
  }

  Widget _attachOpt(String emoji, String label) {
    return GestureDetector(onTap: () => Navigator.pop(context),
      child: Column(children: [
        Container(width: 50, height: 50,
          decoration: BoxDecoration(color: DroidTheme.card, borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24)))),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: DroidTheme.txt2, fontSize: 11)),
      ]),
    );
  }
}

class ChatMsg {
  final String text;
  final bool isUser;
  final bool isError;
  final List<String>? toolsUsed;
  ChatMsg(this.text, this.isUser, {this.isError = false, this.toolsUsed});
}
