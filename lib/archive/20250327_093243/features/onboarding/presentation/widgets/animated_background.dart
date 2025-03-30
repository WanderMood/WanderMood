import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedBackground extends StatelessWidget {
  final int pageIndex;
  final bool isActive;

  const AnimatedBackground({
    super.key,
    required this.pageIndex,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getGradientColors(),
            ),
          ),
        ).animate(target: isActive ? 1 : 0)
          .fadeIn(duration: 600.ms)
          .scale(delay: 200.ms),

        // Animated shapes
        ...List.generate(
          20,
          (index) => Positioned(
            left: (index * 50.0) % MediaQuery.of(context).size.width,
            top: (index * 60.0) % MediaQuery.of(context).size.height,
            child: _buildAnimatedShape(index),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedShape(int index) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAccentColor().withOpacity(0.1),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(),
    )
      .scale(
        duration: 3000.ms,
        curve: Curves.easeInOut,
        begin: const Offset(0.5, 0.5),
        end: const Offset(1.5, 1.5),
      )
      .fadeIn(duration: 2000.ms)
      .then()
      .fadeOut(duration: 2000.ms);
  }

  List<Color> _getGradientColors() {
    switch (pageIndex) {
      case 0: // Choose your Mood
        return [
          const Color(0xFF1A237E), // Deep blue
          const Color(0xFF7986CB), // Light blue
        ];
      case 1: // Create your Journey
        return [
          const Color(0xFF004D40), // Deep teal
          const Color(0xFF26A69A), // Light teal
        ];
      case 2: // Explore your World
        return [
          const Color(0xFF311B92), // Deep purple
          const Color(0xFF7C4DFF), // Light purple
        ];
      case 3: // Begin your Story
        return [
          const Color(0xFF1A237E), // Deep blue
          const Color(0xFF4CAF50), // Brand green
        ];
      default:
        return [
          const Color(0xFF1A237E),
          const Color(0xFF4CAF50),
        ];
    }
  }

  Color _getAccentColor() {
    switch (pageIndex) {
      case 0:
        return const Color(0xFF7986CB); // Light blue
      case 1:
        return const Color(0xFF26A69A); // Light teal
      case 2:
        return const Color(0xFF7C4DFF); // Light purple
      case 3:
        return const Color(0xFF4CAF50); // Brand green
      default:
        return const Color(0xFF4CAF50);
    }
  }
} 