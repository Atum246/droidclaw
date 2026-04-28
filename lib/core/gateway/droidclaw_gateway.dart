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

/// 🧠 DroidClaw Gateway — The Brain
class DroidClawGateway extends ChangeNotifier {
  static final DroidClawGateway I = DroidClawGateway._();
  DroidClawGateway._();

  bool _ready = false;
  bool _processing = false;
  String _status = 'idle';
  final List<AgentTask> _activeTasks = [];
  final StreamController<AgentEvent> _events = StreamController.broadcast();

  bool get isReady => _ready;
  bool get isProcessing => _processing;
  String get status => _status;
  List<AgentTask> get activeTasks => _activeTasks;
  Stream<AgentEvent> get events => _events.stream;

  Future<void> init() async {
    _status = 'initializing';
    notifyListeners();
    _ready = true;
    _status = 'ready';
    notifyListeners();
  }

  /// Process a user message through the full agent loop
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
      final provider = AIProviderManager.I.activeProvider;
      final model = AIProviderManager.I.activeModel;
      final tools = ToolEngine.I.availableTools;
      final skills = SkillEngine.I.findRelevant(userMessage);
      final memories = await MemoryEngine.I.getRelevantContext(userMessage);

      // Build system prompt
      final sysPrompt = _buildSystemPrompt(memories, skills);

      // Build messages
      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': sysPrompt},
        if (history != null)
          ...history.map((m) => {'role': m.role, 'content': m.content}),
        {'role': 'user', 'content': userMessage},
      ];

      // Agent loop: model → tools → model → done
      String response = '';
      final toolsUsed = <String>[];
      int iterations = 0;
      const maxIterations = 10;

      while (iterations < maxIterations) {
        iterations++;
        
        _events.add(AgentEvent(
          type: 'model_call',
          taskId: task.id,
          data: {'iteration': iterations, 'provider': provider.name},
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
          } catch (e) {
            messages.add({
              'role': 'tool',
              'tool_call_id': tc.id,
              'content': 'Error: $e',
            });
          }
        }
      }

      // Save to memory
      await MemoryEngine.I.addTurn(
        sessionId: sessionId,
        user: userMessage,
        assistant: response,
        tools: toolsUsed,
      );

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

  String _buildSystemPrompt(List<MemoryEntry> memories, List<Skill> skills) {
    final buf = StringBuffer();
    buf.writeln('You are DroidClaw, a powerful AI agent running on Android.');
    buf.writeln('You can execute tools, search the web, manage files, control the phone, automate tasks, and more.');
    buf.writeln('Use emojis naturally. Be helpful, concise, and actionable.');
    buf.writeln();

    if (memories.isNotEmpty) {
      buf.writeln('## Memory Context');
      for (var m in memories.take(10)) {
        buf.writeln('- ${m.key}: ${m.value}');
      }
      buf.writeln();
    }

    if (skills.isNotEmpty) {
      buf.writeln('## Active Skills');
      for (var s in skills) {
        buf.writeln('- ${s.name}: ${s.description}');
      }
      buf.writeln();
    }

    return buf.toString();
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
