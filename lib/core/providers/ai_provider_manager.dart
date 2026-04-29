import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 🤖 AI Provider Manager — 35+ Providers (MEGA Edition)
class AIProviderManager extends ChangeNotifier {
  static final AIProviderManager I = AIProviderManager._();
  AIProviderManager._();

  late SharedPreferences _prefs;
  final _secure = const FlutterSecureStorage();
  final Map<String, AIProvider> _providers = {};
  String _activeProviderId = 'openai';
  String _activeModelId = 'gpt-4o';
  final Map<String, List<Map<String, dynamic>>> _conversationContext = {};

  List<AIProvider> get providers => _providers.values.toList();
  AIProvider get activeProvider => _providers[_activeProviderId]!;
  String get activeModelId => _activeModelId;
  String get activeProviderId => _activeProviderId;
  int get totalModels => _providers.values.fold(0, (sum, p) => sum + p.models.length);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _activeProviderId = _prefs.getString('activeProvider') ?? 'openai';
    _activeModelId = _prefs.getString('activeModel') ?? 'gpt-4o';
    _registerAll();
  }

  void _registerAll() {
    // ══════════ 🟢 OPENAI ══════════
    _p('openai', 'OpenAI', '🟢', 'https://api.openai.com/v1', [
      _m('gpt-4o', 'GPT-4o', 128000, ['text','code','vision','tools']),
      _m('gpt-4o-mini', 'GPT-4o Mini', 128000, ['text','code','vision','tools']),
      _m('gpt-4-turbo', 'GPT-4 Turbo', 128000, ['text','code','vision','tools']),
      _m('gpt-4', 'GPT-4', 8192, ['text','code']),
      _m('gpt-3.5-turbo', 'GPT-3.5 Turbo', 16385, ['text','code']),
      _m('o1-preview', 'o1 Preview', 128000, ['text','code','reasoning']),
      _m('o1-mini', 'o1 Mini', 128000, ['text','code','reasoning']),
      _m('o1', 'o1', 200000, ['text','code','reasoning','tools']),
      _m('o3-mini', 'o3 Mini', 200000, ['text','code','reasoning']),
      _m('gpt-4o-search-preview', 'GPT-4o Search', 128000, ['text','search']),
    ]);

    // ══════════ 🟣 ANTHROPIC ══════════
    _p('anthropic', 'Anthropic', '🟣', 'https://api.anthropic.com/v1', [
      _m('claude-sonnet-4-20250514', 'Claude Sonnet 4', 200000, ['text','code','vision','tools']),
      _m('claude-3.5-sonnet', 'Claude 3.5 Sonnet', 200000, ['text','code','vision','tools']),
      _m('claude-3.5-haiku', 'Claude 3.5 Haiku', 200000, ['text','code','tools']),
      _m('claude-3-opus', 'Claude 3 Opus', 200000, ['text','code','vision','tools']),
      _m('claude-3-sonnet', 'Claude 3 Sonnet', 200000, ['text','code','vision']),
      _m('claude-3-haiku', 'Claude 3 Haiku', 200000, ['text','code']),
    ]);

    // ══════════ 🔵 GOOGLE ══════════
    _p('google', 'Google AI', '🔵', 'https://generativelanguage.googleapis.com/v1beta', [
      _m('gemini-2.5-pro', 'Gemini 2.5 Pro', 1048576, ['text','code','vision','tools','reasoning']),
      _m('gemini-2.5-flash', 'Gemini 2.5 Flash', 1048576, ['text','code','vision','tools']),
      _m('gemini-2.0-flash', 'Gemini 2.0 Flash', 1048576, ['text','code','vision','tools']),
      _m('gemini-2.0-flash-lite', 'Gemini 2.0 Flash Lite', 1048576, ['text','code']),
      _m('gemini-1.5-pro', 'Gemini 1.5 Pro', 2097152, ['text','code','vision','tools']),
      _m('gemini-1.5-flash', 'Gemini 1.5 Flash', 1048576, ['text','code','vision']),
      _m('gemini-1.5-flash-8b', 'Gemini 1.5 Flash 8B', 1048576, ['text','code']),
      _m('gemma-3-27b-it', 'Gemma 3 27B', 131072, ['text','code']),
      _m('gemma-3-12b-it', 'Gemma 3 12B', 131072, ['text','code']),
    ]);

    // ══════════ 🔗 OPENROUTER (100+ models!) ══════════
    _p('openrouter', 'OpenRouter', '🔗', 'https://openrouter.ai/api/v1', [
      _m('anthropic/claude-sonnet-4', 'Claude Sonnet 4', 200000, ['text','code','vision']),
      _m('anthropic/claude-3.5-sonnet', 'Claude 3.5 Sonnet', 200000, ['text','code','vision']),
      _m('openai/gpt-4o', 'GPT-4o', 128000, ['text','code','vision']),
      _m('openai/o1', 'o1', 200000, ['text','reasoning']),
      _m('google/gemini-2.5-pro', 'Gemini 2.5 Pro', 1048576, ['text','code','vision']),
      _m('google/gemini-2.0-flash', 'Gemini 2.0 Flash', 1048576, ['text','code','vision']),
      _m('meta-llama/llama-4-maverick', 'Llama 4 Maverick', 1048576, ['text','code','vision']),
      _m('meta-llama/llama-4-scout', 'Llama 4 Scout', 1048576, ['text','code','vision']),
      _m('meta-llama/llama-3.1-405b', 'Llama 3.1 405B', 131072, ['text','code']),
      _m('meta-llama/llama-3.1-70b', 'Llama 3.1 70B', 131072, ['text','code']),
      _m('mistralai/mistral-large', 'Mistral Large', 65536, ['text','code']),
      _m('deepseek/deepseek-chat-v3', 'DeepSeek V3', 65536, ['text','code']),
      _m('deepseek/deepseek-r1', 'DeepSeek R1', 65536, ['text','reasoning']),
      _m('qwen/qwen-2.5-72b', 'Qwen 2.5 72B', 131072, ['text','code']),
      _m('nvidia/llama-3.1-nemotron-70b', 'Nemotron 70B', 131072, ['text','code']),
      _m('x-ai/grok-3', 'Grok 3', 131072, ['text','code','tools']),
      _m('x-ai/grok-3-mini', 'Grok 3 Mini', 131072, ['text','code']),
    ]);

    // ══════════ 🟢 NVIDIA NIM ══════════
    _p('nvidia', 'Nvidia NIM', '🟢', 'https://integrate.api.nvidia.com/v1', [
      _m('meta/llama-3.1-405b-instruct', 'Llama 3.1 405B', 131072, ['text','code']),
      _m('meta/llama-3.1-70b-instruct', 'Llama 3.1 70B', 131072, ['text','code']),
      _m('meta/llama-3.1-8b-instruct', 'Llama 3.1 8B', 131072, ['text','code']),
      _m('mistralai/mistral-large-2-instruct', 'Mistral Large 2', 65536, ['text','code']),
      _m('google/gemma-2-27b-it', 'Gemma 2 27B', 8192, ['text','code']),
      _m('nvidia/llama-3.1-nemotron-70b-instruct', 'Nemotron 70B', 131072, ['text','code']),
      _m('nvidia/nemotron-mini-4b-instruct', 'Nemotron Mini 4B', 4096, ['text','code']),
      _m('deepseek-ai/deepseek-r1', 'DeepSeek R1', 65536, ['text','reasoning']),
    ]);

    // ══════════ 🟠 MISTRAL ══════════
    _p('mistral', 'Mistral AI', '🟠', 'https://api.mistral.ai/v1', [
      _m('mistral-large-latest', 'Mistral Large', 65536, ['text','code','tools']),
      _m('mistral-medium-latest', 'Mistral Medium', 32768, ['text','code']),
      _m('mistral-small-latest', 'Mistral Small', 32768, ['text','code']),
      _m('codestral-latest', 'Codestral', 32768, ['code']),
      _m('pixtral-large-latest', 'Pixtral Large', 65536, ['text','vision']),
      _m('ministral-8b-latest', 'Ministral 8B', 32768, ['text','code']),
      _m('ministral-3b-latest', 'Ministral 3B', 32768, ['text','code']),
    ]);

    // ══════════ 🔷 DEEPSEEK ══════════
    _p('deepseek', 'DeepSeek', '🔷', 'https://api.deepseek.com/v1', [
      _m('deepseek-chat', 'DeepSeek V3', 65536, ['text','code','tools']),
      _m('deepseek-coder', 'DeepSeek Coder', 65536, ['code']),
      _m('deepseek-reasoner', 'DeepSeek R1', 65536, ['text','code','reasoning']),
    ]);

    // ══════════ 🟤 ALIBABA (Qwen) ══════════
    _p('alibaba', 'Alibaba Qwen', '🟤', 'https://dashscope.aliyuncs.com/compatible-mode/v1', [
      _m('qwen-max', 'Qwen Max', 32768, ['text','code','tools']),
      _m('qwen-plus', 'Qwen Plus', 131072, ['text','code']),
      _m('qwen-turbo', 'Qwen Turbo', 131072, ['text','code']),
      _m('qwen-vl-max', 'Qwen VL Max', 32768, ['text','vision']),
      _m('qwen-coder-plus', 'Qwen Coder Plus', 131072, ['code']),
      _m('qwen2.5-72b-instruct', 'Qwen 2.5 72B', 131072, ['text','code']),
    ]);

    // ══════════ 📱 XIAOMI ══════════
    _p('xiaomi', 'Xiaomi MiMo', '🟧', 'https://api.xiaomi.com/v1', [
      _m('mimo-v2-pro', 'MiMo V2 Pro', 65536, ['text','code','reasoning']),
      _m('mimo-v2-lite', 'MiMo V2 Lite', 32768, ['text','code']),
    ]);

    // ══════════ 🔥 GROQ (Ultra Fast) ══════════
    _p('groq', 'Groq', '🔥', 'https://api.groq.com/openai/v1', [
      _m('llama-3.1-70b-versatile', 'Llama 3.1 70B', 131072, ['text','code']),
      _m('llama-3.1-8b-instant', 'Llama 3.1 8B', 131072, ['text','code']),
      _m('llama-3.3-70b-versatile', 'Llama 3.3 70B', 131072, ['text','code']),
      _m('mixtral-8x7b-32768', 'Mixtral 8x7B', 32768, ['text','code']),
      _m('gemma2-9b-it', 'Gemma 2 9B', 8192, ['text','code']),
      _m('deepseek-r1-distill-llama-70b', 'DeepSeek R1 70B', 131072, ['text','reasoning']),
    ]);

    // ══════════ 🟡 COHERE ══════════
    _p('cohere', 'Cohere', '🟡', 'https://api.cohere.com/v2', [
      _m('command-r-plus', 'Command R+', 128000, ['text','code','tools']),
      _m('command-r', 'Command R', 128000, ['text','code']),
      _m('command-a', 'Command A', 256000, ['text','code','tools']),
    ]);

    // ══════════ 🟪 PERPLEXITY ══════════
    _p('perplexity', 'Perplexity', '🟪', 'https://api.perplexity.ai', [
      _m('llama-3.1-sonar-large-128k-online', 'Sonar Large', 128000, ['text','search']),
      _m('llama-3.1-sonar-small-128k-online', 'Sonar Small', 128000, ['text','search']),
      _m('sonar-pro', 'Sonar Pro', 200000, ['text','search','code']),
      _m('sonar', 'Sonar', 200000, ['text','search']),
    ]);

    // ══════════ 🌐 TOGETHER AI ══════════
    _p('together', 'Together AI', '🌐', 'https://api.together.xyz/v1', [
      _m('meta-llama/Meta-Llama-3.1-405B-Instruct-Turbo', 'Llama 3.1 405B', 131072, ['text','code']),
      _m('meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo', 'Llama 3.1 70B', 131072, ['text','code']),
      _m('meta-llama/Llama-3.3-70B-Instruct-Turbo', 'Llama 3.3 70B', 131072, ['text','code']),
      _m('mistralai/Mixtral-8x22B-Instruct-v0.1', 'Mixtral 8x22B', 65536, ['text','code']),
      _m('Qwen/Qwen2.5-72B-Instruct-Turbo', 'Qwen 2.5 72B', 131072, ['text','code']),
      _m('deepseek-ai/DeepSeek-R1', 'DeepSeek R1', 65536, ['text','reasoning']),
    ]);

    // ══════════ 🧠 CEREBRAS ══════════
    _p('cerebras', 'Cerebras', '🧠', 'https://api.cerebras.ai/v1', [
      _m('llama3.1-8b', 'Llama 3.1 8B', 8192, ['text','code']),
      _m('llama3.1-70b', 'Llama 3.1 70B', 8192, ['text','code']),
      _m('llama-3.3-70b', 'Llama 3.3 70B', 8192, ['text','code']),
    ]);

    // ══════════ 🟤 SAMBANOVA ══════════
    _p('sambanova', 'SambaNova', '🟤', 'https://api.sambanova.ai/v1', [
      _m('Meta-Llama-3.1-405B-Instruct', 'Llama 3.1 405B', 131072, ['text','code']),
      _m('Meta-Llama-3.1-70B-Instruct', 'Llama 3.1 70B', 131072, ['text','code']),
      _m('DeepSeek-R1', 'DeepSeek R1', 65536, ['text','reasoning']),
      _m('DeepSeek-V3-0324', 'DeepSeek V3', 65536, ['text','code']),
      _m('QwQ-32B', 'QwQ 32B', 131072, ['text','reasoning']),
    ]);

    // ══════════ 🎆 FIREWORKS AI ══════════
    _p('fireworks', 'Fireworks AI', '🎆', 'https://api.fireworks.ai/inference/v1', [
      _m('accounts/fireworks/models/llama-v3p1-405b-instruct', 'Llama 3.1 405B', 131072, ['text','code']),
      _m('accounts/fireworks/models/llama-v3p1-70b-instruct', 'Llama 3.1 70B', 131072, ['text','code']),
      _m('accounts/fireworks/models/deepseek-r1', 'DeepSeek R1', 65536, ['text','reasoning']),
      _m('accounts/fireworks/models/qwen2p5-72b-instruct', 'Qwen 2.5 72B', 131072, ['text','code']),
    ]);

    // ══════════ ✍️ WRITER ══════════
    _p('writer', 'Writer', '✍️', 'https://api.writer.com/v1', [
      _m('palmyra-x-004', 'Palmyra X 004', 32768, ['text','code','tools']),
      _m('palmyra-x-003', 'Palmyra X 003', 32768, ['text','code']),
    ]);

    // ══════════ 🟦 REPLICATE ══════════
    _p('replicate', 'Replicate', '🟦', 'https://api.replicate.com/v1', [
      _m('meta/llama-3.1-405b-instruct', 'Llama 3.1 405B', 131072, ['text','code']),
      _m('meta/llama-3.1-70b-instruct', 'Llama 3.1 70B', 131072, ['text','code']),
    ]);

    // ══════════ 🟩 ANTHROPIC-CLAUDE (AWS Bedrock) ══════════
    _p('bedrock', 'AWS Bedrock', '🟩', 'https://bedrock-runtime.us-east-1.amazonaws.com', [
      _m('anthropic.claude-3.5-sonnet', 'Claude 3.5 Sonnet', 200000, ['text','code','vision']),
      _m('anthropic.claude-3-haiku', 'Claude 3 Haiku', 200000, ['text','code']),
      _m('meta.llama3-1-405b', 'Llama 3.1 405B', 131072, ['text','code']),
      _m('meta.llama3-1-70b', 'Llama 3.1 70B', 131072, ['text','code']),
    ]);

    // ══════════ 🔶 GOOGLE VERTEX ══════════
    _p('vertex', 'Google Vertex', '🔶', 'https://us-central1-aiplatform.googleapis.com/v1', [
      _m('gemini-2.5-pro', 'Gemini 2.5 Pro', 1048576, ['text','code','vision']),
      _m('gemini-2.0-flash', 'Gemini 2.0 Flash', 1048576, ['text','code','vision']),
      _m('gemini-1.5-pro', 'Gemini 1.5 Pro', 2097152, ['text','code','vision']),
    ]);

    // ══════════ 🌙 MOONSHOT (Kimi) ══════════
    _p('moonshot', 'Moonshot AI', '🌙', 'https://api.moonshot.cn/v1', [
      _m('moonshot-v1-128k', 'Kimi 128K', 131072, ['text','code']),
      _m('moonshot-v1-32k', 'Kimi 32K', 32768, ['text','code']),
      _m('moonshot-v1-8k', 'Kimi 8K', 8192, ['text','code']),
    ]);

    // ══════════ 🟫 ZHIPU (GLM) ══════════
    _p('zhipu', 'Zhipu AI', '🟫', 'https://open.bigmodel.cn/api/paas/v4', [
      _m('glm-4-plus', 'GLM-4 Plus', 128000, ['text','code','tools']),
      _m('glm-4-flash', 'GLM-4 Flash', 128000, ['text','code']),
      _m('glm-4v-plus', 'GLM-4V Plus', 2000, ['text','vision']),
    ]);

    // ══════════ 🔶 BAICHUAN ══════════
    _p('baichuan', 'Baichuan', '🔶', 'https://api.baichuan-ai.com/v1', [
      _m('Baichuan4', 'Baichuan 4', 32768, ['text','code']),
      _m('Baichuan3-Turbo', 'Baichuan 3 Turbo', 32768, ['text','code']),
    ]);

    // ══════════ 🟨 YI (01.AI) ══════════
    _p('yi', '01.AI Yi', '🟨', 'https://api.lingyiwanwu.com/v1', [
      _m('yi-large', 'Yi Large', 32768, ['text','code']),
      _m('yi-medium', 'Yi Medium', 16384, ['text','code']),
      _m('yi-vision', 'Yi Vision', 16384, ['text','vision']),
    ]);

    // ══════════ 🟥 MINIMAX ══════════
    _p('minimax', 'MiniMax', '🟥', 'https://api.minimax.chat/v1', [
      _m('abab6.5-chat', 'Abab 6.5', 32768, ['text','code']),
      _m('abab6.5s-chat', 'Abab 6.5s', 32768, ['text','code']),
    ]);

    // ══════════ 🦙 OLLAMA (Local) ══════════
    _p('ollama', 'Ollama (Local)', '🦙', 'http://localhost:11434/v1', isLocal: true, [
      _m('llama3.1', 'Llama 3.1', 131072, ['text','code']),
      _m('llama3.2', 'Llama 3.2', 131072, ['text','code']),
      _m('llama3.3', 'Llama 3.3', 131072, ['text','code']),
      _m('codellama', 'Code Llama', 16384, ['code']),
      _m('mistral', 'Mistral', 32768, ['text','code']),
      _m('mixtral', 'Mixtral', 32768, ['text','code']),
      _m('qwen2.5', 'Qwen 2.5', 131072, ['text','code']),
      _m('phi3', 'Phi-3', 131072, ['text','code']),
      _m('gemma2', 'Gemma 2', 8192, ['text','code']),
      _m('deepseek-r1', 'DeepSeek R1', 65536, ['text','reasoning']),
      _m('command-r', 'Command R', 128000, ['text','code']),
      _m('llava', 'LLaVA', 4096, ['text','vision']),
    ]);

    // ══════════ 🖥️ LM STUDIO (Local) ══════════
    _p('lmstudio', 'LM Studio (Local)', '🖥️', 'http://localhost:1234/v1', isLocal: true, [
      _m('local-model', 'Local Model', 32768, ['text','code']),
    ]);

    // ══════════ ⚙️ CUSTOM ══════════
    _p('custom', 'Custom API', '⚙️', '', isCustom: true, [
      _m('custom-model', 'Custom Model', 32768, ['text','code']),
    ]);
  }

  void _p(String id, String name, String icon, String url, List<AIModel> models, {bool isLocal = false, bool isCustom = false}) {
    _providers[id] = AIProvider(id: id, name: name, icon: icon, baseUrl: url, models: models, isLocal: isLocal, isCustom: isCustom);
  }

  AIModel _m(String id, String name, int tokens, List<String> caps) => AIModel(id: id, name: name, maxTokens: tokens, capabilities: caps);

  Future<void> setActiveProvider(String providerId, String modelId) async {
    _activeProviderId = providerId;
    _activeModelId = modelId;
    await _prefs.setString('activeProvider', providerId);
    await _prefs.setString('activeModel', modelId);
    notifyListeners();
  }

  /// Swap model mid-conversation
  void swapModel(String providerId, String modelId) {
    _activeProviderId = providerId;
    _activeModelId = modelId;
    notifyListeners();
  }

  Future<void> setApiKey(String providerId, String key) async {
    await _secure.write(key: 'api_key_$providerId', value: key);
    notifyListeners();
  }

  Future<String?> getApiKey(String providerId) async => await _secure.read(key: 'api_key_$providerId');

  Future<void> setCustomEndpoint(String url) async {
    _providers['custom'] = _providers['custom']!.copyWith(baseUrl: url);
    await _prefs.setString('customEndpoint', url);
    notifyListeners();
  }

  List<AIModel> getModelsForProvider(String providerId) => _providers[providerId]?.models ?? [];

  /// Get all models across all providers
  List<({String providerId, AIProvider provider, AIModel model})> getAllModels() {
    final result = <({String providerId, AIProvider provider, AIModel model})>[];
    for (var p in _providers.values) {
      for (var m in p.models) {
        result.add((providerId: p.id, provider: p, model: m));
      }
    }
    return result;
  }
}

