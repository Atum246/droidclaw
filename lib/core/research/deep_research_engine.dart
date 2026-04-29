import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../providers/ai_provider_manager.dart';
import '../tools/tool_engine.dart';
import '../memory/memory_engine.dart';

/// 🔬 Deep Research Engine — Multi-Step Research with Synthesis
/// Does comprehensive research by chaining searches, reading sources, and synthesizing
class DeepResearchEngine extends ChangeNotifier {
  static final DeepResearchEngine I = DeepResearchEngine._();
  DeepResearchEngine._();

  final Map<String, ResearchProject> _projects = {};
  final StreamController<ResearchEvent> _events = StreamController.broadcast();

  Map<String, ResearchProject> get projects => Map.unmodifiable(_projects);
  Stream<ResearchEvent> get events => _events.stream;

  /// Start a deep research project
  Future<ResearchProject> research({
    required String topic,
    int depth = 3,           // How many layers of research
    int sourcesPerLayer = 5, // Sources to check per layer
    bool saveToMemory = true,
    String? specificFocus,
  }) async {
    final id = const Uuid().v4();
    final project = ResearchProject(
      id: id,
      topic: topic,
      depth: depth,
      sourcesPerLayer: sourcesPerLayer,
      specificFocus: specificFocus,
      createdAt: DateTime.now(),
    );
    _projects[id] = project;
    _events.add(ResearchEvent(type: 'started', projectId: id, data: topic));
    notifyListeners();

    // Run research in background
    _conductResearch(project, saveToMemory: saveToMemory);
    return project;
  }

  Future<void> _conductResearch(ResearchProject project, {bool saveToMemory = true}) async {
    project.status = ResearchStatus.inProgress;
    notifyListeners();

    try {
      final provider = AIProviderManager.I;

      // Layer 1: Initial research — gather key questions and subtopics
      project.currentPhase = '🔍 Analyzing topic and generating research questions...';
      notifyListeners();

      final questionsResult = await provider.chat(
        modelId: provider.activeModelId,
        messages: [
          {'role': 'system', 'content': 'You are a research planning engine. Generate structured research questions.'},
          {'role': 'user', 'content': '''
Research Topic: ${project.topic}
${project.specificFocus != null ? 'Focus: ${project.specificFocus}' : ''}

Generate a JSON array of ${project.sourcesPerLayer} research questions to investigate:
["question1", "question2", ...]

Only output the JSON array, nothing else.'''},
        ],
        tools: [],
      );

      final questions = _parseJsonList(questionsResult.content);
      project.questions = questions.cast<String>();
      project.layers.add(ResearchLayer(
        level: 1,
        topic: 'Research Questions',
        findings: questions.map((q) => ResearchFinding(question: q, sources: [])).toList(),
      ));

      // Layer 2+: Search and analyze for each question
      for (int layer = 2; layer <= project.depth; layer++) {
        project.currentPhase = '📚 Layer $layer: Searching and analyzing sources...';
        notifyListeners();

        final layerFindings = <ResearchFinding>[];

        for (var question in questions.take(project.sourcesPerLayer)) {
          // Search for each question
          project.currentPhase = '🔍 Searching: $question';
          notifyListeners();

          try {
            final searchResult = await ToolEngine.I.execute('web_search', {'query': question});
            final fetchResults = <String>[];

            // Try to fetch top results
            final urls = _extractUrls(searchResult.content);
            for (var url in urls.take(2)) {
              try {
                final content = await ToolEngine.I.execute('fetch_url', {'url': url, 'maxChars': 3000});
                fetchResults.add(content.content);
              } catch (_) {}
            }

            layerFindings.add(ResearchFinding(
              question: question,
              searchResult: searchResult.content,
              fetchedContent: fetchResults,
              sources: urls,
            ));
          } catch (e) {
            layerFindings.add(ResearchFinding(
              question: question,
              searchResult: 'Search failed: $e',
              sources: [],
            ));
          }
        }

        project.layers.add(ResearchLayer(level: layer, topic: 'Layer $layer Research', findings: layerFindings));

        // Generate follow-up questions based on findings
        if (layer < project.depth) {
          project.currentPhase = '🧠 Generating follow-up questions...';
          notifyListeners();

          final synthesis = await provider.chat(
            modelId: provider.activeModelId,
            messages: [
              {'role': 'system', 'content': 'You are a research analyst. Generate follow-up questions.'},
              {'role': 'user', 'content': '''
Topic: ${project.topic}
Findings so far:
${layerFindings.map((f) => 'Q: ${f.question}\nA: ${f.searchResult}').join('\n\n')}

Generate 3-5 follow-up questions that need deeper investigation.
Output as JSON array: ["q1", "q2", ...]'''},
            ],
            tools: [],
          );

          questions.addAll(_parseJsonList(synthesis.content).cast<String>());
        }
      }

      // Final synthesis
      project.currentPhase = '📝 Synthesizing final report...';
      notifyListeners();

      final allFindings = project.layers.expand((l) => l.findings).toList();
      final findingsText = allFindings.map((f) =>
        'Q: ${f.question}\nSources: ${f.sources.join(", ")}\nFindings: ${f.searchResult}\n${f.fetchedContent.join("\n")}'
      ).join('\n\n---\n\n');

      final synthesisResult = await provider.chat(
        modelId: provider.activeModelId,
        messages: [
          {'role': 'system', 'content': '''You are a senior research analyst. Synthesize research findings into a comprehensive, well-structured report.
Include:
- Executive Summary
- Key Findings (with citations)
- Detailed Analysis
- Conclusions
- Recommendations
- Sources'''},
          {'role': 'user', 'content': '''
Research Topic: ${project.topic}
${project.specificFocus != null ? 'Focus: ${project.specificFocus}' : ''}

RESEARCH FINDINGS:
$findingsText

Synthesize this into a comprehensive research report.'''},
        ],
        tools: [],
      );

      project.finalReport = synthesisResult.content;
      project.status = ResearchStatus.completed;
      project.completedAt = DateTime.now();
      project.currentPhase = '✅ Research complete';

      // Save to memory
      if (saveToMemory) {
        await MemoryEngine.I.saveMemory(
          'research_${project.topic}',
          project.finalReport!,
          category: 'research',
        );
      }

    } catch (e) {
      project.status = ResearchStatus.failed;
      project.currentPhase = '❌ Research failed: $e';
    }

    _events.add(ResearchEvent(
      type: 'completed',
      projectId: project.id,
      data: {'status': project.status.name, 'report': project.finalReport},
    ));
    notifyListeners();
  }

