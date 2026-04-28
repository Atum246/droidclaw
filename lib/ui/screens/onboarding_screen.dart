import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/droid_theme.dart';

/// 🎉 Onboarding Screen — First-time welcome
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  final _pages = const [
    OnboardPage(
      emoji: '🤖', title: 'Meet DroidClaw',
      subtitle: 'Your personal AI agent that can actually DO things',
      description: 'Not just a chatbot — DroidClaw searches the web, manages files, writes code, automates tasks, and controls your phone.',
      gradient: DroidTheme.grad1,
    ),
    OnboardPage(
      emoji: '🧠', title: '20+ AI Providers',
      subtitle: 'Use any AI model you want',
      description: 'OpenAI, Anthropic, Google, Nvidia, OpenRouter, Mistral, DeepSeek, Groq, and many more. Bring your own API keys or run models locally.',
      gradient: DroidTheme.grad2,
    ),
    OnboardPage(
      emoji: '⚡', title: '110+ Skills Built-in',
      subtitle: 'Ready to help with anything',
      description: 'Code review, writing, translation, math, research, business planning, creative work, and 100+ more specialized skills.',
      gradient: DroidTheme.grad3,
    ),
    OnboardPage(
      emoji: '🔧', title: '50+ Powerful Tools',
      subtitle: 'The agent can actually DO things',
      description: 'File management, web search, code execution, phone control, calendar, messaging, image generation, voice, and more.',
      gradient: DroidTheme.grad4,
    ),
    OnboardPage(
      emoji: '📱', title: 'Download Local Models',
      subtitle: 'Run AI directly on your phone',
      description: 'Download Gemma, Llama, Phi, Qwen, Mistral and more — all optimized for mobile. No internet needed, complete privacy.',
      gradient: DroidTheme.grad1,
    ),
    OnboardPage(
      emoji: '🚀', title: 'Ready to Go!',
      subtitle: 'Let\'s set up your agent',
      description: 'Add your API key for at least one provider, and you\'re ready. DroidClaw will handle the rest!',
      gradient: DroidTheme.grad2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DroidTheme.bg,
      body: SafeArea(child: Column(children: [
        // Skip button
        if (_page < _pages.length - 1)
          Align(alignment: Alignment.topRight,
            child: TextButton(onPressed: () => widget.onComplete(),
              child: Text('Skip', style: TextStyle(color: DroidTheme.txt3, fontSize: 14)))),
        Expanded(child: PageView.builder(
          controller: _pageCtrl,
          itemCount: _pages.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (_, i) => _buildPage(_pages[i]),
        )),
        // Dots
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_pages.length, (i) =>
          AnimatedContainer(duration: 300.ms, width: _page == i ? 24 : 8, height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: _page == i ? DroidTheme.accent : DroidTheme.txt3.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4))))),
        const SizedBox(height: 20),
        // Button
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_page < _pages.length - 1) {
                  _pageCtrl.nextPage(duration: 300.ms, curve: Curves.easeOut);
                } else {
                  widget.onComplete();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DroidTheme.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text(_page == _pages.length - 1 ? 'Get Started 🚀' : 'Next →',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ))),
        const SizedBox(height: 24),
      ])),
    );
  }

  Widget _buildPage(OnboardPage page) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 100, height: 100,
          decoration: BoxDecoration(gradient: page.gradient, borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: DroidTheme.accent.withOpacity(0.2), blurRadius: 30, spreadRadius: 3)]),
          child: Center(child: Text(page.emoji, style: const TextStyle(fontSize: 50))),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 32),
        Text(page.title, textAlign: TextAlign.center,
          style: TextStyle(color: DroidTheme.txt, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        const SizedBox(height: 8),
        Text(page.subtitle, textAlign: TextAlign.center,
          style: TextStyle(color: DroidTheme.accent, fontSize: 16, fontWeight: FontWeight.w600),
        ).animate().fadeIn(delay: 350.ms),
        const SizedBox(height: 16),
        Text(page.description, textAlign: TextAlign.center,
          style: TextStyle(color: DroidTheme.txt2, fontSize: 14, height: 1.6),
        ).animate().fadeIn(delay: 500.ms),
      ]),
    );
  }
}

class OnboardPage {
  final String emoji; final String title; final String subtitle;
  final String description; final LinearGradient gradient;
  const OnboardPage({required this.emoji, required this.title, required this.subtitle,
    required this.description, required this.gradient});
}
