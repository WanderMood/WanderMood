import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodSelectionWidget extends StatelessWidget {
  final Set<String> selectedMoods;
  final Function(String) onMoodSelected;
  final Function() onGeneratePress;

  const MoodSelectionWidget({
    Key? key,
    required this.selectedMoods,
    required this.onMoodSelected,
    required this.onGeneratePress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling today?',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMoodChip('Happy', '😊', selectedMoods.contains('Happy')),
            _buildMoodChip('Relaxed', '😌', selectedMoods.contains('Relaxed')),
            _buildMoodChip('Energetic', '⚡', selectedMoods.contains('Energetic')),
            _buildMoodChip('Adventurous', '🌍', selectedMoods.contains('Adventurous')),
            _buildMoodChip('Peaceful', '🕊️', selectedMoods.contains('Peaceful')),
            _buildMoodChip('Creative', '🎨', selectedMoods.contains('Creative')),
          ],
        ),
        if (selectedMoods.isNotEmpty) ...[
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onGeneratePress,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Generate Plan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMoodChip(String label, String emoji, bool isSelected) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onMoodSelected(label);
        } else {
          onMoodSelected(label);
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue[100],
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: isSelected ? Colors.blue[900] : Colors.black87,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
} 