import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class MoodSelector extends ConsumerStatefulWidget {
  final Function(Set<String>) onMoodsSelected;

  const MoodSelector({
    super.key,
    required this.onMoodsSelected,
  });

  @override
  ConsumerState<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends ConsumerState<MoodSelector> {
  final Set<String> _selectedMoods = {};
  static const int maxMoodSelections = 3;
  static const int minMoodSelections = 1;

  final List<MoodOption> _moods = [
    MoodOption(
      label: 'Adventurous',
      emoji: '🏔️',
      color: const Color(0xFFFF9800), // Vibrant Orange
    ),
    MoodOption(
      label: 'Relaxed',
      emoji: '😴',
      color: const Color(0xFF2196F3), // Vibrant Blue
    ),
    MoodOption(
      label: 'Romantic',
      emoji: '❤️',
      color: const Color(0xFFE91E63), // Vibrant Pink
    ),
    MoodOption(
      label: 'Energetic',
      emoji: '⚡',
      color: const Color(0xFFFFC107), // Vibrant Yellow
    ),
    MoodOption(
      label: 'Excited',
      emoji: '🎉',
      color: const Color(0xFF9C27B0), // Vibrant Purple
    ),
    MoodOption(
      label: 'Surprise',
      emoji: '🍔',
      color: const Color(0xFF00BCD4), // Vibrant Cyan
    ),
    MoodOption(
      label: 'Foody',
      emoji: '🎈',
      color: const Color(0xFFFF5722), // Vibrant Deep Orange
    ),
    MoodOption(
      label: 'Festive',
      emoji: '🎈',
      color: const Color(0xFF8BC34A), // Vibrant Light Green
    ),
    MoodOption(
      label: 'Mindful',
      emoji: '🌱',
      color: const Color(0xFF4CAF50), // Vibrant Green
    ),
    MoodOption(
      label: 'Family fun',
      emoji: '👨‍👩‍👧‍👦',
      color: const Color(0xFF3F51B5), // Vibrant Indigo
    ),
    MoodOption(
      label: 'Creative',
      emoji: '💡',
      color: const Color(0xFFFFEB3B), // Vibrant Light Yellow
    ),
    MoodOption(
      label: 'Luxurious',
      emoji: '💎',
      color: const Color(0xFF673AB7), // Vibrant Deep Purple
    ),
  ];

  void _toggleMood(String mood) {
    setState(() {
      if (_selectedMoods.contains(mood)) {
        _selectedMoods.remove(mood);
      } else if (_selectedMoods.length < maxMoodSelections) {
        _selectedMoods.add(mood);
      } else {
        // Show snackbar when trying to select more than max moods
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can select up to $maxMoodSelections moods',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });

    // Notify parent about mood selection changes
    widget.onMoodsSelected(_selectedMoods);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected moods indicator
          if (_selectedMoods.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Selected moods: ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _selectedMoods.join(', '),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Grid of mood tiles
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _moods.length,
            itemBuilder: (context, index) {
              final mood = _moods[index];
              final isSelected = _selectedMoods.contains(mood.label);
              
              return GestureDetector(
                onTap: () => _toggleMood(mood.label),
                child: Container(
                  decoration: BoxDecoration(
                    color: mood.color.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? mood.color : mood.color.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: mood.color.withOpacity(0.25),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.15),
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mood.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mood.label,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Add bottom padding
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class MoodOption {
  final String label;
  final String emoji;
  final Color color;

  const MoodOption({
    required this.label,
    required this.emoji,
    required this.color,
  });
} 