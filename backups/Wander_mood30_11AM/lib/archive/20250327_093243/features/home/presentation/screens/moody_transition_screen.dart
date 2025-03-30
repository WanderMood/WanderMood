import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../widgets/moody_thinking_widget.dart';

class MoodyTransitionScreen extends StatefulWidget {
  final String selectedMood;

  const MoodyTransitionScreen({
    Key? key,
    required this.selectedMood,
  }) : super(key: key);

  @override
  State<MoodyTransitionScreen> createState() => _MoodyTransitionScreenState();
}

class _MoodyTransitionScreenState extends State<MoodyTransitionScreen> {
  final List<String> _travelQuotes = [
    "Hmm... Let me think about your perfect {mood} adventure...",
    "Exploring the best spots for your {mood} mood...",
    "Analyzing weather patterns for the perfect experience...",
    "Finding hidden gems that match your vibe...",
    "Almost ready to make your day amazing...",
    "Creating something special just for you...",
    "Adding final magical touches...",
  ];

  String _getMoodAdjective(String mood) {
    switch (mood.toLowerCase()) {
      case 'romantic':
        return 'romantic';
      case 'adventurous':
        return 'adventurous';
      case 'relaxed':
        return 'relaxing';
      case 'energetic':
        return 'energetic';
      case 'cultural':
        return 'cultural';
      default:
        return 'perfect';
    }
  }

  int _currentQuoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTransition();
  }

  void _startTransition() async {
    // Show each quote for about 1 second
    for (int i = 0; i < _travelQuotes.length; i++) {
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 800));
        setState(() {
          _currentQuoteIndex = i;
        });
      }
    }

    // Add final delay before navigation
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (context.mounted) {
        context.go('/planning/${widget.selectedMood}');
      }
    }
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
              Color(0xFFE8F5E9),  // Light green
              Color(0xFFC8E6C9),  // Lighter green
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Moody thinking animation
              const MoodyThinkingWidget(),

              const SizedBox(height: 40),

              // Travel quote
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SizedBox(
                  height: 80,
                  child: Text(
                    _travelQuotes[_currentQuoteIndex]
                        .replaceAll('{mood}', _getMoodAdjective(widget.selectedMood)),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A4A24),
                    ),
                    textAlign: TextAlign.center,
                  ).animate(
                    key: ValueKey(_currentQuoteIndex),
                  ).fadeIn(
                    duration: 400.milliseconds,
                  ).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 400.milliseconds,
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 