import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/presentation/widgets/moody_character.dart';

class OnboardingLoadingScreen extends StatefulWidget {
  const OnboardingLoadingScreen({super.key});

  @override
  State<OnboardingLoadingScreen> createState() => _OnboardingLoadingScreenState();
}

class _OnboardingLoadingScreenState extends State<OnboardingLoadingScreen> 
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showSecondText = false;
  bool _showThirdText = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Sequence the text animations
    _animateText();
    _navigateToSummary();
  }

  Future<void> _animateText() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _showSecondText = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _showThirdText = true);
  }

  Future<void> _navigateToSummary() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      context.go('/preferences/summary');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFDF5), // Warm cream yellow
              Color(0xFFFFF3E0), // Slightly darker warm yellow
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Moody
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 10 * _controller.value),
                      child: const MoodyCharacter(size: 120),
                    );
                  },
                ),
                const SizedBox(height: 40),
                
                // Loading texts with animations
                Text(
                  'Creating your perfect travel profile...',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ).animate()
                 .fadeIn(duration: 500.ms)
                 .slideX(begin: -0.2, end: 0),
                
                if (_showSecondText)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Matching your vibes with amazing places...',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ).animate()
                     .fadeIn(duration: 500.ms)
                     .slideX(begin: 0.2, end: 0),
                  ),
                
                if (_showThirdText)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Almost ready for your adventure! ✨',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ).animate()
                     .fadeIn(duration: 500.ms)
                     .slideX(begin: -0.2, end: 0),
                  ),
                
                const SizedBox(height: 40),
                
                // Loading indicator
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF5BB32A).withOpacity(0.8),
                    ),
                    strokeWidth: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 