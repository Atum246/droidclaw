import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/ai_provider_manager.dart';
import '../memory/memory_engine.dart';

/// 🖼️ Multi-Modal Engine — Process Images, Voice, Files Intelligently
/// The agent can SEE, HEAR, and READ any content you throw at it
class MultiModalEngine extends ChangeNotifier {
  static final MultiModalEngine I = MultiModalEngine._();
  MultiModalEngine._();

  final List<ProcessedMedia> _history = [];
  final StreamController<MediaEvent> _events = StreamController.broadcast();

  List<ProcessedMedia> get history => List.unmodifiable(_history);
  Stream<MediaEvent> get events => _events.stream;

  /// Process an image — OCR, describe, analyze, extract data
  Future<ProcessedMedia> processImage({
    required String path,
    required String task, // 'describe', 'ocr', 'analyze', 'extract', 'identify'
    String? customPrompt,
  }) async {
    final id = const Uuid().v4();
    _events.add(MediaEvent(type: 'processing', mediaId: id, mediaType: 'image'));

    try {
      final file = File(path);
      if (!await file.exists()) {
        return ProcessedMedia(id: id, type: MediaType.image, path: path,
          error: 'File not found: $path', processedAt: DateTime.now());
      }

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      String prompt;
      switch (task) {
        case 'describe':
          prompt = 'Describe this image in detail. What do you see?';
          break;
        case 'ocr':
          prompt = 'Extract ALL text from this image. Return the text exactly as shown, preserving formatting.';
          break;
        case 'analyze':
          prompt = customPrompt ?? 'Analyze this image thoroughly. What is it? What are the key elements? What can be learned from it?';
          break;
        case 'extract':
          prompt = customPrompt ?? 'Extract all useful data from this image (text, numbers, URLs, contacts, etc). Return as structured data.';
          break;
        case 'identify':
          prompt = 'What is shown in this image? Identify objects, people, places, brands, text, etc.';
          break;
        default:
          prompt = customPrompt ?? 'Process this image and provide useful information.';
      }

      final result = await AIProviderManager.I.chat(
        modelId: AIProviderManager.I.activeModelId,
        messages: [
          {'role': 'system', 'content': 'You are a multi-modal AI. Analyze images carefully and provide detailed, useful responses.'},
          {'role': 'user', 'content': [
            {'type': 'text', 'text': prompt},
            {'type': 'image_url', 'image_url': {'url': 'data:image/${_getExtension(path)};base64,$base64Image'}},
          ]},
        ],
        tools: [],
      );

      final processed = ProcessedMedia(
        id: id,
        type: MediaType.image,
        path: path,
        task: task,
        result: result.content,
        processedAt: DateTime.now(),
      );

      _history.add(processed);

      // Save to memory
      await MemoryEngine.I.saveMemory(
        'image_${id}',
        'Image ($task): ${result.content.substring(0, result.content.length > 500 ? 500 : result.content.length)}',
        category: 'media',
      );

      _events.add(MediaEvent(type: 'completed', mediaId: id, mediaType: 'image'));
      notifyListeners();
      return processed;

    } catch (e) {
      final processed = ProcessedMedia(id: id, type: MediaType.image, path: path,
        error: 'Processing failed: $e', processedAt: DateTime.now());
      _history.add(processed);
      _events.add(MediaEvent(type: 'error', mediaId: id, mediaType: 'image', error: e.toString()));
      notifyListeners();
      return processed;
    }
  }

  /// Process a voice note — transcribe, analyze, extract intent
  Future<ProcessedMedia> processVoice({
    required String path,
    required String task, // 'transcribe', 'analyze', 'command'
    String? customPrompt,
  }) async {
    final id = const Uuid().v4();
    _events.add(MediaEvent(type: 'processing', mediaId: id, mediaType: 'voice'));

    try {
      final file = File(path);
      if (!await file.exists()) {
        return ProcessedMedia(id: id, type: MediaType.voice, path: path,
          error: 'File not found: $path', processedAt: DateTime.now());
      }

      // For now, use AI to process audio
      // In production, would use speech-to-text API
      String prompt;
      switch (task) {
        case 'transcribe':
          prompt = 'Transcribe this audio. Return the exact words spoken.';
          break;
        case 'analyze':
          prompt = customPrompt ?? 'Analyze this audio. What is being said? What is the tone? What are the key points?';
          break;
        case 'command':
          prompt = 'This is a voice command. Extract the intent and parameters. What does the user want me to do?';
          break;
        default:
          prompt = customPrompt ?? 'Process this audio and provide useful information.';
      }

      // Placeholder: In production, send audio to provider
      final result = await AIProviderManager.I.chat(
        modelId: AIProviderManager.I.activeModelId,
        messages: [
          {'role': 'system', 'content': 'You are processing an audio file. Provide useful analysis.'},
          {'role': 'user', 'content': '$prompt\n\n[Audio file: ${file.path}]'},
        ],
        tools: [],
      );

      final processed = ProcessedMedia(
        id: id,
        type: MediaType.voice,
        path: path,
        task: task,
        result: result.content,
        processedAt: DateTime.now(),
      );

      _history.add(processed);
      _events.add(MediaEvent(type: 'completed', mediaId: id, mediaType: 'voice'));
      notifyListeners();
      return processed;

    } catch (e) {
      final processed = ProcessedMedia(id: id, type: MediaType.voice, path: path,
        error: 'Processing failed: $e', processedAt: DateTime.now());
      _history.add(processed);
      notifyListeners();
      return processed;
    }
  }

