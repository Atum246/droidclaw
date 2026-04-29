import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../providers/ai_provider_manager.dart';
import '../tools/tool_engine.dart';
import '../skills/skill_engine.dart';
import '../memory/memory_engine.dart';
import '../search/web_search_engine.dart';
import '../automation/automation_engine.dart';
import '../agents/sub_agent_manager.dart';
import '../tools/tool_creator.dart';
import '../skills/skill_creator.dart';
import '../research/deep_research_engine.dart';

/// 🧠 DroidClaw Gateway — The Autonomous Brain
/// Full agent loop with self-healing, auto-creation, and sub-agent spawning
class DroidClawGateway extends ChangeNotifier {
  static final DroidClawGateway I = DroidClawGateway._();
  DroidClawGateway._();

  bool _ready = false;
  bool _processing = false;
  String _status = 'idle';
  bool _onboardingComplete = false;
  Map<String, dynamic> _userProfile = {};
  final List<AgentTask> _activeTasks = [];
  final StreamController<AgentEvent> _events = StreamController.broadcast();

  bool get isReady => _ready;
  bool get isProcessing => _processing;
  String get status => _status;
  bool get onboardingComplete => _onboardingComplete;
  Map<String, dynamic> get userProfile => Map.unmodifiable(_userProfile);
  List<AgentTask> get activeTasks => _activeTasks;
  Stream<AgentEvent> get events => _events.stream;

  Future<void> init() async {
    _status = 'initializing';
    notifyListeners();

    // Load user profile from memory
    final profile = await MemoryEngine.I.recall('user_profile');
    if (profile != null) {
      try { _userProfile = jsonDecode(profile); } catch (_) {}
      _onboardingComplete = _userProfile['onboarding_complete'] == true;
    }

    _ready = true;
    _status = 'ready';
    notifyListeners();
  }

