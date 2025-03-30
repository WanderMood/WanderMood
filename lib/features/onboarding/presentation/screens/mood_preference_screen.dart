import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../home/presentation/widgets/moody_character.dart';

class SwirlingGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          const Color(0xFFFFF8E1).withOpacity(0.3),
          const Color(0xFFFFF3D6).withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    for (var i = 0; i < 5; i++) {
      final startPoint = Offset(
        size.width * (0.2 + 0.15 * i),
        size.height * (0.2 + 0.1 * math.sin(i.toDouble())),
      );
      path.moveTo(startPoint.dx, startPoint.dy);
      
      path.quadraticBezierTo(
        size.width * (0.5 + 0.1 * math.cos(i.toDouble())),
        size.height * (0.5 + 0.1 * math.sin(i.toDouble())),
        size.width * (0.8 - 0.15 * i),
        size.height * (0.8 + 0.1 * math.cos(i.toDouble())),
      );
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MoodPreferenceScreen extends ConsumerStatefulWidget {
  const MoodPreferenceScreen({super.key});

  @override
  ConsumerState<MoodPreferenceScreen> createState() => _MoodPreferenceScreenState();
}

class _MoodPreferenceScreenState extends ConsumerState<MoodPreferenceScreen> with TickerProviderStateMixin {
  late final AnimationController _moodyController;
  late final AnimationController _messageController;
  late final FlutterTts _flutterTts;
  final Set<String> _selectedMoods = {};
  String _lastSelectedMood = '';

  final Map<String, String> _moodResponses = {
    'Adventurous': "Ooo Adventurous! Let's go hike a volcano!",
    'Peaceful': "Peaceful vibes? I know some serene spots!",
    'Social': "Social butterfly! I know just the places to mingle!",
    'Cultural': "Art and culture lover! Let's explore some hidden gems!",
    'Romantic': "Romance in the air! I've got some dreamy spots in mind!",
  };

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Adventurous', 'emoji': '🏃‍♂️', 'color': const Color(0xFFFF6B6B)},
    {'name': 'Peaceful', 'emoji': '🧘‍♀️', 'color': const Color(0xFF4ECDC4)},
    {'name': 'Social', 'emoji': '🎉', 'color': const Color(0xFFFFBE0B)},
    {'name': 'Cultural', 'emoji': '🎭', 'color': const Color(0xFF9B5DE5)},
    {'name': 'Romantic', 'emoji': '💑', 'color': const Color(0xFFFF70A6)},
  ];

  @override
  void initState() {
    super.initState();
    _moodyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _messageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeTts();
    _startAnimation();
  }

  void _initializeTts() async {
    _flutterTts = FlutterTts();
    
    // Get available voices
    var voices = await _flutterTts.getVoices;
    print('Available voices: $voices');
    
    // Set voice properties
    await _flutterTts.setLanguage('en-GB');  // British English
    await _flutterTts.setVoice({"name": "Daniel"});  // Try Daniel's voice
    await _flutterTts.setSpeechRate(0.9);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // Test voice
    await _flutterTts.speak("Hello, I'm Daniel. How do I sound?");
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _moodyController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _messageController.forward();
    _speakMessage();
  }

  Future<void> _speakMessage() async {
    const message = "Let's sync our vibes! What moods inspire you to explore";
    await _flutterTts.speak(message);
  }

  void _toggleMood(String mood) {
    setState(() {
      if (_selectedMoods.contains(mood)) {
        _selectedMoods.remove(mood);
        _lastSelectedMood = _selectedMoods.isEmpty ? '' : _selectedMoods.last;
      } else {
        _selectedMoods.add(mood);
        _lastSelectedMood = mood;
      }
    });
    
    // Only speak for single selection or 4+ selections
    if (_selectedMoods.length == 1) {
      _speakMoodResponse(_lastSelectedMood);
    } else if (_selectedMoods.length >= 4) {
      _speakMultipleMoodsMessage();
    }
  }

  Future<void> _speakMoodResponse(String mood) async {
    if (_moodResponses.containsKey(mood)) {
      await _flutterTts.speak(_moodResponses[mood]!);
    }
  }

  Future<void> _speakMultipleMoodsMessage() async {
    await _flutterTts.speak("Wow, you're quite the explorer! Let's mix all these vibes into something amazing!");
  }

  @override
  void dispose() {
    _moodyController.dispose();
    _messageController.dispose();
    _flutterTts.stop();
    super.dispose();
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
              Color(0xFFFFF8E1), // Warm cream yellow
              Color(0xFFFFF3D6), // Slightly darker warm yellow
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Swirl effect
              Positioned.fill(
                child: CustomPaint(
                  painter: SwirlingGradientPainter(),
                ),
              ),
              
              // Progress indicator
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5BB32A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5BB32A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    ...List.generate(3, (index) => Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )),
                  ],
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.2),
                        end: Offset.zero,
                      ).animate(_messageController),
                      child: FadeTransition(
                        opacity: _messageController,
                        child: Text(
                          'Let\'s sync our vibes! ✨',
                          style: GoogleFonts.museoModerno(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5BB32A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.2),
                        end: Offset.zero,
                      ).animate(_messageController),
                      child: FadeTransition(
                        opacity: _messageController,
                        child: Text(
                          'What moods inspire you to explore?',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _moods.length,
                        itemBuilder: (context, index) {
                          final mood = _moods[index];
                          final isSelected = _selectedMoods.contains(mood['name']);
                          return InkWell(
                            onTap: () => _toggleMood(mood['name']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected 
                                  ? Colors.white.withOpacity(0.95)
                                  : Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected 
                                    ? mood['color']
                                    : Colors.grey.withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                      ? mood['color'].withOpacity(0.4)
                                      : Colors.black.withOpacity(0.1),
                                    blurRadius: 12,
                                    spreadRadius: isSelected ? 2 : 0,
                                    offset: Offset(0, isSelected ? 2 : 4),
                                  ),
                                  if (isSelected)
                                    BoxShadow(
                                      color: mood['color'].withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          mood['emoji'],
                                          style: const TextStyle(fontSize: 32),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          mood['name'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                              ? mood['color']
                                              : Colors.black87,
                                            shadows: isSelected ? [
                                              Shadow(
                                                color: Colors.black.withOpacity(0.2),
                                                offset: const Offset(0, 1),
                                                blurRadius: 2,
                                              ),
                                            ] : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: mood['color'],
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ).animate(
                              onPlay: (controller) => controller.repeat(),
                            ).shimmer(
                              duration: const Duration(seconds: 2),
                              color: isSelected ? mood['color'].withOpacity(0.3) : Colors.transparent,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedMoods.isNotEmpty
                          ? () => context.go('/preferences/interests')
                          : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5BB32A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                        ),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Moody character
              Positioned(
                right: 20,
                bottom: MediaQuery.of(context).size.height * 0.15,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.5,
                    end: 1.0,
                  ).animate(_moodyController),
                  child: const MoodyCharacter(
                    size: 150,
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