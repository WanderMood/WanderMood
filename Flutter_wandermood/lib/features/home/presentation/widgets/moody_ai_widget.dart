import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodyAIWidget extends StatefulWidget {
  final VoidCallback onTap;
  final bool isListening;
  final VoidCallback onVoiceInputTap;

  const MoodyAIWidget({
    super.key,
    required this.onTap,
    required this.isListening,
    required this.onVoiceInputTap,
  });

  @override
  State<MoodyAIWidget> createState() => _MoodyAIWidgetState();
}

class _MoodyAIWidgetState extends State<MoodyAIWidget> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning! Want help finding your vibe today?";
    } else if (hour < 17) {
      return "Hey there! Ready to explore?";
    } else {
      return "Wanna see what's going on tonight?";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Speech Bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              _getGreeting(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms),
          
          const SizedBox(height: 12),
          
          // Moody Character
          GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _isHovered = true),
            onTapUp: (_) => setState(() => _isHovered = false),
            onTapCancel: () => setState(() => _isHovered = false),
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Moody's face
                        Center(
                          child: Icon(
                            Icons.smart_toy,
                            size: 40,
                            color: _isHovered ? Colors.green : Colors.grey[600],
                          ),
                        ),
                        // Glow effect when hovered
                        if (_isHovered)
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.green.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 1.0],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ).animate().fadeIn(duration: 600.ms),
          
          const SizedBox(height: 12),
          
          // Voice Input Button
          GestureDetector(
            onTap: widget.onVoiceInputTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.isListening ? Colors.green : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                widget.isListening ? Icons.mic : Icons.mic_none,
                color: widget.isListening ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms),
        ],
      ),
    );
  }
} 