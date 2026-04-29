import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../skills/skill_engine.dart';
import '../providers/ai_provider_manager.dart';

/// ⚡ Skill Creator — Auto-Generates New Skills on Demand
/// When the agent encounters a task type it doesn't have a skill for
class SkillCreator extends ChangeNotifier {
  static final SkillCreator I = SkillCreator._();
  SkillCreator._();

  late SharedPreferences _prefs;
  final Map<String, CreatedSkill> _createdSkills = {};
  final List<SkillCreationLog> _logs = [];

  Map<String, CreatedSkill> get createdSkills => Map.unmodifiable(_createdSkills);
  List<SkillCreationLog> get logs => List.unmodifiable(_logs);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCreatedSkills();
  }

  void _loadCreatedSkills() {
    final data = _prefs.getString('created_skills');
    if (data != null) {
      final Map<String, dynamic> map = jsonDecode(data);
      map.forEach((k, v) {
        final skill = CreatedSkill.fromJson(v);
        _createdSkills[k] = skill;
        _registerDynamicSkill(skill);
      });
    }
  }

  Future<void> _saveCreatedSkills() async {
    final data = _createdSkills.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs.setString('created_skills', jsonEncode(data));
  }

  /// Create a new skill dynamically
  Future<CreatedSkill> createSkill({
    required String name,
    required String description,
    required String category,
    required String icon,
    required List<String> triggers,
    required String systemPrompt,
    String? reason,
  }) async {
    final skill = CreatedSkill(
      id: 'created_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      category: category,
      icon: icon,
      triggers: triggers,
      systemPrompt: systemPrompt,
      reason: reason ?? 'Auto-generated skill',
      createdAt: DateTime.now(),
    );

    _createdSkills[skill.id] = skill;
    _registerDynamicSkill(skill);
    await _saveCreatedSkills();

    _logs.add(SkillCreationLog(
      skillName: name,
      reason: reason ?? 'Auto-generated',
      timestamp: DateTime.now(),
    ));

    notifyListeners();
    return skill;
  }

  /// Analyze if a new skill is needed for a task
  Future<SkillAnalysis> analyzeNeed(String task) async {
    final existingSkills = SkillEngine.I.skills.map((s) => '${s.name}: ${s.description} [${s.triggers.join(", ")}]').join('\n');

    final prompt = '''
You are a skill analysis engine. Given a task and existing skills, determine:
1. Is there an existing skill that handles this? 
2. If not, what new skill should be created?

EXISTING SKILLS:
$existingSkills

TASK: $task

Respond in JSON:
{
  "hasExistingSkill": true/false,
  "existingSkillId": "id_if_exists",
  "newSkill": {
    "name": "Skill Name",
    "description": "What it does",
    "category": "category",
    "icon": "emoji",
    "triggers": ["trigger1", "trigger2"],
    "systemPrompt": "Detailed system prompt for this skill's behavior"
  },
  "reasoning": "why"
}
''';

    try {
      final result = await AIProviderManager.I.chat(
        modelId: AIProviderManager.I.activeModelId,
        messages: [
          {'role': 'system', 'content': 'You are a skill analysis engine. Respond only in valid JSON.'},
          {'role': 'user', 'content': prompt},
        ],
        tools: [],
      );

      final json = jsonDecode(_extractJson(result.content));
      return SkillAnalysis.fromJson(json);
    } catch (e) {
      return SkillAnalysis(hasExistingSkill: false, reasoning: 'Analysis failed: $e');
    }
  }

  /// Auto-create a skill for a new type of task
  Future<CreatedSkill?> autoCreateSkill(String task, {String? context}) async {
    final analysis = await analyzeNeed(task);

    if (analysis.hasExistingSkill) return null;
    if (analysis.newSkill == null) return null;

    final spec = analysis.newSkill!;
    return await createSkill(
      name: spec['name'] ?? 'Auto Skill',
      description: spec['description'] ?? 'Auto-generated',
      category: spec['category'] ?? 'custom',
      icon: spec['icon'] ?? '⚡',
      triggers: List<String>.from(spec['triggers'] ?? []),
      systemPrompt: spec['systemPrompt'] ?? 'Handle this task type.',
      reason: analysis.reasoning,
    );
  }

  void _registerDynamicSkill(CreatedSkill skill) {
    SkillEngine.I.registerDynamicSkill(
      id: skill.id,
      name: skill.name,
      description: '${skill.description} [Auto-created]',
      category: skill.category,
      icon: skill.icon,
      triggers: skill.triggers,
    );
  }

  String _extractJson(String text) {
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    return jsonMatch?.group(0) ?? '{}';
  }
}

class CreatedSkill {
  final String id;
  final String name;
  final String description;
  final String category;
  final String icon;
  final List<String> triggers;
  final String systemPrompt;
  final String reason;
  final DateTime createdAt;
  int useCount;

  CreatedSkill({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.triggers,
    required this.systemPrompt,
    required this.reason,
    required this.createdAt,
    this.useCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'category': category, 'icon': icon, 'triggers': triggers,
    'systemPrompt': systemPrompt, 'reason': reason,
    'createdAt': createdAt.toIso8601String(), 'useCount': useCount,
  };

  factory CreatedSkill.fromJson(Map<String, dynamic> j) => CreatedSkill(
    id: j['id'], name: j['name'], description: j['description'],
    category: j['category'], icon: j['icon'],
    triggers: List<String>.from(j['triggers'] ?? []),
    systemPrompt: j['systemPrompt'] ?? '', reason: j['reason'] ?? '',
    createdAt: DateTime.parse(j['createdAt']), useCount: j['useCount'] ?? 0,
  );
}

class SkillAnalysis {
  final bool hasExistingSkill;
  final String? existingSkillId;
  final Map<String, dynamic>? newSkill;
  final String reasoning;

  SkillAnalysis({
    required this.hasExistingSkill,
    this.existingSkillId,
    this.newSkill,
    required this.reasoning,
  });

  factory SkillAnalysis.fromJson(Map<String, dynamic> j) => SkillAnalysis(
    hasExistingSkill: j['hasExistingSkill'] ?? false,
    existingSkillId: j['existingSkillId'],
    newSkill: j['newSkill'] != null ? Map<String, dynamic>.from(j['newSkill']) : null,
    reasoning: j['reasoning'] ?? '',
  );
}

class SkillCreationLog {
  final String skillName;
  final String reason;
  final DateTime timestamp;
  SkillCreationLog({required this.skillName, required this.reason, required this.timestamp});
}
