import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/speech_service.dart';
import '../widgets/moody_character.dart';

class MoodyAIWidget extends StatefulWidget {
  final VoidCallback onTap;
  final Function(String) onVoiceInput;
  final bool isListening;
  final bool isSpeaking;

  const MoodyAIWidget({
    super.key,
    required this.onTap,
    required this.onVoiceInput,
    required this.isListening,
    required this.isSpeaking,
  });

  @override
  State<MoodyAIWidget> createState() => _MoodyAIWidgetState();
}

class _MoodyAIWidgetState extends State<MoodyAIWidget> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  final _speechService = SpeechService();
  String _recognizedText = '';
  bool _isInitializing = false;
  bool _hasPermission = false;
  bool _showPermissionMessage = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionAndInitialize();
    });
  }

  Future<void> _checkPermissionAndInitialize() async {
    setState(() => _isInitializing = true);
    
    try {
      // Initialize speech service first
      await _speechService.initialize();
      
      // Check microphone permission
      final micStatus = await Permission.microphone.status;
      if (micStatus.isDenied) {
        final newStatus = await Permission.microphone.request();
        if (!newStatus.isGranted) {
          if (mounted) {
            setState(() {
              _hasPermission = false;
              _showPermissionMessage = true;
              _isInitializing = false;
            });
          }
          return;
        }
      }

      // Check speech recognition permission on iOS
      if (Platform.isIOS) {
        final speechStatus = await Permission.speech.status;
        if (speechStatus.isDenied) {
          final newStatus = await Permission.speech.request();
          if (!newStatus.isGranted) {
            if (mounted) {
              setState(() {
                _hasPermission = false;
                _showPermissionMessage = true;
                _isInitializing = false;
              });
            }
            return;
          }
        }
      }

      if (mounted) {
        setState(() {
          _hasPermission = true;
          _showPermissionMessage = false;
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _showPermissionMessage = true;
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _handleVoiceInputTap() async {
    if (_isInitializing) return;

    if (!_hasPermission) {
      await _checkPermissionAndInitialize();
      return;
    }

    try {
      if (_speechService.isListening) {
        await _speechService.stopListening();
        setState(() {});
        return;
      }

      await _speechService.startListening((text) {
        if (mounted) {
          setState(() => _recognizedText = text);
          widget.onVoiceInput(text);
        }
      });
      setState(() {});
    } catch (e) {
      debugPrint('Error starting voice recognition: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting voice recognition: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleMicrophoneTap() async {
    final status = await Permission.microphone.status;
    
    if (status.isPermanentlyDenied) {
      // Show settings dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Microphone Permission Required'),
            content: const Text(
              'Moody needs microphone access to hear your voice. '
              'Please enable it in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (status.isDenied) {
      final newStatus = await Permission.microphone.request();
      if (newStatus.isDenied) {
        setState(() => _showPermissionMessage = true);
        return;
      }
    }

    setState(() => _showPermissionMessage = false);
    widget.onTap();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Speech Bubble
        if (_recognizedText.isNotEmpty || widget.isSpeaking)
          Positioned(
            top: 100,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_recognizedText.isNotEmpty)
                        Text(
                          'You said: $_recognizedText',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ],
            ),
          ),

        // Moody Character
        Positioned(
          right: 16,
          top: MediaQuery.of(context).size.height * 0.15,
          child: GestureDetector(
            onTap: _handleMicrophoneTap,
            child: MoodyCharacter(
              size: 80,
              mood: widget.isListening ? 'listening' : 
                    widget.isSpeaking ? 'speaking' : 'idle',
            ),
          ),
        ),

        // Permission Message
        if (_showPermissionMessage)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Text(
                'Please allow microphone access to talk with Moody',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ).animate().fade(
              duration: 300.ms,
            ).slideY(
              begin: 1,
              end: 0,
              duration: 300.ms,
            ),
          ),
      ],
    );
  }

  Color _getButtonColor() {
    if (_isInitializing) return Colors.grey;
    if (!_hasPermission) return Colors.red;
    return _speechService.isListening ? Colors.green : Colors.white;
  }

  IconData _getButtonIcon() {
    if (_isInitializing) return Icons.hourglass_empty;
    if (!_hasPermission) return Icons.mic_off;
    return _speechService.isListening ? Icons.mic : Icons.mic_none;
  }
} 