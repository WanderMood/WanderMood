import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

enum TtsState { playing, stopped }

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  TtsState _ttsState = TtsState.stopped;
  
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize speech recognition
      _isInitialized = await _speechToText.initialize(
        onError: (error) => debugPrint('🎤 Speech recognition error: $error'),
        debugLogging: true,
      );

      if (!_isInitialized) {
        debugPrint('❌ Failed to initialize speech recognition');
        return;
      }

      // Configure TTS
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);

      _flutterTts.setStartHandler(() {
        debugPrint('🗣️ TTS Playing');
        _ttsState = TtsState.playing;
      });

      _flutterTts.setCompletionHandler(() {
        debugPrint('🗣️ TTS Completed');
        _ttsState = TtsState.stopped;
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('🗣️ TTS Error: $msg');
        _ttsState = TtsState.stopped;
      });

      debugPrint('✅ Speech service initialized successfully');
    } catch (e) {
      debugPrint('❌ Speech service initialization error: $e');
      _isInitialized = false;
    }
  }
  
  Future<void> startListening(Function(String) onResult) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        debugPrint('❌ Could not initialize speech service');
        return;
      }
    }

    if (_speechToText.isListening) {
      await stopListening();
      return;
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            debugPrint('🎤 Final result: ${result.recognizedWords}');
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
      debugPrint('🎤 Started listening');
    } catch (e) {
      debugPrint('❌ Error starting speech recognition: $e');
    }
  }
  
  Future<void> stopListening() async {
    await _speechToText.stop();
    debugPrint('🎤 Stopped listening');
  }
  
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    if (_ttsState == TtsState.playing) {
      await stop();
    }

    try {
      debugPrint('🗣️ TTS Playing: $text');
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('❌ Error speaking text: $e');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _ttsState = TtsState.stopped;
  }

  bool get isListening => _speechToText.isListening;
  bool get isSpeaking => _ttsState == TtsState.playing;
  
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
  }
} 