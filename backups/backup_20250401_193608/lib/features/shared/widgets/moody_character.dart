import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MoodyCharacter extends StatelessWidget {
  final double size;
  final String mood;

  const MoodyCharacter({
    super.key,
    this.size = 120,
    this.mood = 'default',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Base character
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF5BB32A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5BB32A).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          )
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .moveY(
            begin: 0,
            end: -4,
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
          ),

          // Face features based on mood
          _buildFace(),
        ],
      ),
    );
  }

  Widget _buildFace() {
    switch (mood.toLowerCase()) {
      case 'happy':
        return _buildHappyFace();
      case 'excited':
        return _buildExcitedFace();
      case 'speaking':
        return _buildSpeakingFace();
      case 'thinking':
        return _buildThinkingFace();
      case 'default':
      default:
        return _buildDefaultFace();
    }
  }

  Widget _buildDefaultFace() {
    return Stack(
      children: [
        // Eyes
        Positioned(
          top: size * 0.3,
          left: size * 0.25,
          child: Container(
            width: size * 0.15,
            height: size * 0.15,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: size * 0.3,
          right: size * 0.25,
          child: Container(
            width: size * 0.15,
            height: size * 0.15,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Smile
        Positioned(
          bottom: size * 0.25,
          left: size * 0.3,
          child: Container(
            width: size * 0.4,
            height: size * 0.15,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white,
                  width: size * 0.04,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHappyFace() {
    return Stack(
      children: [
        // Happy eyes (curved lines)
        Positioned(
          top: size * 0.3,
          left: size * 0.25,
          child: Container(
            width: size * 0.15,
            height: size * 0.15,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white,
                  width: size * 0.04,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: size * 0.3,
          right: size * 0.25,
          child: Container(
            width: size * 0.15,
            height: size * 0.15,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white,
                  width: size * 0.04,
                ),
              ),
            ),
          ),
        ),
        // Big smile
        Positioned(
          bottom: size * 0.25,
          left: size * 0.2,
          child: Container(
            width: size * 0.6,
            height: size * 0.3,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white,
                  width: size * 0.04,
                ),
              ),
            ),
          ),
        ),
      ],
    )
    .animate(
      onPlay: (controller) => controller.repeat(),
    )
    .scale(
      begin: const Offset(1, 1),
      end: const Offset(1.1, 1.1),
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildExcitedFace() {
    return Stack(
      children: [
        // Sparkly eyes
        Positioned(
          top: size * 0.3,
          left: size * 0.25,
          child: Text(
            '✨',
            style: TextStyle(
              fontSize: size * 0.2,
            ),
          ),
        ),
        Positioned(
          top: size * 0.3,
          right: size * 0.25,
          child: Text(
            '✨',
            style: TextStyle(
              fontSize: size * 0.2,
            ),
          ),
        ),
        // Open smile
        Positioned(
          bottom: size * 0.25,
          left: size * 0.3,
          child: Container(
            width: size * 0.4,
            height: size * 0.2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.1),
            ),
          ),
        ),
      ],
    )
    .animate(
      onPlay: (controller) => controller.repeat(),
    )
    .shake(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildSpeakingFace() {
    return Stack(
      children: [
        // Eyes
        Positioned(
          top: size * 0.3,
          left: size * 0.25,
          child: Container(
            width: size * 0.15,
            height: size * 0.15,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: size * 0.3,
          right: size * 0.25,
          child: Container(
            width: size * 0.15,
            height: size * 0.15,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Speaking mouth
        Positioned(
          bottom: size * 0.25,
          left: size * 0.3,
          child: Container(
            width: size * 0.4,
            height: size * 0.2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.1),
            ),
          )
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .scaleY(
            begin: 0.5,
            end: 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }

  Widget _buildThinkingFace() {
    return Stack(
      children: [
        // Thinking eyes (looking up)
        Positioned(
          top: size * 0.25,
          left: size * 0.25,
          child: Container(
            width: size * 0.15,
            height: size * 0.15,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: size * 0.25,
          right: size * 0.25,
          child: Container(
            width: size * 0.15,
            height: size * 0.15,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Thinking mouth (small line)
        Positioned(
          bottom: size * 0.3,
          left: size * 0.35,
          child: Container(
            width: size * 0.3,
            height: size * 0.04,
            color: Colors.white,
          ),
        ),
        // Thinking bubble
        Positioned(
          top: size * 0.1,
          right: size * 0.1,
          child: Container(
            width: size * 0.15,
            height: size * 0.15,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          )
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.2, 1.2),
            duration: const Duration(seconds: 1),
          )
          .fadeIn(duration: const Duration(milliseconds: 300))
          .then()
          .fadeOut(duration: const Duration(milliseconds: 300)),
        ),
      ],
    );
  }
} 