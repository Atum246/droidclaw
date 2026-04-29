import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../tools/tool_engine.dart';
import '../providers/ai_provider_manager.dart';

/// 🔧 Tool Creator — Auto-Generates New Tools on Demand
/// When the agent doesn't have a tool for a task, this creates one
class ToolCreator extends ChangeNotifier {
  static final ToolCreator I = ToolCreator._();
  ToolCreator._();

  late SharedPreferences _prefs;
  final Map<String, CreatedTool> _createdTools = {};
  final List<ToolCreationLog> _logs = [];

  Map<String, CreatedTool> get createdTools => Map.unmodifiable(_createdTools);
  List<ToolCreationLog> get logs => List.unmodifiable(_logs);
  int get createdCount => _createdTools.length;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCreatedTools();
  }

  void _loadCreatedTools() {
    final data = _prefs.getString('created_tools');
    if (data != null) {
      final Map<String, dynamic> map = jsonDecode(data);
      map.forEach((k, v) {
        final tool = CreatedTool.fromJson(v);
        _createdTools[k] = tool;
        _registerDynamicTool(tool);
      });
    }
  }

  Future<void> _saveCreatedTools() async {
    final data = _createdTools.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs.setString('created_tools', jsonEncode(data));
  }

  /// Create a new tool dynamically
  Future<CreatedTool> createTool({
    required String name,
    required String description,
    required String category,
    required String icon,
    required Map<String, dynamic> parameters,
    required String implementation,
    String? reason,
  }) async {
    final tool = CreatedTool(
      id: 'created_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      category: category,
      icon: icon,
      parameters: parameters,
      implementation: implementation,
      reason: reason ?? 'Auto-generated tool',
      createdAt: DateTime.now(),
    );

    _createdTools[name] = tool;
    _registerDynamicTool(tool);
    await _saveCreatedTools();

    _logs.add(ToolCreationLog(
      toolName: name,
      reason: reason ?? 'Auto-generated',
      timestamp: DateTime.now(),
    ));

    notifyListeners();
    return tool;
  }

  /// Analyze a task and determine if a new tool is needed
  Future<ToolAnalysis> analyzeTask(String task) async {
    final existingTools = ToolEngine.I.tools.map((t) => '${t.name}: ${t.description}').join('\n');

    final prompt = '''
You are a tool analysis engine. Given a task and the list of existing tools, determine:
1. Can the task be accomplished with existing tools? (yes/no)
2. If no, what new tool should be created?
3. Provide the tool specification.

EXISTING TOOLS:
$existingTools

TASK: $task

Respond in JSON:
{
  "canUseExisting": true/false,
  "existingTool": "tool_name_if_applicable",
  "suggestedTool": {
    "name": "tool_name",
    "description": "what it does",
    "category": "category",
    "icon": "emoji",
    "parameters": {"param": "type"},
    "implementation": "description of what the tool should do step by step"
  },
  "reasoning": "why this tool is needed"
}
''';

    try {
      final result = await AIProviderManager.I.chat(
        modelId: AIProviderManager.I.activeModelId,
        messages: [
          {'role': 'system', 'content': 'You are a tool analysis engine. Respond only in valid JSON.'},
          {'role': 'user', 'content': prompt},
        ],
        tools: [],
      );

      final json = jsonDecode(_extractJson(result.content));
      return ToolAnalysis.fromJson(json);
    } catch (e) {
      return ToolAnalysis(canUseExisting: false, reasoning: 'Analysis failed: $e');
    }
  }

  /// Auto-create a tool for a task that can't be handled
  Future<CreatedTool?> autoCreateTool(String task, {String? context}) async {
    final analysis = await analyzeTask(task);

    if (analysis.canUseExisting && analysis.existingTool != null) {
      return null; // Existing tool can handle it
    }

    if (analysis.suggestedTool == null) return null;

    final spec = analysis.suggestedTool!;
    return await createTool(
      name: spec['name'] ?? 'auto_tool_${DateTime.now().millisecondsSinceEpoch}',
      description: spec['description'] ?? 'Auto-generated tool',
      category: spec['category'] ?? 'custom',
      icon: spec['icon'] ?? '🔧',
      parameters: Map<String, dynamic>.from(spec['parameters'] ?? {}),
      implementation: spec['implementation'] ?? '',
      reason: analysis.reasoning,
    );
  }

  void _registerDynamicTool(CreatedTool tool) {
    // Register with ToolEngine so the agent can use it
    // Dynamic tools execute via the AI provider
    ToolEngine.I.registerDynamicTool(
      name: tool.name,
      description: '${tool.description} [Auto-created: ${tool.reason}]',
      icon: tool.icon,
      category: tool.category,
      parameters: tool.parameters,
      executor: (params) => _executeCreatedTool(tool, params),
    );
  }

  Future<ToolResult> _executeCreatedTool(CreatedTool tool, Map<String, dynamic> params) async {
    // Execute the tool using AI provider to interpret and run the implementation
    final prompt = '''
You are executing a dynamically created tool.

TOOL: ${tool.name}
DESCRIPTION: ${tool.description}
IMPLEMENTATION GUIDE: ${tool.implementation}
PARAMETERS: ${jsonEncode(params)}

Execute this tool. If it involves web requests, use available tools.
If it involves computation, calculate it.
If it involves data processing, process it.
Return the result directly.

Available context: ${params.toString()}
''';

    try {
      final result = await AIProviderManager.I.chat(
        modelId: AIProviderManager.I.activeModelId,
        messages: [
          {'role': 'system', 'content': 'You are a tool execution engine. Execute the tool and return results.'},
          {'role': 'user', 'content': prompt},
        ],
        tools: ToolEngine.I.availableTools.map((t) => t.toJsonSchema()).toList(),
      );

      return ToolResult(content: result.content.isNotEmpty ? result.content : '✅ Tool ${tool.name} executed');
    } catch (e) {
      return ToolResult(content: '❌ Tool execution failed: $e', isError: true);
    }
  }

  String _extractJson(String text) {
    // Extract JSON from response that might contain markdown
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    return jsonMatch?.group(0) ?? '{}';
  }
}

