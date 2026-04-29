import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../providers/ai_provider_manager.dart';
import '../tools/tool_engine.dart';
import '../skills/skill_engine.dart';
import '../memory/memory_engine.dart';

/// 🤖 Sub-Agent Manager — Spawn Isolated Task Runners
/// Each sub-agent runs its own reasoning loop with its own context
class SubAgentManager extends ChangeNotifier {
  static final SubAgentManager I = SubAgentManager._();
  SubAgentManager._();

  final Map<String, SubAgent> _agents = {};
  final StreamController<SubAgentEvent> _events = StreamController.broadcast();

  Map<String, SubAgent> get agents => Map.unmodifiable(_agents);
  List<SubAgent> get activeAgents => _agents.values.where((a) => a.status == AgentStatus.running).toList();
  Stream<SubAgentEvent> get events => _events.stream;

  /// Spawn a new sub-agent for a specific task
  Future<SubAgent> spawn({
    required String task,
    String? label,
    String? model,
    AgentPriority priority = AgentPriority.normal,
    Map<String, dynamic>? context,
    int maxIterations = 15,
    Duration? timeout,
  }) async {
    final id = const Uuid().v4();
    final agent = SubAgent(
      id: id,
      label: label ?? 'agent_${id.substring(0, 6)}',
      task: task,
      model: model,
      priority: priority,
      context: context ?? {},
      maxIterations: maxIterations,
      timeout: timeout ?? const Duration(minutes: 5),
      createdAt: DateTime.now(),
    );

    _agents[id] = agent;
    _events.add(SubAgentEvent(type: 'spawned', agentId: id, task: task));
    notifyListeners();

    // Run in background
    _runAgent(agent);
    return agent;
  }

  /// Send a message to a running agent
  Future<void> steer(String agentId, String message) async {
    final agent = _agents[agentId];
    if (agent == null) return;
    agent._pendingSteer = message;
    _events.add(SubAgentEvent(type: 'steered', agentId: agentId, data: message));
  }

  /// Kill a running agent
  Future<void> kill(String agentId) async {
    final agent = _agents[agentId];
    if (agent == null) return;
    agent.status = AgentStatus.killed;
    agent._completer?.complete();
    _events.add(SubAgentEvent(type: 'killed', agentId: agentId));
    notifyListeners();
  }

  /// Get agent status
  SubAgent? getAgent(String id) => _agents[id];

  /// Clean up completed/failed agents
  void cleanup() {
    _agents.removeWhere((_, a) =>
      a.status == AgentStatus.completed ||
      a.status == AgentStatus.failed ||
      a.status == AgentStatus.killed
    );
    notifyListeners();
  }

  Future<void> _runAgent(SubAgent agent) async {
    agent.status = AgentStatus.running;
    agent._completer = Completer();
    notifyListeners();

    try {
      final provider = AIProviderManager.I;
      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content': _buildSubAgentPrompt(agent),
        },
        {'role': 'user', 'content': agent.task},
      ];

      int iterations = 0;
      String response = '';

      while (iterations < agent.maxIterations && agent.status == AgentStatus.running) {
        iterations++;
        agent.currentIteration = iterations;
        agent.statusMessage = '🧠 Thinking (iteration $iterations)...';
        notifyListeners();

        // Check for steering
        if (agent._pendingSteer != null) {
          messages.add({'role': 'user', 'content': agent._pendingSteer!});
          agent._pendingSteer = null;
        }

        try {
          final result = await provider.chat(
            modelId: agent.model ?? provider.activeModelId,
            messages: messages,
            tools: ToolEngine.I.availableTools.map((t) => t.toJsonSchema()).toList(),
          );

          if (result.toolCalls.isEmpty) {
            response = result.content;
            agent.finalResponse = response;
            break;
          }

          // Execute tool calls
          messages.add({
            'role': 'assistant',
            'content': result.content,
            'tool_calls': result.toolCalls.map((tc) => tc.toJson()).toList(),
          });

          for (var tc in result.toolCalls) {
            agent.statusMessage = '⚡ Running: ${tc.name}';
            agent.toolsUsed.add(tc.name);
            notifyListeners();

            try {
              final toolResult = await ToolEngine.I.execute(tc.name, tc.arguments);
              messages.add({
                'role': 'tool',
                'tool_call_id': tc.id,
                'content': toolResult.content,
              });
              agent.toolResults.add({'tool': tc.name, 'result': toolResult.content});
            } catch (e) {
              messages.add({
                'role': 'tool',
                'tool_call_id': tc.id,
                'content': 'Error: $e',
              });
            }
          }
        } catch (e) {
          agent.errors.add('Iteration $iterations: $e');
        }
      }

      if (agent.status == AgentStatus.running) {
        agent.status = AgentStatus.completed;
        agent.completedAt = DateTime.now();
        agent.statusMessage = '✅ Completed';
      }
    } catch (e) {
      agent.status = AgentStatus.failed;
      agent.errors.add('Fatal: $e');
      agent.statusMessage = '❌ Failed: $e';
    }

    agent._completer?.complete();
    _events.add(SubAgentEvent(
      type: 'completed',
      agentId: agent.id,
      data: {'status': agent.status.name, 'response': agent.finalResponse},
    ));
    notifyListeners();
  }

  String _buildSubAgentPrompt(SubAgent agent) {
    final buf = StringBuffer();
    buf.writeln('You are a specialized sub-agent within DroidClaw.');
    buf.writeln('Your task: ${agent.task}');
    buf.writeln('Execute efficiently. Use tools as needed. Report results clearly.');
    buf.writeln('You have access to all DroidClaw tools.');
    if (agent.context.isNotEmpty) {
      buf.writeln('\nContext: ${jsonEncode(agent.context)}');
    }
    return buf.toString();
  }
}

enum AgentStatus { queued, running, completed, failed, killed }
enum AgentPriority { low, normal, high, critical }

class SubAgent {
  final String id;
  final String label;
  final String task;
  final String? model;
  final AgentPriority priority;
  final Map<String, dynamic> context;
  final int maxIterations;
  final Duration timeout;
  final DateTime createdAt;

  AgentStatus status = AgentStatus.queued;
  String? statusMessage;
  int currentIteration = 0;
  String? finalResponse;
  DateTime? completedAt;
  final List<String> toolsUsed = [];
  final List<Map<String, dynamic>> toolResults = [];
  final List<String> errors = [];

  Completer? _completer;
  String? _pendingSteer;

  SubAgent({
    required this.id,
    required this.label,
    required this.task,
    this.model,
    required this.priority,
    required this.context,
    required this.maxIterations,
    required this.timeout,
    required this.createdAt,
  });

  Duration? get duration => completedAt?.difference(createdAt);

  Map<String, dynamic> toJson() => {
    'id': id, 'label': label, 'task': task, 'status': status.name,
    'currentIteration': currentIteration, 'toolsUsed': toolsUsed,
    'finalResponse': finalResponse, 'errors': errors,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };
}

class SubAgentEvent {
  final String type;
  final String agentId;
  final dynamic data;
  final String? task;
  SubAgentEvent({required this.type, required this.agentId, this.data, this.task});
}