  /// Process a user message through the full autonomous agent loop
  Future<AgentResponse> process({
    required String userMessage,
    required String sessionId,
    List<ChatMessage>? history,
  }) async {
    _processing = true;
    _status = 'processing';
    notifyListeners();

    final task = AgentTask(
      id: const Uuid().v4(),
      input: userMessage,
      startedAt: DateTime.now(),
    );
    _activeTasks.add(task);
    _events.add(AgentEvent(type: 'task_started', taskId: task.id));

    try {
      final provider = AIProviderManager.I;
      final model = AIProviderManager.I.activeModelId;
      final tools = ToolEngine.I.availableTools;
      final skills = SkillEngine.I.findRelevant(userMessage);
      final memories = await MemoryEngine.I.getRelevantContext(userMessage);

      // Build enhanced system prompt
      final sysPrompt = _buildSystemPrompt(memories, skills, userMessage);

      // Build messages
      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': sysPrompt},
        if (history != null)
          ...history.map((m) => {'role': m.role, 'content': m.content}),
        {'role': 'user', 'content': userMessage},
      ];

      // Agent loop: model → tools → model → done (with self-healing)
      String response = '';
      final toolsUsed = <String>[];
      int iterations = 0;
      const maxIterations = 15; // Increased for complex tasks
      bool toolNotFound = false;
      String? lastToolError;

      while (iterations < maxIterations) {
        iterations++;

        _events.add(AgentEvent(
          type: 'model_call',
          taskId: task.id,
          data: {'iteration': iterations, 'provider': provider.activeProvider.name},
        ));

        // Call the model
        final result = await provider.chat(
          modelId: model,
          messages: messages,
          tools: tools.map((t) => t.toJsonSchema()).toList(),
        );

        if (result.toolCalls.isEmpty) {
          response = result.content;
          break;
        }

        // Execute tool calls
        messages.add({
          'role': 'assistant',
          'content': result.content,
          'tool_calls': result.toolCalls.map((tc) => tc.toJson()).toList(),
        });

        for (var tc in result.toolCalls) {
          task.currentStep = '⚡ Running: ${tc.name}';
          notifyListeners();

          _events.add(AgentEvent(
            type: 'tool_call',
            taskId: task.id,
            data: {'tool': tc.name, 'params': tc.arguments},
          ));

          try {
            final toolResult = await ToolEngine.I.execute(tc.name, tc.arguments);
            toolsUsed.add(tc.name);

            messages.add({
              'role': 'tool',
              'tool_call_id': tc.id,
              'content': toolResult.content,
            });

            // If tool returned error, log it
            if (toolResult.isError) {
              lastToolError = toolResult.content;
            }
          } catch (e) {
            // Tool doesn't exist or crashed — try to auto-create it
            if (e.toString().contains('not found') || e.toString().contains('not exist')) {
              toolNotFound = true;
              task.currentStep = '🔧 Creating tool: ${tc.name}...';
              notifyListeners();

              try {
                final createdTool = await ToolCreator.I.autoCreateTool(
                  'I need a tool called ${tc.name} that does: ${tc.arguments}',
                  context: 'Original request: $userMessage',
                );

                if (createdTool != null) {
                  toolsUsed.add(tc.name);
                  // Retry with created tool
                  final retryResult = await ToolEngine.I.execute(tc.name, tc.arguments);
                  messages.add({
                    'role': 'tool',
                    'tool_call_id': tc.id,
                    'content': retryResult.content,
                  });
                } else {
                  messages.add({
                    'role': 'tool',
                    'tool_call_id': tc.id,
                    'content': 'Error: Tool ${tc.name} not available. Suggesting alternative approach.',
                  });
                }
              } catch (createError) {
                messages.add({
                  'role': 'tool',
                  'tool_call_id': tc.id,
                  'content': 'Error: $e. Could not auto-create tool.',
                });
              }
            } else {
              messages.add({
                'role': 'tool',
                'tool_call_id': tc.id,
                'content': 'Error: $e',
              });
            }
          }
        }
      }

      // Check if we should spawn sub-agents for follow-up tasks
      if (_shouldSpawnSubAgent(userMessage, response)) {
        _events.add(AgentEvent(
          type: 'sub_agent_suggested',
          taskId: task.id,
          data: {'response': response},
        ));
      }

      // Save to memory
      await MemoryEngine.I.addTurn(
        sessionId: sessionId,
        user: userMessage,
        assistant: response,
        tools: toolsUsed,
      );

      // Auto-learn: if this was a new type of task, create a skill
      if (toolsUsed.isEmpty && response.isNotEmpty) {
        _autoCreateSkillIfNeeded(userMessage, response);
      }

      _activeTasks.remove(task);
      _processing = false;
      _status = 'ready';
      notifyListeners();

      return AgentResponse(
        content: response,
        toolsUsed: toolsUsed,
        steps: iterations,
        duration: DateTime.now().difference(task.startedAt),
      );
    } catch (e) {
      _activeTasks.remove(task);
      _processing = false;
      _status = 'error';
      notifyListeners();
      rethrow;
    }
  }

  String _buildSystemPrompt(List<MemoryEntry> memories, List<Skill> skills, String userMessage) {
    final buf = StringBuffer();
    buf.writeln('You are DroidClaw, a powerful autonomous AI agent running on Android.');
    buf.writeln('You are NOT just a chat app — you are a full agent that ACTS.');
    buf.writeln('');
    buf.writeln('## Core Capabilities');
    buf.writeln('- Execute ANY tool to accomplish tasks');
    buf.writeln('- Spawn sub-agents for parallel/complex tasks');
    buf.writeln('- Auto-create new tools and skills when needed');
    buf.writeln('- Deep research with multi-step investigation');
    buf.writeln('- Browser automation — control web pages');
    buf.writeln('- Phone control — calls, SMS, apps, settings');
    buf.writeln('- Remote control — SSH into devices');
    buf.writeln('- File management — read, write, share any file');
    buf.writeln('- Automation — cron jobs, reminders, workflows');
    buf.writeln('- Social media posting, market research, content creation');
    buf.writeln('');
    buf.writeln('## Behavior Rules');
    buf.writeln('- EXECUTE first, explain later. You are an agent, not a chatbot.');
    buf.writeln('- If you don\'t have a tool for something, use the tool_creator or skill_creator.');
    buf.writeln('- For complex tasks, suggest spawning sub-agents.');
    buf.writeln('- For research tasks, use deep_research tool.');
    buf.writeln('- Use emojis naturally in responses.');
    buf.writeln('- Be concise but thorough.');
    buf.writeln('- When a tool fails, try alternative approaches before giving up.');

    if (_userProfile.isNotEmpty) {
      buf.writeln('\n## User Profile');
      buf.writeln('Name: ${_userProfile['name'] ?? 'User'}');
      buf.writeln('Timezone: ${_userProfile['timezone'] ?? 'Unknown'}');
      if (_userProfile['preferences'] != null) {
        buf.writeln('Preferences: ${_userProfile['preferences']}');
      }
    }

    if (memories.isNotEmpty) {
      buf.writeln('\n## Memory Context');
      for (var m in memories.take(10)) {
        buf.writeln('- ${m.key}: ${m.value}');
      }
    }

    if (skills.isNotEmpty) {
      buf.writeln('\n## Active Skills');
      for (var s in skills) {
        buf.writeln('- ${s.name}: ${s.description}');
      }
    }

    // Add dynamic tools info
    final dynamicTools = ToolCreator.I.createdTools;
    if (dynamicTools.isNotEmpty) {
      buf.writeln('\n## Auto-Created Tools');
      dynamicTools.forEach((name, tool) {
        buf.writeln('- $name: ${tool.description}');
      });
    }

    return buf.toString();
  }

  bool _shouldSpawnSubAgent(String userMessage, String response) {
    final lower = userMessage.toLowerCase();
    return lower.contains('research') ||
           lower.contains('analyze') ||
           lower.contains('compare') ||
           lower.contains('build') ||
           lower.contains('create') && lower.contains('project') ||
           lower.contains('automate') ||
           lower.contains('workflow');
  }

  Future<void> _autoCreateSkillIfNeeded(String task, String response) async {
    try {
      await SkillCreator.I.autoCreateSkill(task, context: response);
    } catch (_) {}
  }

  // ═══════════════════════════════════════════
  // 🎯 ONBOARDING — Like OpenClaw's First Run
  // ═══════════════════════════════════════════

  /// Process onboarding conversation
  Future<OnboardingResponse> processOnboarding(String message, List<ChatMessage> history) async {
    final provider = AIProviderManager.I;

    final onboardingPrompt = '''
You are DroidClaw, an AI agent meeting your user for the first time.

Current conversation:
${history.map((m) => '${m.role}: ${m.content}').join('\n')}
user: $message

Based on what the user has told you, extract their info and respond warmly.

Respond in JSON:
{
  "response": "your conversational reply",
  "profile": {
    "name": "extracted name (null if not mentioned)",
    "preferred_name": "what to call them (null if not mentioned)",
    "timezone": "detected timezone (null if not mentioned)",
    "interests": ["list", "of", "interests"],
    "preferences": "any preferences mentioned"
  },
  "onboardingComplete": false,
  "nextQuestion": "what to ask next (name, timezone, interests, etc.)"
}

Guidelines:
- Be warm, friendly, and use emojis
- Ask one question at a time
- If user gave their name, ask about timezone next
- If timezone known, ask about interests
- If all basic info gathered, set onboardingComplete to true
- Adapt to user's style (formal/casual)
''';

    try {
      final result = await provider.chat(
        modelId: provider.activeModelId,
        messages: [
          {'role': 'system', 'content': 'You are DroidClaw onboarding. Respond only in valid JSON.'},
          {'role': 'user', 'content': onboardingPrompt},
        ],
        tools: [],
      );

      final json = jsonDecode(_extractJson(result.content));
      final profile = Map<String, dynamic>.from(json['profile'] ?? {});

      // Merge profile
      _userProfile.addAll(profile);

      if (json['onboardingComplete'] == true) {
        _userProfile['onboarding_complete'] = true;
        _onboardingComplete = true;
        await MemoryEngine.I.saveMemory('user_profile', jsonEncode(_userProfile), category: 'system');
      } else {
        await MemoryEngine.I.saveMemory('user_profile', jsonEncode(_userProfile), category: 'system');
      }

      notifyListeners();

      return OnboardingResponse(
        response: json['response'] ?? '👋 Hey there!',
        profile: profile,
        isComplete: json['onboardingComplete'] == true,
        nextQuestion: json['nextQuestion'],
      );
    } catch (e) {
      return OnboardingResponse(
        response: '👋 Hey! I\'m DroidClaw, your AI agent. What should I call you?',
        profile: {},
        isComplete: false,
        nextQuestion: 'What\'s your name?',
      );
    }
  }

  String _extractJson(String text) {
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    return jsonMatch?.group(0) ?? '{}';
  }

  // ═══════════════════════════════════════════
  // 🤖 SUB-AGENT SPAWNING
  // ═══════════════════════════════════════════

  /// Spawn a sub-agent for complex tasks
  Future<SubAgent> spawnAgent({
    required String task,
    String? label,
    String? model,
    Map<String, dynamic>? context,
  }) async {
    return await SubAgentManager.I.spawn(
      task: task,
      label: label,
      model: model,
      context: context,
    );
  }

  /// Conduct deep research
  Future<ResearchProject> deepResearch({
    required String topic,
    int depth = 3,
    String? focus,
  }) async {
    return await DeepResearchEngine.I.research(
      topic: topic,
      depth: depth,
      specificFocus: focus,
    );
  }
}