class CreatedTool {
  final String id;
  final String name;
  final String description;
  final String category;
  final String icon;
  final Map<String, dynamic> parameters;
  final String implementation;
  final String reason;
  final DateTime createdAt;
  int useCount;

  CreatedTool({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.parameters,
    required this.implementation,
    required this.reason,
    required this.createdAt,
    this.useCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'category': category, 'icon': icon, 'parameters': parameters,
    'implementation': implementation, 'reason': reason,
    'createdAt': createdAt.toIso8601String(), 'useCount': useCount,
  };

  factory CreatedTool.fromJson(Map<String, dynamic> j) => CreatedTool(
    id: j['id'], name: j['name'], description: j['description'],
    category: j['category'], icon: j['icon'],
    parameters: Map<String, dynamic>.from(j['parameters'] ?? {}),
    implementation: j['implementation'] ?? '', reason: j['reason'] ?? '',
    createdAt: DateTime.parse(j['createdAt']), useCount: j['useCount'] ?? 0,
  );
}

class ToolAnalysis {
  final bool canUseExisting;
  final String? existingTool;
  final Map<String, dynamic>? suggestedTool;
  final String reasoning;

  ToolAnalysis({
    required this.canUseExisting,
    this.existingTool,
    this.suggestedTool,
    required this.reasoning,
  });

  factory ToolAnalysis.fromJson(Map<String, dynamic> j) => ToolAnalysis(
    canUseExisting: j['canUseExisting'] ?? false,
    existingTool: j['existingTool'],
    suggestedTool: j['suggestedTool'] != null ? Map<String, dynamic>.from(j['suggestedTool']) : null,
    reasoning: j['reasoning'] ?? '',
  );
}

class ToolCreationLog {
  final String toolName;
  final String reason;
  final DateTime timestamp;
  ToolCreationLog({required this.toolName, required this.reason, required this.timestamp});
}
