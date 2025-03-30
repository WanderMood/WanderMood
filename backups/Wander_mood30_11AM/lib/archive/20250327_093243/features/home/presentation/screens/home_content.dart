import 'package:flutter/material.dart';
import '../widgets/mood_grid_widget.dart';
import '../widgets/compact_weather_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeContent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CompactWeatherWidget(),
                const SizedBox(height: 30),
                Text(
                  'How are you feeling today?',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A4A24),
                  ),
                ),
                const SizedBox(height: 20),
                MoodGridWidget(
                  selectedMoods: selectedMoods,
                  onMoodSelected: onMoodSelected,
                ),
                const SizedBox(height: 20),
                if (selectedMoods.isNotEmpty)
                  Center(
                    child: ElevatedButton(
                      onPressed: onGeneratePress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF12B347),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Generate',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
} 