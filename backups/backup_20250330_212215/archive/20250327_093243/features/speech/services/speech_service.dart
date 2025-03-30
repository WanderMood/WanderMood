import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

final speechServiceProvider = Provider((ref) => SpeechService());

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    print('🎤 Checking microphone permission...');
    
    // Check microphone permission
    var micStatus = await Permission.microphone.status;
    print('🎤 Current microphone permission status: $micStatus');
    
    if (!micStatus.isGranted) {
      print('🎤 Microphone permission not granted');
      throw Exception('Microphone permission is required for voice input');
    }

    // For iOS, also check speech recognition permission
    if (Platform.isIOS) {
      var speechStatus = await Permission.speech.status;
      if (!speechStatus.isGranted) {
        print('🎤 Speech recognition permission not granted');
        throw Exception('Speech recognition permission is required for voice input');
      }
    }

    try {
      print('🎤 Initializing speech recognition...');
      _isInitialized = await _speechToText.initialize(
        debugLogging: true,
        onError: (errorNotification) => print('🎤 Speech recognition error: $errorNotification'),
      );
      
      if (!_isInitialized) {
        print('🎤 Failed to initialize speech recognition');
        throw Exception('Failed to initialize speech recognition');
      }
      
      print('🎤 Speech recognition initialized successfully');
      return _isInitialized;
    } catch (e) {
      print('🎤 Error initializing speech recognition: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> startListening({
    required Function(String text) onResult,
    required Function() onListeningComplete,
    Function(String error)? onError,
  }) async {
    if (!_isInitialized) {
      print('🎤 Speech service not initialized, attempting to initialize...');
      try {
        final initialized = await initialize();
        if (!initialized) {
          print('🎤 Failed to initialize speech service');
          onError?.call('Failed to initialize speech recognition');
          return;
        }
      } catch (e) {
        print('🎤 Error during initialization: $e');
        onError?.call(e.toString());
        return;
      }
    }

    try {
      print('🎤 Starting speech recognition...');
      final available = await _speechToText.hasPermission;
      print('🎤 Speech recognition permission: $available');
      
      await _speechToText.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords;
          print('🎤 Recognized words: $recognizedWords');
          if (result.finalResult) {
            print('🎤 Final result received');
            onListeningComplete();
          }
          onResult(recognizedWords);
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      );
      print('🎤 Listening started successfully');
    } catch (e) {
      print('🎤 Error starting speech recognition: $e');
      onError?.call('Error starting speech recognition: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      print('🎤 Stopping speech recognition...');
      await _speechToText.stop();
      print('🎤 Speech recognition stopped');
    } catch (e) {
      print('🎤 Error stopping speech recognition: $e');
    }
  }

  bool get isListening => _speechToText.isListening;

  bool get isAvailable => _speechToText.isAvailable;

  void dispose() {
    try {
      _speechToText.cancel();
      _speechToText.stop();
    } catch (e) {
      print('🎤 Error disposing speech recognition: $e');
    }
  }
} 