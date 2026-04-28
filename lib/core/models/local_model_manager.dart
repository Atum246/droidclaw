import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../ui/theme/droid_theme.dart';

/// 📥 Local Model Manager — Download & manage phone-capable AI models
class LocalModelManager extends ChangeNotifier {
  static final LocalModelManager I = LocalModelManager._();
  LocalModelManager._();

  late SharedPreferences _prefs;
  final Map<String, LocalModel> _models = {};
  final Map<String, double> _downloadProgress = {};
  String? _activeLocalModel;

  List<LocalModel> get models => _models.values.toList();
  List<LocalModel> get downloaded => _models.values.where((m) => m.downloaded).toList();
  Map<String, double> get downloadProgress => _downloadProgress;
  String? get activeLocalModel => _activeLocalModel;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _registerAvailableModels();
    _loadState();
  }

  void _registerAvailableModels() {
    final available = [
      // ═══ Google Gemma ═══
      LocalModel(id: 'gemma-3-1b', name: 'Gemma 3 1B', family: 'Gemma', size: '800MB',
        description: 'Ultra-lightweight, runs on any phone', quantization: 'Q4_K_M',
        ramRequired: '2GB', downloadUrl: 'https://huggingface.co/google/gemma-3-1b-it-GGUF/resolve/main/gemma-3-1b-it-Q4_K_M.gguf',
        capabilities: ['text'], icon: '🔵'),
      LocalModel(id: 'gemma-3-4b', name: 'Gemma 3 4B', family: 'Gemma', size: '2.5GB',
        description: 'Great balance of quality and speed', quantization: 'Q4_K_M',
        ramRequired: '4GB', downloadUrl: 'https://huggingface.co/google/gemma-3-4b-it-GGUF/resolve/main/gemma-3-4b-it-Q4_K_M.gguf',
        capabilities: ['text', 'code'], icon: '🔵'),
      LocalModel(id: 'gemma-3-12b', name: 'Gemma 3 12B', family: 'Gemma', size: '7GB',
        description: 'High quality, needs flagship phone', quantization: 'Q4_K_M',
        ramRequired: '8GB', downloadUrl: 'https://huggingface.co/google/gemma-3-12b-it-GGUF/resolve/main/gemma-3-12b-it-Q4_K_M.gguf',
        capabilities: ['text', 'code', 'reasoning'], icon: '🔵'),
      LocalModel(id: 'gemma-3-27b', name: 'Gemma 3 27B', family: 'Gemma', size: '16GB',
        description: 'Best Gemma, needs 16GB+ RAM', quantization: 'Q4_K_M',
        ramRequired: '16GB', downloadUrl: 'https://huggingface.co/google/gemma-3-27b-it-GGUF/resolve/main/gemma-3-27b-it-Q4_K_M.gguf',
        capabilities: ['text', 'code', 'reasoning', 'vision'], icon: '🔵'),

      // ═══ Meta Llama ═══
      LocalModel(id: 'llama-3.2-1b', name: 'Llama 3.2 1B', family: 'Llama', size: '700MB',
        description: 'Meta\'s smallest model, very fast', quantization: 'Q4_K_M',
        ramRequired: '2GB', downloadUrl: 'https://huggingface.co/hf-internal-testing/llama-3.2-1b-Instruct-GGUF/resolve/main/llama-3.2-1b-Instruct-Q4_K_M.gguf',
        capabilities: ['text'], icon: '🦙'),
      LocalModel(id: 'llama-3.2-3b', name: 'Llama 3.2 3B', family: 'Llama', size: '2GB',
        description: 'Compact and capable', quantization: 'Q4_K_M',
        ramRequired: '4GB', downloadUrl: 'https://huggingface.co/hf-internal-testing/llama-3.2-3b-Instruct-GGUF/resolve/main/llama-3.2-3b-Instruct-Q4_K_M.gguf',
        capabilities: ['text', 'code'], icon: '🦙'),
      LocalModel(id: 'llama-3.1-8b', name: 'Llama 3.1 8B', family: 'Llama', size: '4.7GB',
        description: 'Excellent all-round model', quantization: 'Q4_K_M',
        ramRequired: '6GB', downloadUrl: 'https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf',
        capabilities: ['text', 'code'], icon: '🦙'),

      // ═══ Microsoft Phi ═══
      LocalModel(id: 'phi-4-mini', name: 'Phi-4 Mini', family: 'Phi', size: '2.4GB',
        description: 'Microsoft\'s efficient small model', quantization: 'Q4_K_M',
        ramRequired: '4GB', downloadUrl: 'https://huggingface.co/bartowski/Phi-4-mini-instruct-GGUF/resolve/main/Phi-4-mini-instruct-Q4_K_M.gguf',
        capabilities: ['text', 'code', 'math'], icon: '🟦'),
      LocalModel(id: 'phi-3.5-mini', name: 'Phi-3.5 Mini', family: 'Phi', size: '2.3GB',
        description: 'Great reasoning for its size', quantization: 'Q4_K_M',
        ramRequired: '4GB', downloadUrl: 'https://huggingface.co/bartowski/Phi-3.5-mini-instruct-GGUF/resolve/main/Phi-3.5-mini-instruct-Q4_K_M.gguf',
        capabilities: ['text', 'code'], icon: '🟦'),

      // ═══ Qwen ═══
      LocalModel(id: 'qwen2.5-0.5b', name: 'Qwen 2.5 0.5B', family: 'Qwen', size: '400MB',
        description: 'Tiniest model, runs everywhere', quantization: 'Q4_K_M',
        ramRequired: '1GB', downloadUrl: 'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf',
        capabilities: ['text'], icon: '🟤'),
      LocalModel(id: 'qwen2.5-1.5b', name: 'Qwen 2.5 1.5B', family: 'Qwen', size: '1GB',
        description: 'Small but powerful', quantization: 'Q4_K_M',
        ramRequired: '2GB', downloadUrl: 'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf',
        capabilities: ['text', 'code'], icon: '🟤'),
      LocalModel(id: 'qwen2.5-3b', name: 'Qwen 2.5 3B', family: 'Qwen', size: '2GB',
        description: 'Great for coding tasks', quantization: 'Q4_K_M',
        ramRequired: '4GB', downloadUrl: 'https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf',
        capabilities: ['text', 'code'], icon: '🟤'),
      LocalModel(id: 'qwen2.5-7b', name: 'Qwen 2.5 7B', family: 'Qwen', size: '4.5GB',
        description: 'Excellent coding model', quantization: 'Q4_K_M',
        ramRequired: '6GB', downloadUrl: 'https://huggingface.co/Qwen/Qwen2.5-7B-Instruct-GGUF/resolve/main/qwen2.5-7b-instruct-q4_k_m.gguf',
        capabilities: ['text', 'code', 'math'], icon: '🟤'),

      // ═══ Mistral ═══
      LocalModel(id: 'mistral-7b', name: 'Mistral 7B', family: 'Mistral', size: '4.1GB',
        description: 'Fast and efficient', quantization: 'Q4_K_M',
        ramRequired: '6GB', downloadUrl: 'https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf',
        capabilities: ['text', 'code'], icon: '🟠'),
      LocalModel(id: 'mistral-nemo-12b', name: 'Mistral Nemo 12B', family: 'Mistral', size: '7GB',
        description: 'Mistral\'s best small model', quantization: 'Q4_K_M',
        ramRequired: '8GB', downloadUrl: 'https://huggingface.co/bartowski/Mistral-Nemo-Instruct-2407-GGUF/resolve/main/Mistral-Nemo-Instruct-2407-Q4_K_M.gguf',
        capabilities: ['text', 'code', 'tools'], icon: '🟠'),

      // ═══ DeepSeek ═══
      LocalModel(id: 'deepseek-r1-1.5b', name: 'DeepSeek R1 1.5B', family: 'DeepSeek', size: '1.1GB',
        description: 'Tiny reasoning model', quantization: 'Q4_K_M',
        ramRequired: '2GB', downloadUrl: 'https://huggingface.co/bartowski/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B-Q4_K_M.gguf',
        capabilities: ['text', 'reasoning'], icon: '🔷'),
      LocalModel(id: 'deepseek-r1-7b', name: 'DeepSeek R1 7B', family: 'DeepSeek', size: '4.5GB',
        description: 'Strong reasoning in small package', quantization: 'Q4_K_M',
        ramRequired: '6GB', downloadUrl: 'https://huggingface.co/bartowski/DeepSeek-R1-Distill-Qwen-7B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf',
        capabilities: ['text', 'code', 'reasoning'], icon: '🔷'),

      // ═══ SmolLM ═══
      LocalModel(id: 'smollm2-1.7b', name: 'SmolLM2 1.7B', family: 'SmolLM', size: '1GB',
        description: 'HuggingFace\'s tiny powerhouse', quantization: 'Q4_K_M',
        ramRequired: '2GB', downloadUrl: 'https://huggingface.co/bartowski/SmolLM2-1.7B-Instruct-GGUF/resolve/main/SmolLM2-1.7B-Instruct-Q4_K_M.gguf',
        capabilities: ['text'], icon: '🤗'),

      // ═══ LLaVA (Vision) ═══
      LocalModel(id: 'llava-phi-3', name: 'LLaVA Phi-3', family: 'LLaVA', size: '2.8GB',
        description: 'Vision model - understands images!', quantization: 'Q4_K_M',
        ramRequired: '4GB', downloadUrl: 'https://huggingface.co/bartowski/llava-phi-3-mini-GGUF/resolve/main/llava-phi-3-mini-Q4_K_M.gguf',
        capabilities: ['text', 'vision'], icon: '👁️'),
    ];

    for (var m in available) {
      _models[m.id] = m;
    }
  }

  void _loadState() {
    final downloaded = _prefs.getStringList('downloaded_models') ?? [];
    for (var id in downloaded) {
      if (_models.containsKey(id)) {
        _models[id] = _models[id]!.copyWith(downloaded: true);
      }
    }
    _activeLocalModel = _prefs.getString('active_local_model');
  }

  Future<void> downloadModel(String modelId) async {
    final model = _models[modelId];
    if (model == null) return;

    _downloadProgress[modelId] = 0.0;
    notifyListeners();

    // Simulate download progress (real implementation would use dio with progress)
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      _downloadProgress[modelId] = i / 100;
      notifyListeners();
    }

    _models[modelId] = model.copyWith(downloaded: true);
    _downloadProgress.remove(modelId);

    final downloaded = _prefs.getStringList('downloaded_models') ?? [];
    if (!downloaded.contains(modelId)) {
      downloaded.add(modelId);
      await _prefs.setStringList('downloaded_models', downloaded);
    }

    notifyListeners();
  }

  Future<void> deleteModel(String modelId) async {
    _models[modelId] = _models[modelId]!.copyWith(downloaded: false);
    final downloaded = _prefs.getStringList('downloaded_models') ?? [];
    downloaded.remove(modelId);
    await _prefs.setStringList('downloaded_models', downloaded);
    if (_activeLocalModel == modelId) {
      _activeLocalModel = null;
      await _prefs.remove('active_local_model');
    }
    notifyListeners();
  }

  Future<void> setActiveLocalModel(String modelId) async {
    _activeLocalModel = modelId;
    await _prefs.setString('active_local_model', modelId);
    notifyListeners();
  }

  Future<void> importFromUrl(String url, String name) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    _models[id] = LocalModel(
      id: id, name: name, family: 'Custom', size: 'Unknown',
      description: 'Imported from URL', quantization: 'Unknown',
      ramRequired: 'Unknown', downloadUrl: url,
      capabilities: ['text'], icon: '📥', downloaded: true,
    );
    final downloaded = _prefs.getStringList('downloaded_models') ?? [];
    downloaded.add(id);
    await _prefs.setStringList('downloaded_models', downloaded);
    notifyListeners();
  }

  Future<void> importFromFile(String filePath, String name) async {
    final id = 'imported_${DateTime.now().millisecondsSinceEpoch}';
    _models[id] = LocalModel(
      id: id, name: name, family: 'Imported', size: 'Unknown',
      description: 'Imported from file: $filePath', quantization: 'Unknown',
      ramRequired: 'Unknown', downloadUrl: '',
      capabilities: ['text'], icon: '📁', downloaded: true, localPath: filePath,
    );
    final downloaded = _prefs.getStringList('downloaded_models') ?? [];
    downloaded.add(id);
    await _prefs.setStringList('downloaded_models', downloaded);
    notifyListeners();
  }
}

class LocalModel {
  final String id; final String name; final String family; final String size;
  final String description; final String quantization; final String ramRequired;
  final String downloadUrl; final List<String> capabilities; final String icon;
  final bool downloaded; final String? localPath;

  LocalModel({required this.id, required this.name, required this.family, required this.size,
    required this.description, required this.quantization, required this.ramRequired,
    required this.downloadUrl, required this.capabilities, required this.icon,
    this.downloaded = false, this.localPath});

  LocalModel copyWith({bool? downloaded, String? localPath}) => LocalModel(
    id: id, name: name, family: family, size: size, description: description,
    quantization: quantization, ramRequired: ramRequired, downloadUrl: downloadUrl,
    capabilities: capabilities, icon: icon, downloaded: downloaded ?? this.downloaded,
    localPath: localPath ?? this.localPath);
}
