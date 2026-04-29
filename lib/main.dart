import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/gateway/droidclaw_gateway.dart';
import 'core/providers/ai_provider_manager.dart';
import 'core/tools/tool_engine.dart';
import 'core/skills/skill_engine.dart';
import 'core/memory/memory_engine.dart';
import 'core/voice/voice_engine.dart';
import 'core/automation/automation_engine.dart';
import 'core/models/local_model_manager.dart';
import 'core/files/file_manager.dart';
import 'core/browser/browser_engine.dart';
import 'core/agents/sub_agent_manager.dart';
import 'core/tools/tool_creator.dart';
import 'core/skills/skill_creator.dart';
import 'core/research/deep_research_engine.dart';
import 'core/heartbeat/heartbeat_engine.dart';
import 'core/streaming/streaming_engine.dart';
import 'core/multimodal/multimodal_engine.dart';
import 'core/workflow/workflow_builder.dart';
import 'ui/theme/droid_theme.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/onboarding_screen.dart';

/// 🤖 DroidClaw — The Ultimate AI Agent for Android
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await MemoryEngine.I.init();
  await AIProviderManager.I.init();
  await SkillEngine.I.init();
  await ToolEngine.I.init();
  await VoiceEngine.I.init();
  await AutomationEngine.I.init();
  await LocalModelManager.I.init();
  await FileManager.I.init();
  // BrowserEngine initializes lazily on first use
  await ToolCreator.I.init();
  await SkillCreator.I.init();
  await HeartbeatEngine.I.init();
  await WorkflowBuilder.I.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF06060A), systemNavigationBarIconBrightness: Brightness.light,
  ));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => DroidClawGateway.I),
    ChangeNotifierProvider(create: (_) => AIProviderManager.I),
    ChangeNotifierProvider(create: (_) => ToolEngine.I),
    ChangeNotifierProvider(create: (_) => SkillEngine.I),
    ChangeNotifierProvider(create: (_) => VoiceEngine.I),
    ChangeNotifierProvider(create: (_) => AutomationEngine.I),
    ChangeNotifierProvider(create: (_) => LocalModelManager.I),
    ChangeNotifierProvider(create: (_) => FileManager.I),
    ChangeNotifierProvider(create: (_) => BrowserEngine.I),
    ChangeNotifierProvider(create: (_) => SubAgentManager.I),
    ChangeNotifierProvider(create: (_) => ToolCreator.I),
    ChangeNotifierProvider(create: (_) => SkillCreator.I),
    ChangeNotifierProvider(create: (_) => DeepResearchEngine.I),
    ChangeNotifierProvider(create: (_) => HeartbeatEngine.I),
    ChangeNotifierProvider(create: (_) => StreamingEngine.I),
    ChangeNotifierProvider(create: (_) => MultiModalEngine.I),
    ChangeNotifierProvider(create: (_) => WorkflowBuilder.I),
  ], child: DroidClawApp(onboardingDone: onboardingDone)));
}

class DroidClawApp extends StatelessWidget {
  final bool onboardingDone;
  const DroidClawApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DroidClaw', debugShowCheckedModeBanner: false,
      theme: DroidTheme.dark(),
      home: onboardingDone ? const HomeScreen() : OnboardingScreen(
        onComplete: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_done', true);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
      ),
    );
  }
}
