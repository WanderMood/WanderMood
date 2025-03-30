import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecognitionService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      debugPrint('❌ Microphone permission denied');
      return false;
    }
    
    // Initialize speech to text
    _isInitialized = await _speechToText.initialize(
      onError: (error) => debugPrint('🎤 Error: $error'),
      debugLogging: true,
    );
    
    return _isInitialized;
  }
  
  Future<void> startListening({
    required Function(String text) onResult,
    required VoidCallback onListeningComplete,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }
    
    await _speechToText.listen(
      onResult: (result) {
        final recognizedWords = result.recognizedWords;
        if (result.finalResult) {
          onListeningComplete();
          debugPrint('🎤 Final result: $recognizedWords');
        }
        onResult(recognizedWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }
  
  Future<void> stopListening() async {
    await _speechToText.stop();
  }
  
  bool get isListening => _speechToText.isListening;
  
  void dispose() {
    _speechToText.cancel();
  }
} 