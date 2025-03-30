import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingContent extends StatelessWidget {
  final int pageIndex;
  final bool isActive;

  const OnboardingContent({
    super.key,
    required this.pageIndex,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _getGradientColors(),
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                _buildTitle()
                    .animate(target: isActive ? 1 : 0)
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.2, end: 0),
                const SizedBox(height: 16),
                _buildDescription()
                    .animate(target: isActive ? 1 : 0)
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideX(begin: -0.2, end: 0),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      _getTitle(),
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.1,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      _getDescription(),
      style: const TextStyle(
        fontSize: 18,
        color: Colors.white,
        height: 1.5,
      ),
    );
  }

  String _getTitle() {
    switch (pageIndex) {
      case 0:
        return 'Choose\nyour Mood';
      case 1:
        return 'Create\nyour Journey';
      case 2:
        return 'Explore\nyour World';
      case 3:
        return 'Begin\nyour Story';
      default:
        return '';
    }
  }

  String _getDescription() {
    switch (pageIndex) {
      case 0:
        return 'Let your mood guide your journey. Whether you\'re feeling adventurous, relaxed, or social, we\'ll create the perfect experience for you.';
      case 1:
        return 'Tell us where you\'re headed, and we\'ll handle the rest - custom itineraries, hidden gems, and must-do experiences based on your vibe.';
      case 2:
        return 'From local festivals to hidden gems, connect with experiences and people that match your vibe. Create memories that last forever.';
      case 3:
        return 'It\'s time to explore, connect, and experience the world - your way. Ready to dive in to Wandermood?';
      default:
        return '';
    }
  }

  List<Color> _getGradientColors() {
    switch (pageIndex) {
      case 0:
        return [
          const Color(0xFFFFAFF4), // Pink
          const Color(0xFFFFF5AF), // Yellow
        ];
      case 1:
        return [
          const Color(0xFF9CFFAF), // Light green
          const Color(0xFFAFF4FF), // Light blue
        ];
      case 2:
        return [
          const Color(0xFFAF9CFF), // Purple
          const Color(0xFFFFAFE5), // Light pink
        ];
      case 3:
        return [
          const Color(0xFF9CDFFF), // Blue
          const Color(0xFFFFCFAF), // Orange
        ];
      default:
        return [
          Colors.white,
          Colors.white,
        ];
    }
  }
} 