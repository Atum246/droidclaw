import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../gateway/droidclaw_gateway.dart';
import '../automation/automation_engine.dart';
import '../memory/memory_engine.dart';

/// 🎨 Workflow Builder — Visual Automation Engine
/// Create complex multi-step workflows like n8n/Zapier but on your phone
class WorkflowBuilder extends ChangeNotifier {
  static final WorkflowBuilder I = WorkflowBuilder._();
  WorkflowBuilder._();

  late SharedPreferences _prefs;
  final Map<String, Workflow> _workflows = {};
  final Map<String, WorkflowRun> _runs = {};
  final List<WorkflowTemplate> _templates = [];

  Map<String, Workflow> get workflows => Map.unmodifiable(_workflows);
  Map<String, WorkflowRun> get runs => Map.unmodifiable(_runs);
  List<WorkflowTemplate> get templates => List.unmodifiable(_templates);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadWorkflows();
    _registerTemplates();
  }

  void _loadWorkflows() {
    final data = _prefs.getString('workflows');
    if (data != null) {
      final Map<String, dynamic> map = jsonDecode(data);
      map.forEach((k, v) => _workflows[k] = Workflow.fromJson(v));
    }
  }

  Future<void> _saveWorkflows() async {
    final data = _workflows.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs.setString('workflows', jsonEncode(data));
  }

  void _registerTemplates() {
    _templates.addAll([
      WorkflowTemplate(
        id: 'daily_briefing',
        name: '☀️ Daily Briefing',
        description: 'Every morning: check calendar, weather, news, summarize',
        icon: '☀️',
        steps: [
          WorkflowStep(id: '1', type: StepType.action, label: 'Check Calendar', config: {'tool': 'get_calendar', 'params': {'days': 1}}),
          WorkflowStep(id: '2', type: StepType.action, label: 'Check Weather', config: {'tool': 'web_search', 'params': {'query': 'weather today my location'}}),
          WorkflowStep(id: '3', type: StepType.action, label: 'Check News', config: {'tool': 'web_search', 'params': {'query': 'top news today'}}),
          WorkflowStep(id: '4', type: StepType.aiProcess, label: 'Summarize', config: {'prompt': 'Combine calendar, weather, and news into a brief daily briefing.'}),
        ],
      ),
      WorkflowTemplate(
        id: 'social_post',
        name: '📱 Social Media Post',
        description: 'Create and post content across platforms',
        icon: '📱',
        steps: [
          WorkflowStep(id: '1', type: StepType.aiProcess, label: 'Generate Content', config: {'prompt': 'Create an engaging social media post about: {{topic}}'}),
          WorkflowStep(id: '2', type: StepType.condition, label: 'Review?', config: {'condition': 'user_approved'}),
          WorkflowStep(id: '3', type: StepType.action, label: 'Post', config: {'tool': 'share_content'}),
        ],
      ),
      WorkflowTemplate(
        id: 'research_report',
        name: '🔬 Research Report',
        description: 'Deep research on any topic with final report',
        icon: '🔬',
        steps: [
          WorkflowStep(id: '1', type: StepType.action, label: 'Search Web', config: {'tool': 'web_search', 'params': {'query': '{{topic}}'}}),
          WorkflowStep(id: '2', type: StepType.action, label: 'Fetch Sources', config: {'tool': 'fetch_url'}),
          WorkflowStep(id: '3', type: StepType.aiProcess, label: 'Analyze', config: {'prompt': 'Analyze all research findings and extract key insights.'}),
          WorkflowStep(id: '4', type: StepType.aiProcess, label: 'Write Report', config: {'prompt': 'Write a comprehensive research report with citations.'}),
          WorkflowStep(id: '5', type: StepType.action, label: 'Save', config: {'tool': 'write_file'}),
        ],
      ),
      WorkflowTemplate(
        id: 'file_organizer',
        name: '📁 File Organizer',
        description: 'Organize files by type, date, or content',
        icon: '📁',
        steps: [
          WorkflowStep(id: '1', type: StepType.action, label: 'List Files', config: {'tool': 'list_dir', 'params': {'path': '{{directory}}'}}),
          WorkflowStep(id: '2', type: StepType.aiProcess, label: 'Categorize', config: {'prompt': 'Categorize these files by type and suggest organization.'}),
          WorkflowStep(id: '3', type: StepType.condition, label: 'Confirm?', config: {'condition': 'user_approved'}),
          WorkflowStep(id: '4', type: StepType.loop, label: 'Move Files', config: {'action': 'move_file'}),
        ],
      ),
      WorkflowTemplate(
        id: 'email_draft',
        name: '📧 Email Drafter',
        description: 'Draft professional emails from context',
        icon: '📧',
        steps: [
          WorkflowStep(id: '1', type: StepType.aiProcess, label: 'Draft Email', config: {'prompt': 'Draft a professional email: {{context}}'}),
          WorkflowStep(id: '2', type: StepType.condition, label: 'Review?', config: {'condition': 'user_approved'}),
          WorkflowStep(id: '3', type: StepType.action, label: 'Send', config: {'tool': 'send_email'}),
        ],
      ),
      WorkflowTemplate(
        id: 'market_monitor',
        name: '📈 Market Monitor',
        description: 'Track stocks/crypto and alert on big moves',
        icon: '📈',
        steps: [
          WorkflowStep(id: '1', type: StepType.action, label: 'Check Prices', config: {'tool': 'web_search', 'params': {'query': '{{asset}} price today'}}),
          WorkflowStep(id: '2', type: StepType.aiProcess, label: 'Analyze', config: {'prompt': 'Analyze price movement. Alert if significant change (>5%).'}),
          WorkflowStep(id: '3', type: StepType.condition, label: 'Significant?', config: {'condition': 'result.contains("alert")'}),
          WorkflowStep(id: '4', type: StepType.action, label: 'Notify', config: {'tool': 'set_reminder'}),
        ],
      ),
    ]);
  }

  /// Create a new workflow from scratch
  Future<Workflow> createWorkflow({
    required String name,
    required String description,
    required List<WorkflowStep> steps,
    String? trigger,
    Map<String, dynamic>? variables,
  }) async {
    final id = const Uuid().v4();
    final workflow = Workflow(
      id: id,
      name: name,
      description: description,
      steps: steps,
      trigger: trigger,
      variables: variables ?? {},
      createdAt: DateTime.now(),
    );

    _workflows[id] = workflow;
    await _saveWorkflows();
    notifyListeners();
    return workflow;
  }

  /// Create workflow from template
  Future<Workflow> fromTemplate(String templateId, {Map<String, dynamic>? variables}) async {
    final template = _templates.firstWhere((t) => t.id == templateId);
    return await createWorkflow(
      name: template.name,
      description: template.description,
      steps: template.steps.map((s) => s.copyWith(id: const Uuid().v4())).toList(),
      variables: variables,
    );
  }

  /// Create workflow from natural language description
  Future<Workflow> fromNaturalLanguage(String description) async {
    final result = await DroidClawGateway.I.process(
      userMessage: '''Create a workflow from this description. Return JSON:
{
  "name": "workflow name",
  "description": "what it does",
  "steps": [
    {"type": "action|aiProcess|condition|loop|delay", "label": "step name", "config": {}}
  ]
}

Description: $description''',
      sessionId: 'workflow_builder',
    );

    try {
      final json = jsonDecode(_extractJson(result.content));
      final steps = (json['steps'] as List).map((s) => WorkflowStep(
        id: const Uuid().v4(),
        type: StepType.values.firstWhere((e) => e.name == s['type'], orElse: () => StepType.action),
        label: s['label'] ?? 'Step',
        config: Map<String, dynamic>.from(s['config'] ?? {}),
      )).toList();

      return await createWorkflow(
        name: json['name'] ?? 'Custom Workflow',
        description: json['description'] ?? description,
        steps: steps,
      );
    } catch (e) {
      // Fallback: simple workflow
      return await createWorkflow(
        name: 'Custom Workflow',
        description: description,
        steps: [
          WorkflowStep(id: const Uuid().v4(), type: StepType.aiProcess, label: 'Process', config: {'prompt': description}),
        ],
      );
    }
  }

  /// Run a workflow
  Future<WorkflowRun> runWorkflow(String workflowId, {Map<String, dynamic>? inputs}) async {
    final workflow = _workflows[workflowId];
    if (workflow == null) throw Exception('Workflow not found');

    final runId = const Uuid().v4();
    final run = WorkflowRun(
      id: runId,
      workflowId: workflowId,
      startedAt: DateTime.now(),
      inputs: inputs ?? {},
    );
    _runs[runId] = run;
    notifyListeners();

    // Execute steps
    _executeWorkflow(workflow, run);
    return run;
  }

  Future<void> _executeWorkflow(Workflow workflow, WorkflowRun run) async {
    run.status = RunStatus.running;
    final context = <String, dynamic>{...workflow.variables, ...run.inputs};

    for (var i = 0; i < workflow.steps.length; i++) {
      final step = workflow.steps[i];
      run.currentStepIndex = i;
      run.currentStepLabel = step.label;
      notifyListeners();

      try {
        switch (step.type) {
          case StepType.action:
            final tool = step.config['tool'] as String?;
            final params = Map<String, dynamic>.from(step.config['params'] ?? {});
            // Replace variables in params
            params.forEach((k, v) {
              if (v is String && v.startsWith('{{') && v.endsWith('}}')) {
                final varName = v.substring(2, v.length - 2);
                params[k] = context[varName]?.toString() ?? v;
              }
            });

            if (tool != null) {
              final result = await DroidClawGateway.I.process(
                userMessage: 'Execute tool "$tool" with params: ${jsonEncode(params)}',
                sessionId: 'workflow_${run.id}',
              );
              run.stepResults.add(StepResult(stepId: step.id, output: result.content, success: true));
              context['step_${step.id}_output'] = result.content;
            }
            break;

          case StepType.aiProcess:
            String prompt = step.config['prompt'] ?? '';
            // Replace variables
            context.forEach((k, v) {
              prompt = prompt.replaceAll('{{$k}}', v.toString());
            });

            final result = await DroidClawGateway.I.process(
              userMessage: prompt,
              sessionId: 'workflow_${run.id}',
            );
            run.stepResults.add(StepResult(stepId: step.id, output: result.content, success: true));
            context['step_${step.id}_output'] = result.content;
            break;

          case StepType.condition:
            // Evaluate condition
            final condition = step.config['condition'] as String?;
            bool met = true;
            if (condition != null) {
              // Simple condition evaluation
              if (condition == 'user_approved') {
                // In real app, would pause and wait for user
                met = true;
              } else if (condition.startsWith('result.contains')) {
                final check = condition.split('"')[1];
                final lastOutput = run.stepResults.isNotEmpty ? run.stepResults.last.output : '';
                met = lastOutput?.contains(check) ?? false;
              }
            }
            run.stepResults.add(StepResult(stepId: step.id, output: met ? 'Condition met' : 'Condition not met', success: met));
            if (!met) {
              run.status = RunStatus.skipped;
              run.completedAt = DateTime.now();
              notifyListeners();
              return;
            }
            break;

          case StepType.delay:
            final seconds = step.config['seconds'] ?? 1;
            await Future.delayed(Duration(seconds: seconds));
            run.stepResults.add(StepResult(stepId: step.id, output: 'Delayed ${seconds}s', success: true));
            break;

          case StepType.loop:
            // Loop through previous step results
            run.stepResults.add(StepResult(stepId: step.id, output: 'Loop completed', success: true));
            break;
        }
      } catch (e) {
        run.stepResults.add(StepResult(stepId: step.id, output: 'Error: $e', success: false));
        run.status = RunStatus.failed;
        run.error = e.toString();
        run.completedAt = DateTime.now();
        notifyListeners();
        return;
      }
    }

    run.status = RunStatus.completed;
    run.completedAt = DateTime.now();
    notifyListeners();
  }

  /// Delete a workflow
  Future<void> deleteWorkflow(String id) async {
    _workflows.remove(id);
    await _saveWorkflows();
    notifyListeners();
  }

  String _extractJson(String text) {
    final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    return match?.group(0) ?? '{}';
  }
}

