import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/moody_character.dart';
import '../../providers/preferences_provider.dart';

class TravelInterestsScreen extends ConsumerStatefulWidget {
  const TravelInterestsScreen({super.key});

  @override
  ConsumerState<TravelInterestsScreen> createState() => _TravelInterestsScreenState();
}

class _TravelInterestsScreenState extends ConsumerState<TravelInterestsScreen> with TickerProviderStateMixin {
  late final AnimationController _moodyController;
  late final AnimationController _messageController;
  late final FlutterTts _flutterTts;
  final Set<String> selectedInterests = {};
  bool isAnimating = false;

  final List<Map<String, dynamic>> interests = [
    {
      'name': 'Nature',
      'emoji': '🌿',
      'description': 'Parks, gardens, and outdoor spaces',
      'color': const Color(0xFF5BB32A), // Green
    },
    {
      'name': 'Food',
      'emoji': '🍜',
      'description': 'Local cuisine and dining experiences',
      'color': const Color(0xFFFFB199), // Coral
    },
    {
      'name': 'Art',
      'emoji': '🎨',
      'description': 'Museums, galleries, and street art',
      'color': const Color(0xFF9747FF), // Purple
    },
    {
      'name': 'Shopping',
      'emoji': '🛍️',
      'description': 'Markets, boutiques, and malls',
      'color': const Color(0xFFFFE074), // Yellow
    },
    {
      'name': 'History',
      'emoji': '🏛️',
      'description': 'Historical sites and landmarks',
      'color': const Color(0xFFA4D4FF), // Sky blue
    },
    {
      'name': 'Nightlife',
      'emoji': '🌙',
      'description': 'Bars, clubs, and entertainment',
      'color': const Color(0xFF9747FF), // Purple
    },
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
    try {
      _flutterTts = FlutterTts();
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
    } catch (e) {
      debugPrint('TTS Initialization Error: $e');
    }
  }

  void _startAnimation() {
    _moodyController.forward();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
      }
    });
  }

  void _onContinue() {
    if (selectedInterests.isEmpty) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select at least one interest',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isAnimating = true);

    // Save selected interests
    ref.read(preferencesProvider.notifier).setInterests(selectedInterests.toList());

    // Navigate to next screen with animation delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        context.go('/preferences/location');
      }
    });
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
              Color(0xFFFFFDF5), // Warm cream yellow
              Color(0xFFFFF3E0), // Slightly darker warm yellow
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    const LinearProgressIndicator(
                      value: 0.5, // 50% progress
                      backgroundColor: Color(0xFFE8E8E8),
                      color: Color(0xFF5BB32A),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'What interests you\nthe most? 🎯',
                      style: GoogleFonts.museoModerno(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5BB32A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your travel interests and I\'ll find the perfect spots for you!',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Interest cards
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: interests.length,
                        itemBuilder: (context, index) {
                          final interest = interests[index];
                          final isSelected = selectedInterests.contains(interest['name']);
                          
                          return AnimatedScale(
                            scale: isSelected && isAnimating ? 0.95 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: GestureDetector(
                              onTap: () => _toggleInterest(interest['name']),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: interest['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? interest['color']
                                        : interest['color'].withOpacity(0.3),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: interest['color'].withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          interest['emoji'],
                                          style: const TextStyle(fontSize: 40),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          interest['name'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: interest['color'],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            interest['description'],
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black54,
                                              height: 1.3,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: interest['color'],
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
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onContinue,
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
                bottom: MediaQuery.of(context).size.height * 0.08,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.5,
                    end: 1.0,
                  ).animate(_moodyController),
                  child: MoodyCharacter(
                    size: 80,
                    mood: selectedInterests.isEmpty ? 'default' : 'happy',
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