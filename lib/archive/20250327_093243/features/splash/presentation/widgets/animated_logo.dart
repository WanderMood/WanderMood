import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedLogo extends StatelessWidget {
  const AnimatedLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo text with animations
        Text.rich(
          TextSpan(
            text: 'Wander',
            style: GoogleFonts.museoModerno(
              fontSize: 42,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4CAF50),
              letterSpacing: 0.5,
              height: 1.2,
            ),
            children: [
              TextSpan(
                text: 'Mood',
                style: GoogleFonts.museoModerno(
                  fontSize: 42,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50),
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: '.',
                style: GoogleFonts.museoModerno(
                  fontSize: 42,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          delay: 200.ms,
          duration: 600.ms,
          curve: Curves.easeOutBack,
        ),
        
        const SizedBox(height: 20),
        
        // Tagline with staggered animation
        Text(
          'Your mood-driven travel companion',
          style: GoogleFonts.openSans(
            fontSize: 16,
            color: const Color(0xFF4CAF50).withOpacity(0.8),
            letterSpacing: 0.5,
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          delay: 400.ms,
          duration: 400.ms,
          curve: Curves.easeOut,
        ),
      ],
    );
  }
} 