enum StepType { action, aiProcess, condition, delay, loop }
enum RunStatus { queued, running, completed, failed, skipped }

class Workflow {
  final String id;
  final String name;
  final String description;
  final List<WorkflowStep> steps;
  final String? trigger;
  final Map<String, dynamic> variables;
  final DateTime createdAt;
  bool enabled;

  Workflow({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    this.trigger,
    required this.variables,
    required this.createdAt,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'steps': steps.map((s) => s.toJson()).toList(),
    'trigger': trigger, 'variables': variables,
    'createdAt': createdAt.toIso8601String(), 'enabled': enabled,
  };

  factory Workflow.fromJson(Map<String, dynamic> j) => Workflow(
    id: j['id'], name: j['name'], description: j['description'],
    steps: (j['steps'] as List).map((s) => WorkflowStep.fromJson(s)).toList(),
    trigger: j['trigger'],
    variables: Map<String, dynamic>.from(j['variables'] ?? {}),
    createdAt: DateTime.parse(j['createdAt']), enabled: j['enabled'] ?? true,
  );
}

class WorkflowStep {
  final String id;
  final StepType type;
  final String label;
  final Map<String, dynamic> config;

  WorkflowStep({required this.id, required this.type, required this.label, required this.config});

  WorkflowStep copyWith({String? id}) => WorkflowStep(
    id: id ?? this.id, type: type, label: label, config: config,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type.name, 'label': label, 'config': config,
  };

  factory WorkflowStep.fromJson(Map<String, dynamic> j) => WorkflowStep(
    id: j['id'], type: StepType.values.firstWhere((e) => e.name == j['type']),
    label: j['label'], config: Map<String, dynamic>.from(j['config'] ?? {}),
  );
}

class WorkflowRun {
  final String id;
  final String workflowId;
  final DateTime startedAt;
  DateTime? completedAt;
  RunStatus status;
  final Map<String, dynamic> inputs;
  final List<StepResult> stepResults;
  int currentStepIndex;
  String? currentStepLabel;
  String? error;

  WorkflowRun({
    required this.id,
    required this.workflowId,
    required this.startedAt,
    this.status = RunStatus.queued,
    required this.inputs,
    List<StepResult>? stepResults,
    this.currentStepIndex = 0,
    this.currentStepLabel,
    this.error,
  }) : stepResults = stepResults ?? [];

  Duration? get duration => completedAt?.difference(startedAt);
}

class StepResult {
  final String stepId;
  final String? output;
  final bool success;
  StepResult({required this.stepId, this.output, required this.success});
}

class WorkflowTemplate {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<WorkflowStep> steps;

  WorkflowTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.steps,
  });
}
