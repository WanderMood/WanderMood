import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  late final FlutterTts _flutterTts;
  bool _isInitialized = false;

  TTSService() {
    _flutterTts = FlutterTts();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setVoice({"name": "en-us-x-sfg#female_1-local"});
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize TTS: $e');
      rethrow;
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      print('TTS not initialized');
      return;
    }

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Failed to speak: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('Failed to stop TTS: $e');
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
} 