import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../speech/presentation/widgets/voice_input_button.dart';
import '../widgets/moody_character.dart';
import '../widgets/glass_chat_box.dart';
import '../widgets/moody_ai_widget.dart';

class WakeUpMoodVoiceScreen extends ConsumerStatefulWidget {
  const WakeUpMoodVoiceScreen({super.key});

  @override
  ConsumerState<WakeUpMoodVoiceScreen> createState() => _WakeUpMoodVoiceScreenState();
}

class _WakeUpMoodVoiceScreenState extends ConsumerState<WakeUpMoodVoiceScreen> {
  String? _recognizedMood;
  bool _isProcessing = false;
  bool _isListening = false;

  Future<void> _handleVoiceInput(String text) async {
    setState(() {
      _isProcessing = true;
      _recognizedMood = text;
    });

    // Process the voice input to extract the mood
    final mood = _processMoodFromText(text);
    
    if (mood != null) {
      // Save the mood
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('wake_up_mood', mood);
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wake-up mood set to: $mood'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back
        context.pop();
      }
    } else {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not understand the mood. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isProcessing = false;
    });
  }

  String? _processMoodFromText(String text) {
    final lowercaseText = text.toLowerCase();
    
    // Define mood keywords
    const moodMap = {
      'energetic': ['energetic', 'energized', 'active', 'pumped', 'dynamic'],
      'peaceful': ['peaceful', 'calm', 'serene', 'tranquil', 'zen'],
      'adventurous': ['adventurous', 'excited', 'daring', 'bold', 'brave'],
      'creative': ['creative', 'inspired', 'artistic', 'imaginative', 'innovative'],
      'relaxed': ['relaxed', 'chill', 'easy', 'comfortable', 'mellow'],
    };

    // Find matching mood
    for (final entry in moodMap.entries) {
      if (entry.value.any((keyword) => lowercaseText.contains(keyword))) {
        return entry.key;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E), // Deep blue
              Color(0xFF0D47A1), // Darker blue
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tell Moody Your Wake-up Mood',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ).animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Try saying:\n"I want to wake up feeling energetic"\nor\n"Make my morning peaceful"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ).animate()
                    .fadeIn(delay: 600.ms)
                    .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 32),
                  if (_recognizedMood != null || _isProcessing) ...[
                    GlassChatBox(
                      userMessage: _recognizedMood,
                      moodyResponse: _recognizedMood != null 
                        ? "I'll help you wake up feeling ${_processMoodFromText(_recognizedMood!) ?? 'great'}! 🌅"
                        : null,
                      isProcessing: _isProcessing,
                      isListening: _isListening,
                    ),
                    const SizedBox(height: 32),
                  ],
                  VoiceInputButton(
                    onTextRecognized: _handleVoiceInput,
                    onListeningStateChanged: (isListening) {
                      setState(() {
                        _isListening = isListening;
                      });
                    },
                    hintText: 'Tap to set your wake-up mood...',
                  ).animate()
                    .fadeIn(delay: 800.ms)
                    .scale(delay: 800.ms),
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ).animate()
                    .fadeIn(delay: 1000.ms),
                ],
              ),
              
              // Floating Moody
              MoodyAIWidget(
                onTap: () {},
                onVoiceInput: (text) {
                  _handleVoiceInput(text);
                },
                isListening: _isListening,
                isSpeaking: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 