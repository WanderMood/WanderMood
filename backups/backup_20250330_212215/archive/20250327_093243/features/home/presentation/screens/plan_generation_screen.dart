import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../widgets/moody_character.dart';

class PlanGenerationScreen extends StatefulWidget {
  final String selectedMood; // This contains comma-separated moods
  final String location;

  const PlanGenerationScreen({
    super.key,
    required this.selectedMood,
    required this.location,
  });

  @override
  State<PlanGenerationScreen> createState() => _PlanGenerationScreenState();
}

class _PlanGenerationScreenState extends State<PlanGenerationScreen> {
  int _currentStep = 0;
  final List<String> _generationSteps = [
    'Blending your moods together...',
    'Checking weather conditions in Rotterdam...',
    'Creating your perfect mood mix...',
    'Finding balanced activities for day and night...',
    'Adding personalized recommendations...',
    'Almost ready with your perfect plan!',
  ];

  final List<String> _moodyMoods = [
    'excited',      // For blending moods - enthusiastic and happy
    'listening',    // For checking weather - attentive
    'celebrating',  // For creating mood mix - joyful
    'excited',      // For finding activities - energetic
    'speaking',     // For adding recommendations - engaging
    'celebrating',  // For almost ready - happy finish
  ];

  List<String> get selectedMoods => widget.selectedMood.split(',');

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  Future<void> _startGeneration() async {
    for (int i = 0; i < _generationSteps.length; i++) {
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 1500));
        setState(() {
          _currentStep = i;
        });
      }
    }
    
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 1000));
      context.go('/explore');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A4A24)),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFC8E6C9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Selected moods at top
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: selectedMoods.map((mood) =>
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          mood,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A4A24),
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Moody character
              MoodyCharacter(
                size: 120,
                mood: _moodyMoods[_currentStep],
              ).animate(
                onPlay: (controller) => controller.repeat(),
              ).scale(
                duration: 2.seconds,
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
              ),

              const Spacer(),

              // Current step text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _generationSteps[_currentStep],
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A4A24),
                  ),
                  textAlign: TextAlign.center,
                ).animate(
                  key: ValueKey(_currentStep),
                ).fadeIn(duration: 400.ms),
              ),

              const Spacer(),

              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white.withOpacity(0.3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _generationSteps.length,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Step counter
              Text(
                'Step ${_currentStep + 1} of ${_generationSteps.length}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF1A4A24).withOpacity(0.8),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
} 