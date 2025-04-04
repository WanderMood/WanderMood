import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wandermood/features/home/presentation/widgets/moody_character.dart';
import 'package:wandermood/features/plans/domain/providers/plan_generation_provider.dart';

class PlanGenerationScreen extends ConsumerStatefulWidget {
  final List<String> selectedMoods;

  const PlanGenerationScreen({
    super.key,
    required this.selectedMoods,
  });

  @override
  ConsumerState<PlanGenerationScreen> createState() => _PlanGenerationScreenState();
}

class _PlanGenerationScreenState extends ConsumerState<PlanGenerationScreen> {
  final List<String> _moodyMoods = ['thinking', 'excited', 'speaking'];
  final List<String> _loadingMessages = [
    'Analyzing your moods...',
    'Finding the perfect places...',
    'Creating your personalized plan...',
    'Adding some magic touches...',
    'Almost ready...',
  ];
  
  int _currentStep = 0;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startPlanGeneration();
  }

  Future<void> _startPlanGeneration() async {
    // Start the plan generation process
    await ref.read(planGenerationProvider.notifier).generatePlan(
      moods: widget.selectedMoods,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.2),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Selected moods at top
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.selectedMoods.map((mood) =>
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Chip(
                          label: Text(
                            mood,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A4A24),
                            ),
                          ),
                          backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    // Moody character
                    MoodyCharacter(
                      size: 150,
                      mood: _moodyMoods[_currentStep % _moodyMoods.length],
                    ).animate(
                      onPlay: (controller) => controller.repeat(),
                    ).scale(
                      duration: 2.seconds,
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.05, 1.05),
                    ),

                    const SizedBox(height: 40),

                    // Loading message
                    SizedBox(
                      height: 60,
                      child: Text(
                        _loadingMessages[_currentStep % _loadingMessages.length],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A4A24),
                        ),
                        textAlign: TextAlign.center,
                      ).animate(
                        onPlay: (controller) => controller.repeat(),
                      ).fadeIn(
                        duration: 600.ms,
                      ).then()
                      .fadeOut(
                        duration: 400.ms,
                        delay: 2.seconds,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF4CAF50),
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_progress * 100).toInt()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 