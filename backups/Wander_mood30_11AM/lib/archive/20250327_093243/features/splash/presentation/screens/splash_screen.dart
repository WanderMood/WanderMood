import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wandermood/features/splash/application/splash_service.dart';
import 'package:wandermood/features/splash/presentation/widgets/animated_logo.dart';
import 'package:wandermood/features/splash/presentation/widgets/wave_background.dart';

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
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFAFF4), // Pink color
                  Color(0xFFFFF5AF), // Yellow color
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ).animate()
          .fadeIn(duration: 800.ms)
          .shimmer(duration: 2000.ms, delay: 1000.ms),

          // Animated wave background
          const Positioned.fill(
            child: WaveBackground(),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Animated logo
                const AnimatedLogo(),
                
                const Spacer(flex: 2),

                // Progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
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
                        .fadeIn(delay: 400.ms, duration: 400.ms)
                        .shimmer(delay: 1000.ms),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 