  List<dynamic> _parseJsonList(String text) {
    try {
      final match = RegExp(r'\[[\s\S]*\]').firstMatch(text);
      if (match != null) return jsonDecode(match.group(0)!);
    } catch (_) {}
    return [];
  }

  List<String> _extractUrls(String text) {
    final urlRegex = RegExp(r'https?://[^\s\)\]]+');
    return urlRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }
}

enum ResearchStatus { queued, inProgress, completed, failed }

class ResearchProject {
  final String id;
  final String topic;
  final int depth;
  final int sourcesPerLayer;
  final String? specificFocus;
  final DateTime createdAt;

  ResearchStatus status = ResearchStatus.queued;
  String? currentPhase;
  List<String> questions = [];
  final List<ResearchLayer> layers = [];
  String? finalReport;
  DateTime? completedAt;

  ResearchProject({
    required this.id,
    required this.topic,
    required this.depth,
    required this.sourcesPerLayer,
    this.specificFocus,
    required this.createdAt,
  });

  Duration? get duration => completedAt?.difference(createdAt);
}

class ResearchLayer {
  final int level;
  final String topic;
  final List<ResearchFinding> findings;
  ResearchLayer({required this.level, required this.topic, required this.findings});
}

class ResearchFinding {
  final String question;
  final String? searchResult;
  final List<String> fetchedContent;
  final List<String> sources;
  ResearchFinding({
    required this.question,
    this.searchResult,
    this.fetchedContent = const [],
    required this.sources,
  });
}

class ResearchEvent {
  final String type;
  final String projectId;
  final dynamic data;
  ResearchEvent({required this.type, required this.projectId, this.data});
}
