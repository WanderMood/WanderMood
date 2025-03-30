import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GlassChatBox extends StatelessWidget {
  final String? userMessage;
  final String? moodyResponse;
  final bool isListening;
  final bool isProcessing;

  const GlassChatBox({
    super.key,
    this.userMessage,
    this.moodyResponse,
    this.isListening = false,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userMessage != null) ...[
                _buildMessageBubble(
                  message: userMessage!,
                  isUser: true,
                ),
                const SizedBox(height: 12),
              ],
              if (isListening)
                _buildListeningIndicator()
              else if (isProcessing)
                _buildProcessingIndicator()
              else if (moodyResponse != null)
                _buildMessageBubble(
                  message: moodyResponse!,
                  isUser: false,
                ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn()
      .scale(duration: 300.ms);
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isUser,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser 
          ? Colors.white.withOpacity(0.2)
          : Colors.blue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.mood,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
            ),
          Flexible(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.mic,
          color: Colors.blue.withOpacity(0.9),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Listening...',
          style: GoogleFonts.poppins(
            color: Colors.blue.withOpacity(0.9),
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 8),
        _buildDotAnimation(),
      ],
    );
  }

  Widget _buildProcessingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Processing...',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.9),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildDotAnimation() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(),
        ).scale(
          duration: 600.ms,
          delay: Duration(milliseconds: index * 200),
          curve: Curves.easeInOut,
        );
      }),
    );
  }
} 