class AgentResponse {
  final String content;
  final List<String> toolsUsed;
  final int steps;
  final Duration duration;
  AgentResponse({required this.content, required this.toolsUsed, required this.steps, required this.duration});
}

class AgentTask {
  final String id;
  final String input;
  final DateTime startedAt;
  String? currentStep;
  AgentTask({required this.id, required this.input, required this.startedAt, this.currentStep});
}

class AgentEvent {
  final String type;
  final String? taskId;
  final Map<String, dynamic>? data;
  AgentEvent({required this.type, this.taskId, this.data});
}

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final List<String>? toolCalls;
  final String? modelUsed;
  final bool isStreaming;

  ChatMessage({
    String? id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.toolCalls,
    this.modelUsed,
    this.isStreaming = false,
  }) : id = id ?? const Uuid().v4(), timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({String? content, bool? isStreaming}) {
    return ChatMessage(
      id: id, role: role, content: content ?? this.content,
      timestamp: timestamp, toolCalls: toolCalls,
      modelUsed: modelUsed, isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

class OnboardingResponse {
  final String response;
  final Map<String, dynamic> profile;
  final bool isComplete;
  final String? nextQuestion;

  OnboardingResponse({
    required this.response,
    required this.profile,
    required this.isComplete,
    this.nextQuestion,
  });
}
