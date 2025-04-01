import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();
      
      // Set default configuration
      await _flutterTts?.setLanguage('en-US');
      await _flutterTts?.setSpeechRate(0.45);
      await _flutterTts?.setVolume(1.0);
      await _flutterTts?.setPitch(1.0);

      // Try to get available voices
      try {
        var voices = await _flutterTts?.getVoices;
        debugPrint('Available TTS voices: $voices');
        
        // Try to set a specific voice, fallback to default if fails
        try {
          await _flutterTts?.setVoice({
            "name": "en-us-x-sfg#female_1-local",
            "locale": "en-US"
          });
        } catch (e) {
          debugPrint('Failed to set specific voice, using default: $e');
        }
      } catch (e) {
        debugPrint('Failed to get voices: $e');
      }

      // Set up handlers
      _flutterTts?.setStartHandler(() {
        debugPrint('TTS Started');
        _isSpeaking = true;
      });

      _flutterTts?.setCompletionHandler(() {
        debugPrint('TTS Completed');
        _isSpeaking = false;
      });

      _flutterTts?.setErrorHandler((error) {
        debugPrint('TTS Error: $error');
        _isSpeaking = false;
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS Initialization Error: $e');
      _isInitialized = false;
    }
  }

  Future<bool> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isSpeaking) {
      await stop();
    }

    try {
      var result = await _flutterTts?.speak(text);
      return result == 1;
    } catch (e) {
      debugPrint('TTS Speak Error: $e');
      return false;
    }
  }

  Future<bool> stop() async {
    try {
      var result = await _flutterTts?.stop();
      _isSpeaking = false;
      return result == 1;
    } catch (e) {
      debugPrint('TTS Stop Error: $e');
      return false;
    }
  }

  void dispose() {
    _flutterTts?.stop();
    _isInitialized = false;
    _isSpeaking = false;
  }

  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
} 