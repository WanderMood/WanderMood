import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodyChatBubble extends StatelessWidget {
  final String? userMessage;
  final String? moodyResponse;
  final bool isListening;
  final bool isThinking;
  final VoidCallback onClose;

  const MoodyChatBubble({
    super.key,
    this.userMessage,
    this.moodyResponse,
    required this.isListening,
    required this.isThinking,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: 280,
      height: 120,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFffffff).withOpacity(0.1),
          const Color(0xFFFFFFFF).withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFffffff).withOpacity(0.5),
          const Color((0xFFFFFFFF)).withOpacity(0.5),
        ],
      ),
      child: Stack(
        children: [
          // Background animation
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
            ).animate(
              onPlay: (controller) => controller.repeat(),
            ).shimmer(
              duration: 2000.ms,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Moody',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onClose,
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (isListening)
                  _buildListeningAnimation()
                else if (isThinking)
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Thinking...',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                else if (userMessage != null)
                  Text(
                    userMessage!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  )
                else if (moodyResponse != null)
                  Text(
                    moodyResponse!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 200.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
      .slideY(begin: 0.2, end: 0);
  }

  Widget _buildListeningAnimation() {
    return Row(
      children: [
        ...List.generate(3, (index) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(),
            delay: Duration(milliseconds: index * 200),
          ).scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.2, 1.2),
            duration: 600.ms,
            curve: Curves.easeInOut,
          ).fade(
            begin: 0.3,
            end: 1.0,
            duration: 600.ms,
            curve: Curves.easeInOut,
          );
        }),
        const SizedBox(width: 8),
        Text(
          'Listening...',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
} 