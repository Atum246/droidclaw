import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ⚡ Skill Engine — 100+ Built-in Skills
class SkillEngine extends ChangeNotifier {
  static final SkillEngine I = SkillEngine._();
  SkillEngine._();

  late SharedPreferences _prefs;
  final Map<String, Skill> _skills = {};
  final Map<String, bool> _enabled = {};

  List<Skill> get skills => _skills.values.toList();
  List<Skill> get enabledSkills => _skills.values.where((s) => _enabled[s.id] == true).toList();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _registerAll();
    _loadState();
  }

  List<Skill> findRelevant(String message) {
    final lower = message.toLowerCase();
    return enabledSkills.where((s) =>
      s.triggers.any((t) => lower.contains(t.toLowerCase()))
    ).toList();
  }

  /// Register a dynamically created skill at runtime
  void registerDynamicSkill({
    required String id,
    required String name,
    required String description,
    required String category,
    required String icon,
    required List<String> triggers,
  }) {
    _skills[id] = Skill(id: id, name: name, description: description, category: category, icon: icon, triggers: triggers);
    _enabled[id] = true;
    notifyListeners();
  }

  void _loadState() {
    final data = _prefs.getString('skill_states');
    if (data != null) {
      final Map<String, dynamic> states = jsonDecode(data);
      states.forEach((k, v) => _enabled[k] = v as bool);
    }
    // Enable all by default
    for (var s in _skills.values) {
      _enabled.putIfAbsent(s.id, () => true);
    }
  }

  void _reg(String id, String name, String desc, String cat, String icon, List<String> triggers) {
    _skills[id] = Skill(id: id, name: name, description: desc, category: cat, icon: icon, triggers: triggers);
  }

  void _registerAll() {
    // ══════════ 💻 DEVELOPMENT (15) ══════════
    _reg('code_review', 'Code Review', 'Review code for bugs & best practices', 'Development', '🔍', ['review code', 'check code', 'code review', 'audit code']);
    _reg('code_explain', 'Code Explainer', 'Explain code in plain English', 'Development', '📖', ['explain code', 'what does this code', 'code explanation']);
    _reg('code_convert', 'Code Converter', 'Convert between programming languages', 'Development', '🔄', ['convert code', 'translate code', 'port to']);
    _reg('code_gen', 'Code Generator', 'Generate code from description', 'Development', '⚡', ['write code', 'generate code', 'create function', 'implement']);
    _reg('debug', 'Debugger', 'Find and fix bugs', 'Development', '🐛', ['debug', 'fix bug', 'error', 'not working', 'broken']);
    _reg('refactor', 'Refactorer', 'Improve code structure', 'Development', '♻️', ['refactor', 'clean up code', 'improve code']);
    _reg('test_gen', 'Test Generator', 'Generate unit tests', 'Development', '🧪', ['write tests', 'generate tests', 'unit test']);
    _reg('api_design', 'API Designer', 'Design REST APIs', 'Development', '🌐', ['design api', 'api design', 'rest api']);
    _reg('sql_gen', 'SQL Generator', 'Generate SQL queries', 'Development', '🗃️', ['sql query', 'write sql', 'database query']);
    _reg('regex', 'Regex Builder', 'Build regular expressions', 'Development', '🎯', ['regex', 'regular expression', 'pattern match']);
    _reg('git_help', 'Git Helper', 'Git commands & workflows', 'Development', '🌿', ['git', 'commit', 'branch', 'merge']);
    _reg('docker', 'Docker Helper', 'Docker & containers', 'Development', '🐳', ['docker', 'container', 'dockerfile']);
    _reg('json_format', 'JSON Formatter', 'Format & validate JSON', 'Development', '📋', ['json', 'format json', 'validate json']);
    _reg('code_optimize', 'Code Optimizer', 'Optimize code performance', 'Development', '🚀', ['optimize', 'performance', 'speed up']);
    _reg('error_decode', 'Error Decoder', 'Decode error messages', 'Development', '🔐', ['error message', 'what does this error', 'traceback']);

    // ══════════ ✍️ WRITING (15) ══════════
    _reg('email_write', 'Email Writer', 'Draft professional emails', 'Writing', '📧', ['write email', 'draft email', 'compose email']);
    _reg('essay_write', 'Essay Writer', 'Write structured essays', 'Writing', '📝', ['write essay', 'essay about']);
    _reg('story_write', 'Story Writer', 'Create stories & narratives', 'Writing', '📚', ['write story', 'story about', 'creative writing']);
    _reg('poem_write', 'Poet', 'Write poems in various styles', 'Writing', '🎭', ['write poem', 'poetry', 'haiku']);
    _reg('report_write', 'Report Writer', 'Write professional reports', 'Writing', '📊', ['write report', 'report about']);
    _reg('cover_letter', 'Cover Letter', 'Write compelling cover letters', 'Writing', '✉️', ['cover letter', 'job application']);
    _reg('resume_build', 'Resume Builder', 'Build & improve resumes', 'Writing', '📄', ['resume', 'cv', 'curriculum']);
    _reg('grammar', 'Grammar Check', 'Check & correct grammar', 'Writing', '✏️', ['grammar', 'check grammar', 'proofread']);
    _reg('summarize', 'Summarizer', 'Summarize long texts', 'Writing', '📰', ['summarize', 'summary', 'tldr']);
    _reg('translate', 'Translator', 'Translate 100+ languages', 'Writing', '🌍', ['translate', 'translation', 'in spanish', 'in french', 'in chinese', 'in japanese']);
    _reg('paraphrase', 'Paraphraser', 'Rewrite text differently', 'Writing', '🔄', ['paraphrase', 'rewrite', 'rephrase']);
    _reg('headline', 'Headline Generator', 'Generate catchy headlines', 'Writing', '💡', ['headline', 'title', 'subject line']);
    _reg('blog_write', 'Blog Writer', 'Write blog posts', 'Writing', '✍️', ['blog post', 'write blog', 'article']);
    _reg('slogan', 'Slogan Creator', 'Create catchy slogans', 'Writing', '💬', ['slogan', 'tagline', 'motto']);
    _reg('script_write', 'Script Writer', 'Write scripts & screenplays', 'Writing', '🎬', ['script', 'screenplay', 'dialogue']);

    // ══════════ 📊 ANALYSIS (10) ══════════
    _reg('data_analyze', 'Data Analyzer', 'Analyze data patterns', 'Analysis', '📈', ['analyze data', 'data analysis', 'patterns']);
    _reg('sentiment', 'Sentiment Analysis', 'Analyze text sentiment', 'Analysis', '😊', ['sentiment', 'emotion analysis', 'mood']);
    _reg('market_research', 'Market Research', 'Research markets & competitors', 'Analysis', '🔍', ['market research', 'competitor', 'industry']);
    _reg('swot', 'SWOT Analysis', 'Strengths, weaknesses, opportunities, threats', 'Analysis', '🎯', ['swot', 'strengths weaknesses']);
    _reg('risk_assess', 'Risk Assessment', 'Assess risks & mitigation', 'Analysis', '⚠️', ['risk', 'assessment', 'mitigation']);
    _reg('compare', 'Comparator', 'Compare options', 'Analysis', '⚖️', ['compare', 'vs', 'versus', 'pros and cons']);
    _reg('brainstorm', 'Brainstormer', 'Generate creative ideas', 'Analysis', '💡', ['brainstorm', 'ideas', 'creative', 'think of']);
    _reg('critique', 'Critic', 'Provide constructive feedback', 'Analysis', '🎯', ['critique', 'feedback', 'review']);
    _reg('research', 'Researcher', 'Deep research on topics', 'Analysis', '🔬', ['research', 'investigate', 'look into']);
    _reg('trend_analyze', 'Trend Analyzer', 'Analyze trends & patterns', 'Analysis', '📊', ['trend', 'trending', 'popular']);

    // ══════════ 🎓 EDUCATION (10) ══════════
    _reg('math_solve', 'Math Solver', 'Solve math step by step', 'Education', '🔢', ['solve math', 'calculate', 'equation']);
    _reg('science', 'Science Explainer', 'Explain scientific concepts', 'Education', '🔬', ['science', 'explain', 'how does']);
    _reg('history', 'Historian', 'History questions', 'Education', '🏛️', ['history', 'historical', 'when did']);
    _reg('flashcards', 'Flashcard Maker', 'Create study flashcards', 'Education', '🃏', ['flashcards', 'study cards']);
    _reg('quiz', 'Quiz Generator', 'Generate quizzes', 'Education', '❓', ['quiz', 'test me', 'questions']);
    _reg('eli5', 'ELI5', 'Explain like I\'m 5', 'Education', '👶', ['eli5', 'explain simply', 'simple terms']);
    _reg('study_plan', 'Study Planner', 'Create study schedules', 'Education', '📅', ['study plan', 'study schedule']);
    _reg('language_learn', 'Language Tutor', 'Learn new languages', 'Education', '🗣️', ['learn language', 'practice', 'vocabulary']);
    _reg('explain_concept', 'Concept Explainer', 'Break down complex concepts', 'Education', '💡', ['what is', 'explain', 'concept']);
    _reg('vocab_build', 'Vocabulary Builder', 'Build vocabulary', 'Education', '📖', ['vocabulary', 'word meaning', 'definition']);

    // ══════════ 💼 BUSINESS (10) ══════════
    _reg('business_plan', 'Business Plan', 'Write business plans', 'Business', '📋', ['business plan', 'startup plan']);
    _reg('pitch_deck', 'Pitch Deck', 'Create investor pitches', 'Business', '🎤', ['pitch', 'investor', 'presentation']);
    _reg('meeting_notes', 'Meeting Notes', 'Summarize meetings', 'Business', '📝', ['meeting notes', 'meeting summary']);
    _reg('project_plan', 'Project Planner', 'Create project plans', 'Business', '📊', ['project plan', 'timeline', 'roadmap']);
    _reg('budget', 'Budget Helper', 'Budget creation & management', 'Business', '💰', ['budget', 'financial plan']);
    _reg('contract_review', 'Contract Review', 'Review contracts', 'Business', '📜', ['contract', 'agreement', 'terms']);
    _reg('strategy', 'Strategy Advisor', 'Business strategy', 'Business', '♟️', ['strategy', 'strategic plan']);
    _reg('presentation', 'Presentation Maker', 'Create presentations', 'Business', '🎪', ['presentation', 'slides', 'powerpoint']);
    _reg('invoice', 'Invoice Generator', 'Create invoices', 'Business', '🧾', ['invoice', 'bill', 'receipt']);
    _reg('kpi_tracker', 'KPI Tracker', 'Track key metrics', 'Business', '📈', ['kpi', 'metrics', 'tracking']);

    // ══════════ 🎨 CREATIVE (10) ══════════
    _reg('logo_idea', 'Logo Ideas', 'Generate logo concepts', 'Creative', '🎨', ['logo', 'logo design', 'brand mark']);
    _reg('color_palette', 'Color Palette', 'Generate color palettes', 'Creative', '🌈', ['color palette', 'colors', 'theme colors']);
    _reg('ui_design', 'UI Advisor', 'UI/UX design advice', 'Creative', '🖼️', ['ui design', 'ux', 'interface']);
    _reg('brand_name', 'Brand Namer', 'Generate brand names', 'Creative', '✨', ['brand name', 'company name', 'product name']);
    _reg('recipe', 'Recipe Creator', 'Create & modify recipes', 'Creative', '🍳', ['recipe', 'cook', 'meal']);
    _reg('travel_plan', 'Travel Planner', 'Plan trips & itineraries', 'Creative', '✈️', ['travel', 'trip', 'itinerary', 'vacation']);
    _reg('gift_idea', 'Gift Advisor', 'Gift suggestions', 'Creative', '🎁', ['gift', 'present', 'surprise']);
    _reg('interior', 'Interior Design', 'Design room layouts', 'Creative', '🏠', ['interior', 'room design', 'decorate']);
    _reg('fashion', 'Fashion Advisor', 'Style & fashion advice', 'Creative', '👗', ['fashion', 'outfit', 'style']);
    _reg('music_theory', 'Music Theory', 'Music composition help', 'Creative', '🎵', ['music', 'chord', 'melody', 'song']);

    // ══════════ 🛠️ PRODUCTIVITY (10) ══════════
    _reg('todo', 'Todo Manager', 'Manage task lists', 'Productivity', '✅', ['todo', 'task list', 'checklist']);
    _reg('calendar', 'Calendar Helper', 'Manage calendar', 'Productivity', '📅', ['calendar', 'schedule', 'appointment']);
    _reg('note_taker', 'Note Taker', 'Take & organize notes', 'Productivity', '📝', ['note', 'notes', 'write down', 'jot']);
    _reg('decision', 'Decision Maker', 'Help make decisions', 'Productivity', '🤔', ['decide', 'decision', 'should i']);
    _reg('time_manage', 'Time Manager', 'Time management advice', 'Productivity', '⏰', ['time management', 'productivity']);
    _reg('habit', 'Habit Tracker', 'Track & build habits', 'Productivity', '📈', ['habit', 'routine', 'streak']);
    _reg('goal_set', 'Goal Setter', 'Set & track goals', 'Productivity', '🎯', ['goal', 'objective', 'target']);
    _reg('focus', 'Focus Helper', 'Improve concentration', 'Productivity', '🧘', ['focus', 'concentrate', 'distraction']);
    _reg('prioritize', 'Prioritizer', 'Prioritize tasks', 'Productivity', '📊', ['prioritize', 'important', 'urgent']);
    _reg('workflow', 'Workflow Optimizer', 'Optimize workflows', 'Productivity', '🔄', ['workflow', 'automate', 'efficient']);

    // ══════════ 🤖 AI & TECH (8) ══════════
    _reg('prompt_eng', 'Prompt Engineer', 'Craft better AI prompts', 'AI & Tech', '🤖', ['prompt', 'improve prompt', 'prompt engineering']);
    _reg('tech_support', 'Tech Support', 'Technical troubleshooting', 'AI & Tech', '🔧', ['tech support', 'troubleshoot', 'help with']);
    _reg('cybersecurity', 'Cybersecurity', 'Security best practices', 'AI & Tech', '🔒', ['security', 'cybersecurity', 'protect']);
    _reg('ai_explain', 'AI Explainer', 'Explain AI concepts', 'AI & Tech', '🧠', ['ai explain', 'machine learning', 'neural']);
    _reg('blockchain', 'Blockchain Expert', 'Blockchain & crypto', 'AI & Tech', '⛓️', ['blockchain', 'crypto', 'web3']);
    _reg('cloud_arch', 'Cloud Architect', 'Cloud infrastructure', 'AI & Tech', '☁️', ['cloud', 'aws', 'azure', 'infrastructure']);
    _reg('network', 'Network Expert', 'Networking advice', 'AI & Tech', '🌐', ['network', 'dns', 'vpn', 'firewall']);
    _reg('database', 'Database Expert', 'Database design & optimization', 'AI & Tech', '🗃️', ['database', 'sql', 'nosql', 'schema']);

    // ══════════ 🏥 HEALTH (5) ══════════
    _reg('fitness', 'Fitness Coach', 'Workout & fitness', 'Health', '💪', ['fitness', 'workout', 'exercise']);
    _reg('nutrition', 'Nutrition Advisor', 'Diet & nutrition', 'Health', '🥗', ['nutrition', 'diet', 'food']);
    _reg('mental_health', 'Wellness Guide', 'Mental health support', 'Health', '🧘', ['mental health', 'stress', 'anxiety']);
    _reg('sleep', 'Sleep Advisor', 'Sleep improvement', 'Health', '😴', ['sleep', 'insomnia', 'rest']);
    _reg('meditation', 'Meditation Guide', 'Guided meditation', 'Health', '🧘', ['meditate', 'meditation', 'mindfulness']);

    // ══════════ 🎮 FUN (8) ══════════
    _reg('trivia', 'Trivia Master', 'Fun trivia questions', 'Fun', '🎯', ['trivia', 'quiz me', 'fun facts']);
    _reg('joke', 'Comedian', 'Tell jokes', 'Fun', '😂', ['joke', 'funny', 'humor', 'laugh']);
    _reg('riddle', 'Riddler', 'Create & solve riddles', 'Fun', '🧩', ['riddle', 'puzzle', 'brain teaser']);
    _reg('game_design', 'Game Designer', 'Game design concepts', 'Fun', '🎮', ['game design', 'game idea']);
    _reg('debate', 'Debater', 'Practice debating', 'Fun', '🗣️', ['debate', 'argue', 'perspective']);
    _reg('roleplay', 'Roleplayer', 'Creative roleplay', 'Fun', '🎭', ['roleplay', 'pretend', 'character']);
    _reg('story_game', 'Story Game', 'Interactive stories', 'Fun', '📖', ['story game', 'adventure', 'choose your']);
    _reg('would_you', 'Would You Rather', 'Would you rather questions', 'Fun', '🤔', ['would you rather', 'this or that']);

    // ══════════ 📱 SOCIAL MEDIA (6) ══════════
    _reg('tweet', 'Tweet Writer', 'Write engaging tweets', 'Social', '🐦', ['tweet', 'twitter', 'post']);
    _reg('instagram', 'Instagram Caption', 'Write captions', 'Social', '📸', ['instagram', 'caption', 'insta']);
    _reg('linkedin', 'LinkedIn Posts', 'Professional posts', 'Social', '💼', ['linkedin', 'professional post']);
    _reg('youtube', 'YouTube Scripts', 'Video scripts', 'Social', '🎬', ['youtube script', 'video script']);
    _reg('tiktok', 'TikTok Ideas', 'Content ideas', 'Social', '🎵', ['tiktok', 'reel', 'short video']);
    _reg('social_strategy', 'Social Strategy', 'Social media strategy', 'Social', '📊', ['social media strategy', 'content plan']);

    // ══════════ 🔬 RESEARCH (5) ══════════
    _reg('academic', 'Academic Writer', 'Academic writing', 'Research', '🎓', ['academic', 'paper', 'thesis']);
    _reg('literature', 'Literature Review', 'Review literature', 'Research', '📚', ['literature review', 'papers']);
    _reg('hypothesis', 'Hypothesis Generator', 'Generate hypotheses', 'Research', '💡', ['hypothesis', 'theory']);
    _reg('citation', 'Citation Helper', 'Format citations', 'Research', '📎', ['citation', 'reference', 'bibliography']);
    _reg('methodology', 'Methodology Advisor', 'Research methods', 'Research', '🔬', ['methodology', 'research method']);

    // ══════════ ⚖️ LEGAL (3) ══════════
    _reg('legal_basic', 'Legal Basics', 'Basic legal info', 'Legal', '⚖️', ['legal', 'law', 'rights']);
    _reg('privacy', 'Privacy Advisor', 'Privacy & data protection', 'Legal', '🛡️', ['privacy', 'gdpr', 'data protection']);
    _reg('terms', 'Terms Writer', 'Write terms of service', 'Legal', '📜', ['terms of service', 'privacy policy']);
  }
}

class Skill {
  final String id;
  final String name;
  final String description;
  final String category;
  final String icon;
  final List<String> triggers;

  Skill({required this.id, required this.name, required this.description,
    required this.category, required this.icon, required this.triggers});
}
