import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/droid_theme.dart';
import 'chat_screen.dart';
import 'skills_screen.dart';
import 'tools_screen.dart';
import 'memory_screen.dart';
import 'settings_screen.dart';
import 'automation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final _screens = const [
    ChatScreen(), SkillsScreen(), ToolsScreen(),
    MemoryScreen(), AutomationScreen(), SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: DroidTheme.surface,
          border: Border(top: BorderSide(color: DroidTheme.border.withOpacity(0.4), width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _nav(0, '💬', 'Chat'),
                _nav(1, '⚡', 'Skills'),
                _nav(2, '🔧', 'Tools'),
                _nav(3, '🧠', 'Memory'),
                _nav(4, '🔄', 'Auto'),
                _nav(5, '⚙️', 'Settings'),
              ],
            ),
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.05),
    );
  }

  Widget _nav(int i, String emoji, String label) {
    final sel = _tab == i;
    return GestureDetector(
      onTap: () => setState(() => _tab = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: sel ? 12 : 8, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? DroidTheme.accent.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: sel ? 18 : 16)),
            if (sel) ...[
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: DroidTheme.accent, fontWeight: FontWeight.w600, fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }
}
