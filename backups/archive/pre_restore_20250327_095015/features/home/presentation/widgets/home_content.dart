import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'moody_scene_widget.dart';
import 'mood_grid_widget.dart';

class HomeContent extends StatefulWidget {
  final Set<String> selectedMoods;
  final Function(String) onMoodSelected;
  final VoidCallback onGeneratePress;

  const HomeContent({
    super.key,
    required this.selectedMoods,
    required this.onMoodSelected,
    required this.onGeneratePress,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _generateButtonController;
  late Animation<double> _generateButtonAnimation;

  @override
  void initState() {
    super.initState();
    _generateButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _generateButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _generateButtonController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _generateButtonController.dispose();
    super.dispose();
  }

  void _handleVoiceInputTap() {
    setState(() {
      _isListening = !_isListening;
    });
    // TODO: Implement voice input functionality
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFAFF4), // Pink
            Color(0xFFFFF5AF), // Light yellow
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar with Location and Profile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hamburger Menu
                  GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.menu,
                        color: Color(0xFF12B347),
                        size: 24,
                      ),
                    ),
                  ),
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Rotterdam, Netherlands',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Moody Scene
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MoodySceneWidget(),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MoodGridWidget(
                        selectedMoods: widget.selectedMoods,
                        onMoodSelected: widget.onMoodSelected,
                      ),

                      const SizedBox(height: 24),

                      // Voice Input Button
                      GestureDetector(
                        onTap: _handleVoiceInputTap,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: _isListening ? Colors.green : Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Voice Input',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: _isListening ? Colors.green : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Generate Button
                      Center(
                        child: ElevatedButton(
                          onPressed: widget.selectedMoods.isNotEmpty 
                            ? () async {
                                await _generateButtonController.forward();
                                await _generateButtonController.reverse();
                                widget.onGeneratePress();
                              }
                            : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.selectedMoods.isNotEmpty ? const Color(0xFF12B347) : Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: widget.selectedMoods.isNotEmpty ? 4 : 0,
                            animationDuration: const Duration(milliseconds: 200),
                          ),
                          child: ScaleTransition(
                            scale: _generateButtonAnimation,
                            child: Text(
                              'Generate Plan',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: widget.selectedMoods.isNotEmpty ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 