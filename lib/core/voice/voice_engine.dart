import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 🎤 Voice Engine — Speech-to-Text & Text-to-Speech
class VoiceEngine extends ChangeNotifier {
  static final VoiceEngine I = VoiceEngine._();
  VoiceEngine._();

  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _available = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get available => _available;
  String get lastWords => _lastWords;

  Future<void> init() async {
    _available = await _stt.initialize();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
  }

  Future<void> startListening({Function(String)? onResult}) async {
    if (!_available) return;
    _isListening = true;
    notifyListeners();
    await _stt.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        if (result.finalResult) {
          onResult?.call(_lastWords);
        }
        notifyListeners();
      },
    );
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _stt.stop();
    notifyListeners();
  }

  Future<void> speak(String text) async {
    _isSpeaking = true;
    notifyListeners();
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    _isSpeaking = false;
    await _tts.stop();
    notifyListeners();
  }
}
