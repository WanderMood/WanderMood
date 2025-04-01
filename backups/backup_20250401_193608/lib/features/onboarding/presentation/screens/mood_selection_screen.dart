import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/moody_character.dart';
import '../../providers/preferences_provider.dart';

class MoodSelectionScreen extends ConsumerStatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  ConsumerState<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends ConsumerState<MoodSelectionScreen> {
  String? selectedMood;
  bool isAnimating = false;

  final List<Map<String, dynamic>> moods = [
    {
      'name': 'Adventurous',
      'emoji': '🌟',
      'description': 'Ready for thrilling experiences and new discoveries',
      'color': const Color(0xFFFFB199), // Coral
    },
    {
      'name': 'Relaxed',
      'emoji': '🌊',
      'description': 'Looking for peaceful and calming activities',
      'color': const Color(0xFFA4D4FF), // Sky blue
    },
    {
      'name': 'Social',
      'emoji': '🎉',
      'description': 'Want to meet people and enjoy social activities',
      'color': const Color(0xFFFFE074), // Yellow
    },
    {
      'name': 'Cultural',
      'emoji': '🎭',
      'description': 'Interested in arts, history, and local traditions',
      'color': const Color(0xFF9747FF), // Purple
    },
  ];

  void _onMoodSelected(String mood) {
    setState(() {
      selectedMood = mood;
      isAnimating = true;
    });

    // Save the selected mood using the preferences provider
    ref.read(preferencesProvider.notifier).setMood(mood);

    // Add a delay for the animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        context.go('/preferences/interests');
      }
    });
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Color(0xFF5BB32A),
                  ),
                  onPressed: () => context.go('/welcome'),
                ),
              ),
              
              // Title and Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you feeling\ntoday? 🌈',
                      style: GoogleFonts.museoModerno(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5BB32A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Choose your mood and I\'ll personalize your travel recommendations accordingly!',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Mood Selection Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: moods.length,
                  itemBuilder: (context, index) {
                    final mood = moods[index];
                    final isSelected = selectedMood == mood['name'];
                    
                    return AnimatedScale(
                      scale: isSelected && isAnimating ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: () => _onMoodSelected(mood['name']),
                        child: Container(
                          decoration: BoxDecoration(
                            color: mood['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? mood['color']
                                  : mood['color'].withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: mood['color'].withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                mood['emoji'],
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                mood['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: mood['color'],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  mood['description'],
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
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Moody Character
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 24.0, bottom: 24.0),
                  child: MoodyCharacter(
                    size: 120,
                    mood: selectedMood?.toLowerCase() ?? 'default',
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