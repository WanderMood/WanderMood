import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class MorningMoodyScreen extends ConsumerStatefulWidget {
  const MorningMoodyScreen({super.key});

  @override
  ConsumerState<MorningMoodyScreen> createState() => _MorningMoodyScreenState();
}

class _MorningMoodyScreenState extends ConsumerState<MorningMoodyScreen> {
  bool _showContent = false;
  late String _greeting;
  late String _message;

  @override
  void initState() {
    super.initState();
    _setGreetingAndMessage();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });
  }

  void _setGreetingAndMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 7 && hour < 9) {
      _greeting = "Early Bird! 🌅";
      _message = "Ready to make the most of your morning? Let's plan something amazing!";
    } else if (hour >= 9 && hour < 10) {
      _greeting = "Good Morning! ☀️";
      _message = "Perfect time to plan your day's adventures!";
    } else {
      _greeting = "Hello There! 🌞";
      _message = "Let's make the rest of your day wonderful!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // Adjust gradient based on time
              DateTime.now().hour < 9 
                ? const Color(0xFFFFE4F3) // Softer pink for early morning
                : const Color(0xFFFFF0F5), // Brighter for later morning
              const Color(0xFFFFF9E3), // Warm yellow
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                _greeting,
                style: GoogleFonts.museoModerno(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF12B347),
                ),
              ).animate()
                .fadeIn(delay: const Duration(milliseconds: 300))
                .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 20),
              if (_showContent) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                ).animate()
                  .fadeIn(delay: const Duration(milliseconds: 600))
                  .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF12B347),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Start Fresh! 🌱",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate()
                  .fadeIn(delay: const Duration(milliseconds: 900))
                  .slideY(begin: 0.3, end: 0),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 