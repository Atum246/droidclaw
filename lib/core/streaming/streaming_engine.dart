import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../providers/ai_provider_manager.dart';

/// 📡 Streaming Engine — Real-Time Token Streaming
/// Makes the agent feel alive by showing words as they're generated
class StreamingEngine extends ChangeNotifier {
  static final StreamingEngine I = StreamingEngine._();
  StreamingEngine._();

  final StreamController<StreamChunk> _chunks = StreamController.broadcast();
  final StreamController<StreamSession> _sessions = StreamController.broadcast();
  bool _isStreaming = false;
  String _currentBuffer = '';
  StreamSession? _currentSession;

  bool get isStreaming => _isStreaming;
  String get currentBuffer => _currentBuffer;
  Stream<StreamChunk> get chunks => _chunks.stream;
  Stream<StreamSession> get sessions => _sessions.stream;
  StreamSession? get currentSession => _currentSession;

  /// Stream a response from the AI provider
  Future<String> streamResponse({
    required List<Map<String, dynamic>> messages,
    required String modelId,
    List<Map<String, dynamic>>? tools,
    void Function(String token)? onToken,
    void Function(String fullText)? onComplete,
    void Function(String error)? onError,
  }) async {
    _isStreaming = true;
    _currentBuffer = '';
    _currentSession = StreamSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startedAt: DateTime.now(),
    );
    _sessions.add(_currentSession!);
    notifyListeners();

    final buffer = StringBuffer();

    try {
      final provider = AIProviderManager.I;

      // Use the provider's streaming capability if available
      await for (final chunk in provider.chatStream(
        modelId: modelId,
        messages: messages,
        tools: tools ?? [],
      )) {
        if (chunk.isToken) {
          buffer.write(chunk.content);
          _currentBuffer = buffer.toString();

          final streamChunk = StreamChunk(
            content: chunk.content,
            isToken: true,
            timestamp: DateTime.now(),
          );
          _chunks.add(streamChunk);
          onToken?.call(chunk.content);
          notifyListeners();
        } else if (chunk.isToolCall) {
          final streamChunk = StreamChunk(
            content: chunk.content,
            isToolCall: true,
            toolName: chunk.toolName,
            timestamp: DateTime.now(),
          );
          _chunks.add(streamChunk);
        }
      }

      final result = buffer.toString();
      _currentSession?.completedAt = DateTime.now();
      _currentSession?.finalText = result;
      onComplete?.call(result);
      _isStreaming = false;
      notifyListeners();
      return result;

    } catch (e) {
      _currentSession?.error = e.toString();
      onError?.call(e.toString());
      _isStreaming = false;
      notifyListeners();
      return buffer.toString();
    }
  }

  /// Cancel current stream
  void cancel() {
    _isStreaming = false;
    _currentSession?.cancelled = true;
    notifyListeners();
  }

  void dispose_session() {
    _currentSession = null;
    _currentBuffer = '';
  }
}

class StreamChunk {
  final String content;
  final bool isToken;
  final bool isToolCall;
  final String? toolName;
  final DateTime timestamp;

  StreamChunk({
    required this.content,
    this.isToken = false,
    this.isToolCall = false,
    this.toolName,
    required this.timestamp,
  });
}

class StreamSession {
  final String id;
  final DateTime startedAt;
  DateTime? completedAt;
  String? finalText;
  String? error;
  bool cancelled = false;

  StreamSession({required this.id, required this.startedAt});

  Duration? get duration => completedAt?.difference(startedAt);
  bool get isActive => completedAt == null && !cancelled;
}
