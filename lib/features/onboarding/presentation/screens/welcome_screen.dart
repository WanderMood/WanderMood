import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../home/presentation/widgets/moody_character.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'package:confetti/confetti.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _controller.forward();
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _controller,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to\nWanderMood! ✨',
                          style: GoogleFonts.museoModerno(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5BB32A),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your personal travel companion that adapts to your mood and helps you discover amazing places.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _controller,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => context.go('/preferences/mood'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5BB32A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Get Started',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            'I already have an account',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: const Color(0xFF5BB32A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EnhancedSpeechTailPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final Color glowColor;
  final bool isLeft;

  EnhancedSpeechTailPainter({
    required this.color,
    required this.shadowColor,
    required this.glowColor,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    
    if (isLeft) {
      path.moveTo(size.width * 0.2, 0);
      path.quadraticBezierTo(
        0, size.height * 0.5,
        size.width * 0.5, size.height,
      );
      path.quadraticBezierTo(
        size.width, size.height * 0.5,
        size.width * 0.8, 0,
      );
    } else {
      path.moveTo(size.width * 0.8, 0);
      path.quadraticBezierTo(
        size.width, size.height * 0.5,
        size.width * 0.5, size.height,
      );
      path.quadraticBezierTo(
        0, size.height * 0.5,
        size.width * 0.2, 0,
      );
    }
    path.close();

    // Draw shadows
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path, shadowPaint);

    // Draw glow
    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path, glowPaint);

    // Draw main tail
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SwirlingGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create flowing wave gradients with maximum opacity
    final Paint wavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFFDF5).withOpacity(0.95),  // Increased from 0.8
          const Color(0xFFFFF3E0).withOpacity(0.85),  // Increased from 0.7
          const Color(0xFFFFF9E8).withOpacity(0.75),  // Increased from 0.6
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Create accent wave paint with higher opacity
    final Paint accentPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFFFFF3E0).withOpacity(0.85),  // Increased from 0.7
          const Color(0xFFFFF9E8).withOpacity(0.75),  // Increased from 0.6
          const Color(0xFFFFFDF5).withOpacity(0.65),  // Increased from 0.5
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Path mainWavePath = Path();
    final Path accentWavePath = Path();

    // Create multiple flowing wave layers with larger amplitude
    for (int i = 0; i < 3; i++) {
      double amplitude = size.height * 0.12;  // Increased from 0.08
      double frequency = math.pi / (size.width * 0.4);  // Adjusted for wider waves
      double verticalOffset = size.height * (0.2 + i * 0.3);

      mainWavePath.moveTo(0, verticalOffset);
      
      // Create more pronounced flowing wave
      for (double x = 0; x <= size.width; x += 4) {  // Decreased step for smoother waves
        double y = verticalOffset + 
                   math.sin(x * frequency + i) * amplitude +
                   math.cos(x * frequency * 0.5) * amplitude * 0.9;  // Increased from 0.7
        
        if (x == 0) {
          mainWavePath.moveTo(x, y);
        } else {
          mainWavePath.lineTo(x, y);
        }
      }

      // Create accent waves with larger amplitude
      amplitude = size.height * 0.09;  // Increased from 0.06
      verticalOffset = size.height * (0.1 + i * 0.3);
      
      for (double x = 0; x <= size.width; x += 4) {  // Decreased step for smoother waves
        double y = verticalOffset + 
                   math.sin(x * frequency * 1.5 + i + math.pi) * amplitude +
                   math.cos(x * frequency * 0.7) * amplitude * 1.2;  // Increased multiplier
        
        if (x == 0) {
          accentWavePath.moveTo(x, y);
        } else {
          accentWavePath.lineTo(x, y);
        }
      }
    }

    // Create more pronounced flowing curves
    for (int i = 0; i < 2; i++) {
      double startY = size.height * (0.3 + i * 0.4);
      double controlY = size.height * (0.1 + i * 0.4);  // Lower control point for more curve
      
      mainWavePath.moveTo(0, startY);
      mainWavePath.quadraticBezierTo(
        size.width * 0.5,
        controlY,
        size.width,
        startY
      );
    }

    // Add larger dots along the waves
    for (int i = 0; i < 15; i++) {  // Increased number of dots
      double x = size.width * (i / 15);
      double y = size.height * (0.3 + math.sin(i * 0.8) * 0.25);  // Increased amplitude
      
      canvas.drawCircle(
        Offset(x, y),
        5,  // Increased from 4
        wavePaint
      );
    }

    // Draw all elements with stronger blur effect
    canvas.drawPath(mainWavePath, wavePaint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));  // Increased from 4
    canvas.drawPath(accentWavePath, accentPaint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));  // Increased from 3
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 