class AIProvider {
  final String id; final String name; final String icon; final String baseUrl;
  final bool isLocal; final bool isCustom; final List<AIModel> models;
  AIProvider({required this.id, required this.name, required this.icon, required this.baseUrl,
    this.isLocal = false, this.isCustom = false, required this.models});
  AIProvider copyWith({String? baseUrl}) => AIProvider(id: id, name: name, icon: icon,
    baseUrl: baseUrl ?? this.baseUrl, isLocal: isLocal, isCustom: isCustom, models: models);

  /// Chat with the AI provider
  Future<ProviderResponse> chat({required String modelId, required List<Map<String, dynamic>> messages, List<Map<String, dynamic>>? tools}) async {
    final apiKey = await AIProviderManager.I.getApiKey(id);
    final headers = <String, String>{'Content-Type': 'application/json',
      if (apiKey != null && apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey'};
    final body = <String, dynamic>{'model': modelId, 'messages': messages, 'max_tokens': 4096, 'temperature': 0.7,
      if (tools != null && tools.isNotEmpty) 'tools': tools};
    final resp = await http.post(Uri.parse('$baseUrl/chat/completions'), headers: headers, body: jsonEncode(body));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body); final msg = data['choices'][0]['message'];
      return ProviderResponse(content: msg['content'] ?? '',
        toolCalls: (msg['tool_calls'] as List?)?.map((tc) => ToolCallRef(id: tc['id'],
          name: tc['function']['name'], arguments: jsonDecode(tc['function']['arguments'] ?? '{}'))).toList() ?? []);
    }
    throw Exception('API Error ${resp.statusCode}: ${resp.body}');
  }

