import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/widgets/moody_character.dart';
import '../../application/onboarding_service.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../widgets/swirling_gradient_painter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingLoadingScreen extends ConsumerStatefulWidget {
  const OnboardingLoadingScreen({super.key});

  @override
  ConsumerState<OnboardingLoadingScreen> createState() => _OnboardingLoadingScreenState();
}

class _OnboardingLoadingScreenState extends ConsumerState<OnboardingLoadingScreen> {
  bool _isProcessing = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _processPreferences();
  }

  Future<void> _handleContinueAnyway() async {
    // Mark preferences as complete to avoid getting stuck in the flow
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedPreferences', true);
    
    if (mounted) {
      context.go('/preferences/summary');
    }
  }

  Future<void> _processPreferences() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _hasError = false;
      _errorMessage = '';
    });

    // Use WidgetsBinding to ensure we're not in the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Get preferences safely after the build phase
        final preferences = ref.read(preferencesProvider);
        
        try {
          await ref.read(onboardingServiceProvider.notifier).processUserPreferences(
            moods: preferences.selectedMoods,
            interests: preferences.travelInterests,
            travelStyles: preferences.travelStyles,
            budget: preferences.budgetLevel,
          );

          if (mounted) {
            context.go('/preferences/summary');
          }
        } catch (e) {
          print('Error in loading screen: $e');
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = e.toString();
              _isProcessing = false;
            });
          }
        }
      } catch (e) {
        print('Error reading preferences: $e');
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Failed to read your preferences: $e';
            _isProcessing = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: SwirlingGradientPainter(),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MoodyCharacter(size: 150),
                const SizedBox(height: 30),
                Text(
                  _hasError 
                      ? 'Oops! Something went wrong'
                      : 'Creating your perfect\ntravel experience...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ).animate()
                 .fadeIn(duration: 600.ms)
                 .slideY(begin: -0.2, end: 0),
                
                const SizedBox(height: 20),
                
                if (_hasError)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'We encountered an error while processing your preferences.\nYou can try again or continue to the next screen.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 40),
                
                if (_isProcessing)
                  const CircularProgressIndicator(
                    color: Color(0xFF5BB32A),
                  )
                else if (_hasError)
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _processPreferences,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5BB32A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Try Again',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextButton(
                        onPressed: _handleContinueAnyway,
                        child: Text(
                          'Continue Anyway',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFF5BB32A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 