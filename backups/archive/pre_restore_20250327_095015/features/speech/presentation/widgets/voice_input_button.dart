import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import '../../services/speech_service.dart';

class VoiceInputButton extends ConsumerStatefulWidget {
  final Function(String text) onTextRecognized;
  final Function(bool isListening)? onListeningStateChanged;
  final String hintText;

  const VoiceInputButton({
    super.key,
    required this.onTextRecognized,
    this.onListeningStateChanged,
    this.hintText = 'Tap to speak your mood...',
  });

  @override
  ConsumerState<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends ConsumerState<VoiceInputButton> {
  bool _isListening = false;
  String _recognizedText = '';
  bool _isInitializing = false;

  void _updateListeningState(bool isListening) {
    setState(() => _isListening = isListening);
    widget.onListeningStateChanged?.call(isListening);
  }

  Future<void> _showPermissionInstructions() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Access Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('To use voice features, please:'),
            const SizedBox(height: 16),
            const Text('1. Open your iPhone Settings'),
            const Text('2. Go to Privacy & Security'),
            const Text('3. Tap on Microphone'),
            const Text('4. Find WanderMood in the list'),
            const Text('5. Toggle WanderMood ON'),
            const SizedBox(height: 16),
            const Text('After enabling the permission, return to WanderMood and try again.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK, I\'ll do it'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAndRequestPermissions() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      // Check microphone permission
      var micStatus = await Permission.microphone.status;
      print('🎤 Current microphone permission status: $micStatus');
      
      if (micStatus.isDenied) {
        micStatus = await Permission.microphone.request();
        print('🎤 New microphone permission status: $micStatus');
      }

      // For iOS, also check speech recognition permission
      if (Platform.isIOS) {
        var speechStatus = await Permission.speech.status;
        if (speechStatus.isDenied) {
          speechStatus = await Permission.speech.request();
        }
        
        if (speechStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied || !micStatus.isGranted) {
          if (mounted) {
            await _showPermissionInstructions();
          }
          return;
        }
      }

      if (!micStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable microphone access to use voice input'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Initialize speech service
      final speechService = ref.read(speechServiceProvider);
      await speechService.initialize();
      
      // Start listening
      await _toggleListening();
    } catch (e) {
      print('🎤 Error checking permissions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _toggleListening() async {
    final speechService = ref.read(speechServiceProvider);

    if (!_isListening) {
      _updateListeningState(true);
      _recognizedText = '';

      await speechService.startListening(
        onResult: (text) {
          setState(() => _recognizedText = text);
        },
        onListeningComplete: () {
          _updateListeningState(false);
          if (_recognizedText.isNotEmpty) {
            widget.onTextRecognized(_recognizedText);
          }
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } else {
      await speechService.stopListening();
      _updateListeningState(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _checkAndRequestPermissions,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isListening ? Colors.blue.withOpacity(0.2) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              size: 32,
              color: _isListening ? Colors.blue : Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isListening ? 'Listening...' : widget.hintText,
          style: TextStyle(
            color: _isListening ? Colors.blue : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        if (_recognizedText.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _recognizedText,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
} 