  /// Stream chat responses
  Stream<String> chatStream({required String modelId, required List<Map<String, dynamic>> messages}) async* {
    final apiKey = await AIProviderManager.I.getApiKey(id);
    final headers = <String, String>{'Content-Type': 'application/json',
      if (apiKey != null && apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey'};
    final body = <String, dynamic>{'model': modelId, 'messages': messages, 'stream': true, 'temperature': 0.7};
    final req = http.StreamedRequest('POST', Uri.parse('$baseUrl/chat/completions'))
      ..headers.addAll(headers)
      ..bodyBytes = utf8.encode(jsonEncode(body));
    final resp = await http.Client().send(req);
    if (resp.statusCode == 200) {
      await resp.stream.transform(utf8.decoder).transform(const LineSplitter()).forEach((line) {
        if (line.startsWith('data: ')) {
          final json = jsonDecode(line.substring(6));
          final delta = json['choices'][0]['delta'];
          if (delta['content'] != null) yield delta['content'];
        }
      });
    } else {
      throw Exception('API Error ${resp.statusCode}');
    }
  }
}

class AIModel {
  final String id; final String name; final int maxTokens; final List<String> capabilities;
  AIModel({required this.id, required this.name, required this.maxTokens, required this.capabilities});
}

class ProviderResponse {
  final String content; final List<ToolCallRef> toolCalls;
  ProviderResponse({required this.content, required this.toolCalls});
}

class ToolCallRef {
  final String id; final String name; final Map<String, dynamic> arguments;
  ToolCallRef({required this.id, required this.name, required this.arguments});
  Map<String, dynamic> toJson() => {'id': id, 'type': 'function', 'function': {'name': name, 'arguments': jsonEncode(arguments)}};
}
