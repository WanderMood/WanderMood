import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'moody_character.dart';

class MoodySceneWidget extends StatefulWidget {
  const MoodySceneWidget({super.key});

  @override
  State<MoodySceneWidget> createState() => _MoodySceneWidgetState();
}

class _MoodySceneWidgetState extends State<MoodySceneWidget> {
  bool _isListening = false;
  String _currentMood = 'idle';

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning sunshine 🌞\nReady to explore a vibe?";
    } else if (hour < 17) {
      return "Good afternoon friend ☀️\nLet's find your perfect vibe!";
    } else if (hour < 21) {
      return "Good evening star ⭐\nTime for some evening vibes?";
    } else {
      return "Hey night owl 🌙\nLet's discover your mood!";
    }
  }

  void _handleTap() {
    setState(() {
      if (_currentMood == 'idle') {
        _currentMood = 'speaking';
      } else {
        _currentMood = 'idle';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Scene
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                // Water surface
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 140,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),

                // Animated clouds
                Positioned(
                  left: 20,
                  top: 40,
                  child: _buildCloud()
                    .animate(onPlay: (controller) => controller.repeat())
                    .moveX(
                      begin: -50,
                      end: MediaQuery.of(context).size.width,
                      duration: 20.seconds,
                      curve: Curves.linear,
                    ),
                ),

                // Trees
                Positioned(
                  left: 20,
                  bottom: 100,
                  child: _buildTree(),
                ),
                Positioned(
                  left: 50,
                  bottom: 100,
                  child: _buildTree(),
                ),

                // Stars
                ..._buildStars(),
              ],
            ),
          ),

          // Speech bubble
          Positioned(
            top: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ).animate().fadeIn(duration: 600.ms),

          // Moody character
          Positioned(
            bottom: -20,
            left: 0,
            right: 0,
            child: MoodyCharacter(
              size: 140,
              mood: _currentMood,
              onTap: _handleTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloud() {
    return Container(
      width: 60,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget _buildTree() {
    return Container(
      width: 40,
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF2E7D32),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
  }

  List<Widget> _buildStars() {
    return List.generate(
      5,
      (index) => Positioned(
        top: 20.0 + (index * 30),
        right: 20.0 + (index * 40),
        child: Icon(
          Icons.star,
          color: Colors.yellow[300],
          size: 20,
        ).animate(
          onPlay: (controller) => controller.repeat(),
        ).scale(
          duration: 1.seconds,
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
        ),
      ),
    );
  }
} 