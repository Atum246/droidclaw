import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/droid_theme.dart';
import '../../core/gateway/droidclaw_gateway.dart';

/// 🎉 Onboarding Screen — First Run Experience
/// Conversational setup like OpenClaw: name, timezone, preferences
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <_OnboardMsg>[];
  bool _loading = false;
  bool _gettingLocation = false;
  int _step = 0; // 0=welcome, 1=name, 2=timezone, 3=interests, 4=done

  @override
  void initState() {
    super.initState();
    _startOnboarding();
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _startOnboarding() {
    setState(() {
      _msgs.add(_OnboardMsg(
        '🤖 Hey! I just came online. I\'m DroidClaw — your personal AI agent.\n\n'
        'Not just a chatbot — I can actually DO things on your phone, browse the web, '
        'automate tasks, control devices, and even create new tools on the fly.\n\n'
        'First things first — what\'s your name? 😊',
        false,
      ));
      _step = 1;
    });
  }

  void _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _loading) return;
    setState(() { _msgs.add(_OnboardMsg(text, true)); _loading = true; _ctrl.clear(); });
    _scrollDown();

    try {
      final history = _msgs.map((m) => ChatMessage(
        role: m.isUser ? 'user' : 'assistant',
        content: m.text,
      )).toList();

      final response = await DroidClawGateway.I.processOnboarding(text, history);

      setState(() {
        _msgs.add(_OnboardMsg(response.response, false));

        if (response.profile['name'] != null) _step = 2;
        if (response.profile['timezone'] != null) _step = 3;
        if (response.profile['interests'] != null && (response.profile['interests'] as List).isNotEmpty) _step = 4;
        if (response.isComplete) _step = 5;
      });

      // If we got their name, offer to detect timezone
      if (response.profile['name'] != null && _step == 2) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _offerTimezoneDetection(response.profile['name']);
        });
      }

      // If onboarding complete, wrap up
      if (response.isComplete) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) _finishOnboarding();
        });
      }

      _loading = false;
    } catch (e) {
      setState(() {
        _msgs.add(_OnboardMsg('😅 Oops, had a hiccup. Let\'s try again — what were you saying?', false));
        _loading = false;
      });
    }
    _scrollDown();
  }

  void _offerTimezoneDetection(String name) {
    setState(() {
      _msgs.add(_OnboardMsg(
        'Nice to meet you, $name! 🎉\n\n'
        'Should I access your phone\'s timezone to set things up correctly? '
        'This helps me schedule reminders and automations at the right times. ⏰\n\n'
        'Just say "yes" or tell me your timezone manually (like "GMT+8" or "EST").',
        false,
      ));
    });
    _scrollDown();
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    setState(() {
      _msgs.add(_OnboardMsg(
        '🚀 All set! Here\'s what I can do:\n\n'
        '🔧 **80+ Tools** — phone control, files, web, code, and more\n'
        '⚡ **110+ Skills** — writing, analysis, research, creativity\n'
        '🌐 **Browser Automation** — control any website\n'
        '🤖 **Sub-Agents** — spawn parallel workers for complex tasks\n'
        '🔬 **Deep Research** — multi-step investigation on any topic\n'
        '🔧 **Auto-Create Tools** — if I don\'t have a tool, I\'ll build one\n'
        '⏰ **Automation** — cron jobs, reminders, workflows\n'
        '📱 **Full Phone Control** — calls, SMS, apps, settings\n\n'
        'Let\'s get started! What do you want to do? 💪',
        false,
      ));
    });
    _scrollDown();

    // Auto-complete after showing summary
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) widget.onComplete();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.animateTo(
        _scroll.position.maxScrollExtent, duration: 300.ms, curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DroidTheme.bg,
      body: SafeArea(
        child: Column(children: [
          _header(),
          Expanded(child: _msgList()),
          _quickActions(),
          _input(),
        ]),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: DroidTheme.grad1,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: DroidTheme.accent.withOpacity(0.3), blurRadius: 12, spreadRadius: 1)],
          ),
          child: const Center(child: Text('🤖', style: TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DroidClaw Setup', style: TextStyle(
            color: DroidTheme.txt, fontSize: 18, fontWeight: FontWeight.w800)),
          Text('Let\'s get you started', style: TextStyle(
            color: DroidTheme.txt3, fontSize: 12)),
        ])),
        _stepIndicator(),
      ]),
    ).animate().fadeIn();
  }

  Widget _stepIndicator() {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) {
      final done = i < _step;
      final current = i == _step - 1;
      return Container(
        width: current ? 16 : 6, height: 6,
        margin: const EdgeInsets.only(left: 3),
        decoration: BoxDecoration(
          color: done ? DroidTheme.accent : DroidTheme.border,
          borderRadius: BorderRadius.circular(3),
        ),
      );
    }));
  }

  Widget _msgList() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _msgs.length + (_loading ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == _msgs.length) return _typing();
        return _bubble(_msgs[i]);
      },
    );
  }

  Widget _bubble(_OnboardMsg m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: m.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!m.isUser) ...[
            Container(width: 30, height: 30,
              decoration: BoxDecoration(gradient: DroidTheme.grad1, borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 15))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: m.isUser ? DroidTheme.accent : DroidTheme.card,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(m.isUser ? 16 : 4), bottomRight: Radius.circular(m.isUser ? 4 : 16)),
              border: m.isUser ? null : Border.all(color: DroidTheme.border.withOpacity(0.3), width: 0.5),
            ),
            child: Text(m.text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6)),
          )),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.04);
  }

  Widget _typing() {
    return Padding(padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: DroidTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('⚡', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
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

  Widget _quickActions() {
    if (_step <= 1) return const SizedBox.shrink();
    final actions = <String>[];
    if (_step == 2) actions.addAll(['Yes, detect my timezone', 'I\'m in GMT+8', 'I\'m in EST', 'I\'m in PST']);
    if (_step == 3) actions.addAll(['Coding & tech', 'Writing & content', 'Business & finance', 'Research & learning']);
    if (_step >= 4) actions.addAll(['Show me what you can do', 'Start with research', 'Automate something']);

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () { _ctrl.text = actions[i]; _send(); },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: DroidTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DroidTheme.border, width: 0.5),
            ),
            child: Text(actions[i], style: TextStyle(color: DroidTheme.txt, fontSize: 12)),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _input() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: BoxDecoration(
        color: DroidTheme.bg,
        border: Border(top: BorderSide(color: DroidTheme.border.withOpacity(0.3), width: 0.5)),
      ),
      child: SafeArea(child: Row(children: [
        Expanded(child: Container(
          decoration: BoxDecoration(
            color: DroidTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DroidTheme.border, width: 0.5),
          ),
          child: Row(children: [
            const SizedBox(width: 14),
            Expanded(child: TextField(
              controller: _ctrl,
              style: TextStyle(color: DroidTheme.txt, fontSize: 14),
              decoration: InputDecoration(
                hintText: _getHint(),
                hintStyle: TextStyle(color: DroidTheme.txt3, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (_) => _send(),
            )),
          ]),
        )),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _send,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: DroidTheme.grad1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
          ),
        ),
      ])),
    ).animate().fadeIn().slideY(begin: 0.05);
  }

  String _getHint() {
    switch (_step) {
      case 1: return 'What\'s your name?';
      case 2: return 'Your timezone...';
      case 3: return 'Your interests...';
      default: return 'Type anything...';
    }
  }
}

class _OnboardMsg {
  final String text;
  final bool isUser;
  _OnboardMsg(this.text, this.isUser);
}
