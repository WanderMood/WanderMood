import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/splash/application/splash_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start de navigatie timer
    Future.microtask(() {
      ref.read(splashServiceProvider).handleSplashNavigation(context);
    });
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
              Color(0xFFFFAFF4), // Nieuwe roze kleur
              Color(0xFFFFF5AF), // Nieuwe gele kleur
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // App naam met custom styling
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
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .scale(delay: 200.ms, duration: 400.ms),

                const Spacer(flex: 2),

                // Progress indicator
                Container(
                  width: double.infinity,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                  ),
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  ),
                ).animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 