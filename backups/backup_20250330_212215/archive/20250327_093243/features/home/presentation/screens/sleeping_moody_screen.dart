import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../widgets/moody_character.dart';

class SleepingMoodyScreen extends StatelessWidget {
  const SleepingMoodyScreen({super.key});

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
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Moon background
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ).animate()
                    .fadeIn(duration: 800.ms)
                    .scale(delay: 200.ms),
                  // Sleeping Moody
                  const MoodyCharacter(
                    size: 120,
                    mood: 'relaxed',
                  ).animate()
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 0.2, end: 0, delay: 200.ms),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Shh... Moody is sleeping 🌙',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ).animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.2, end: 0, delay: 400.ms),
              const SizedBox(height: 16),
              Text(
                'Come back between 7 AM and 12 PM\nfor your daily dose of wanderlust!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ).animate()
                .fadeIn(delay: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 600.ms),
              const SizedBox(height: 32),
              Text(
                'Want to set your wake-up mood?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ).animate()
                .fadeIn(delay: 800.ms),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/wake-up-mood'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Set Wake-up Mood 🌅',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate()
                .fadeIn(delay: 1000.ms)
                .scale(delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
} 