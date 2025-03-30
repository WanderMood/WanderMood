import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/onboarding/models/onboarding_page_model.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingPageModel page;
  final bool isActive;

  const OnboardingPage({
    super.key,
    required this.page,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        Image.asset(
          page.backgroundImage,
          fit: BoxFit.cover,
        ),

        // Overlay gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: page.gradientColors,
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                
                // Title
                Text(
                  page.title,
                  style: GoogleFonts.museoModerno(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ).animate(target: isActive ? 1 : 0)
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideX(begin: -0.2, end: 0),

                const SizedBox(height: 16),

                // Description
                Text(
                  page.description,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ).animate(target: isActive ? 1 : 0)
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideX(begin: -0.2, end: 0),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 