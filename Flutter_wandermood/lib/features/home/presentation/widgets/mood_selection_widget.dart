import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'mood_tile.dart';

class MoodSelectionWidget extends StatefulWidget {
  final Set<String> selectedMoods;
  final Function(Set<String>) onMoodsChanged;
  final int maxSelections;

  const MoodSelectionWidget({
    Key? key,
    required this.selectedMoods,
    required this.onMoodsChanged,
    this.maxSelections = 3,
  }) : super(key: key);

  @override
  State<MoodSelectionWidget> createState() => _MoodSelectionWidgetState();
}

class _MoodSelectionWidgetState extends State<MoodSelectionWidget> {
  final List<Map<String, dynamic>> _firstRowMoods = [
    {
      'icon': '🏕️',
      'label': 'Adventurous',
      'color': Colors.blue.shade50,
      'borderColor': Colors.blue.shade200,
    },
    {
      'icon': '🍃',
      'label': 'Relaxed',
      'color': Colors.green.shade50,
      'borderColor': Colors.green.shade200,
    },
    {
      'icon': '💖',
      'label': 'Romantic',
      'color': Colors.pink.shade50,
      'borderColor': Colors.pink.shade200,
    },
    {
      'icon': '⚡',
      'label': 'Energetic',
      'color': Colors.yellow.shade50,
      'borderColor': Colors.yellow.shade200,
    },
    {
      'icon': '🤩',
      'label': 'Excited',
      'color': Colors.purple.shade50,
      'borderColor': Colors.purple.shade200,
    },
    {
      'icon': '☕',
      'label': 'Cozy',
      'color': Colors.brown.shade50,
      'borderColor': Colors.brown.shade200,
    },
  ];

  final List<Map<String, dynamic>> _secondRowMoods = [
    {
      'icon': '😲',
      'label': 'Surprise',
      'color': Colors.orange.shade50,
      'borderColor': Colors.orange.shade200,
    },
    {
      'icon': '🍽️',
      'label': 'Foody',
      'color': Colors.red.shade50,
      'borderColor': Colors.red.shade200,
    },
    {
      'icon': '🎉',
      'label': 'Festive',
      'color': Colors.indigo.shade50,
      'borderColor': Colors.indigo.shade200,
    },
    {
      'icon': '🧠',
      'label': 'Mind',
      'color': Colors.teal.shade50,
      'borderColor': Colors.teal.shade200,
    },
    {
      'icon': '👨‍👩‍👧‍👦',
      'label': 'Family fun',
      'color': Colors.deepPurple.shade50,
      'borderColor': Colors.deepPurple.shade200,
    },
    {
      'icon': '🌍',
      'label': 'Cultural',
      'color': Colors.cyan.shade50,
      'borderColor': Colors.cyan.shade200,
    },
  ];

  void _handleMoodSelect(String mood) {
    final newSelectedMoods = Set<String>.from(widget.selectedMoods);
    if (newSelectedMoods.contains(mood)) {
      newSelectedMoods.remove(mood);
    } else if (newSelectedMoods.length < widget.maxSelections) {
      newSelectedMoods.add(mood);
    }
    widget.onMoodsChanged(newSelectedMoods);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mood selection title
        Text(
          'How are you feeling today?',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

        const SizedBox(height: 24),

        // First row of moods
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _firstRowMoods.length,
            itemBuilder: (context, index) {
              final mood = _firstRowMoods[index];
              final isSelected = widget.selectedMoods.contains(mood['label']);
              final isEnabled = widget.selectedMoods.length < widget.maxSelections || 
                              widget.selectedMoods.contains(mood['label']);
              
              return MoodTile(
                label: mood['label'] as String,
                emoji: mood['icon'] as String,
                bgColor: mood['color'] as Color,
                isSelected: isSelected,
                isSelectionEnabled: isEnabled,
                onTap: () => _handleMoodSelect(mood['label']),
              ).animate(
                onPlay: (controller) => controller.repeat(),
              ).shimmer(
                duration: const Duration(seconds: 2),
                color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
              );
            },
          ),
        ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

        const SizedBox(height: 16),

        // Second row of moods
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _secondRowMoods.length,
            itemBuilder: (context, index) {
              final mood = _secondRowMoods[index];
              final isSelected = widget.selectedMoods.contains(mood['label']);
              final isEnabled = widget.selectedMoods.length < widget.maxSelections || 
                              widget.selectedMoods.contains(mood['label']);
              
              return MoodTile(
                label: mood['label'] as String,
                emoji: mood['icon'] as String,
                bgColor: mood['color'] as Color,
                isSelected: isSelected,
                isSelectionEnabled: isEnabled,
                onTap: () => _handleMoodSelect(mood['label']),
              ).animate(
                onPlay: (controller) => controller.repeat(),
              ).shimmer(
                duration: const Duration(seconds: 2),
                color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
              );
            },
          ),
        ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),
      ],
    );
  }
} 