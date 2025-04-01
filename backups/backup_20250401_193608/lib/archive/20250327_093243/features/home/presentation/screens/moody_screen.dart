import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/moody_character.dart';
import '../widgets/moody_ai_widget.dart';
import '../../services/speech_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'sleeping_moody_screen.dart';
import 'moody_planning_screen.dart';

class MoodyScreen extends ConsumerStatefulWidget {
  const MoodyScreen({super.key});

  @override
  ConsumerState<MoodyScreen> createState() => _MoodyScreenState();
}

class _MoodyScreenState extends ConsumerState<MoodyScreen> {
  final _speechService = SpeechService();
  bool _isSpeaking = false;
  bool _isListening = false;
  String _moodyResponse = '';
  bool _isNewUser = false;
  String _selectedMood = 'adventurous'; // Default mood

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _checkUserState();
  }

  Future<void> _initializeSpeech() async {
    await _speechService.initialize();
  }

  Future<void> _checkUserState() async {
    // TODO: Implement check if user is new from your state management
    setState(() {
      _isNewUser = false;
    });
  }

  Widget _buildMeetMoody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFAFF4), // Pink
            Color(0xFFFFF5AF), // Light yellow
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MoodyCharacter(
              size: 150,
              mood: 'happy',
            ),
            const SizedBox(height: 32),
            Text(
              'Meet Moody!',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Your personal AI travel companion who helps plan your perfect day based on your mood!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isNewUser = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Get Started!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final hour = now.hour;
    
    if (_isNewUser) {
      return _buildMeetMoody();
    }
    
    if (hour >= 23 || hour < 6) {
      return const SleepingMoodyScreen();
    }
    
    return MoodyPlanningScreen(selectedMood: _selectedMood);
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }
} 