  /// Process a document — PDF, text, CSV, etc.
  Future<ProcessedMedia> processDocument({
    required String path,
    required String task, // 'read', 'summarize', 'extract', 'analyze'
    String? customPrompt,
  }) async {
    final id = const Uuid().v4();
    _events.add(MediaEvent(type: 'processing', mediaId: id, mediaType: 'document'));

    try {
      final file = File(path);
      if (!await file.exists()) {
        return ProcessedMedia(id: id, type: MediaType.document, path: path,
          error: 'File not found: $path', processedAt: DateTime.now());
      }

      final content = await file.readAsString();
      final truncated = content.length > 10000 ? '${content.substring(0, 10000)}...[truncated]' : content;

      String prompt;
      switch (task) {
        case 'read':
          prompt = 'Read and return the content of this document:\n\n$truncated';
          break;
        case 'summarize':
          prompt = 'Summarize this document concisely:\n\n$truncated';
          break;
        case 'extract':
          prompt = customPrompt ?? 'Extract all key data from this document (names, dates, numbers, facts):\n\n$truncated';
          break;
        case 'analyze':
          prompt = customPrompt ?? 'Analyze this document thoroughly:\n\n$truncated';
          break;
        default:
          prompt = customPrompt ?? 'Process this document:\n\n$truncated';
      }

      final result = await AIProviderManager.I.chat(
        modelId: AIProviderManager.I.activeModelId,
        messages: [
          {'role': 'system', 'content': 'You are a document processing AI. Provide useful, structured analysis.'},
          {'role': 'user', 'content': prompt},
        ],
        tools: [],
      );

      final processed = ProcessedMedia(
        id: id,
        type: MediaType.document,
        path: path,
        task: task,
        result: result.content,
        processedAt: DateTime.now(),
      );

      _history.add(processed);

      await MemoryEngine.I.saveMemory(
        'doc_${id}',
        'Document ($task): ${result.content.substring(0, result.content.length > 500 ? 500 : result.content.length)}',
        category: 'media',
      );

      _events.add(MediaEvent(type: 'completed', mediaId: id, mediaType: 'document'));
      notifyListeners();
      return processed;

    } catch (e) {
      final processed = ProcessedMedia(id: id, type: MediaType.document, path: path,
        error: 'Processing failed: $e', processedAt: DateTime.now());
      _history.add(processed);
      notifyListeners();
      return processed;
    }
  }

  /// Process any file — auto-detect type and handle accordingly
  Future<ProcessedMedia> processAny({
    required String path,
    String? customPrompt,
  }) async {
    final ext = _getExtension(path).toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) {
      return processImage(path: path, task: 'analyze', customPrompt: customPrompt);
    } else if (['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(ext)) {
      return processVoice(path: path, task: 'analyze', customPrompt: customPrompt);
    } else {
      return processDocument(path: path, task: 'analyze', customPrompt: customPrompt);
    }
  }

  String _getExtension(String path) {
    final parts = path.split('.');
    return parts.length > 1 ? parts.last : 'unknown';
  }
}

enum MediaType { image, voice, document, video, unknown }

class ProcessedMedia {
  final String id;
  final MediaType type;
  final String path;
  final String? task;
  final String? result;
  final String? error;
  final DateTime processedAt;

  ProcessedMedia({
    required this.id,
    required this.type,
    required this.path,
    this.task,
    this.result,
    this.error,
    required this.processedAt,
  });

  bool get isSuccess => error == null && result != null;
}

class MediaEvent {
  final String type; // 'processing', 'completed', 'error'
  final String mediaId;
  final String mediaType;
  final String? error;

  MediaEvent({required this.type, required this.mediaId, required this.mediaType, this.error});
}
