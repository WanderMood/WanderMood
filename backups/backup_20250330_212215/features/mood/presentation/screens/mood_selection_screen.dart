import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  String? _selectedMood;
  final List<MoodOption> _moods = [
    MoodOption(
      emoji: '😊',
      label: 'Happy',
      color: const Color(0xFFFFD700),
      description: 'Feeling joyful and energetic',
    ),
    MoodOption(
      emoji: '😌',
      label: 'Calm',
      color: const Color(0xFF87CEEB),
      description: 'Peaceful and relaxed',
    ),
    MoodOption(
      emoji: '🤔',
      label: 'Thoughtful',
      color: const Color(0xFF9B59B6),
      description: 'Reflective and contemplative',
    ),
    MoodOption(
      emoji: '😤',
      label: 'Stressed',
      color: const Color(0xFFFF6B6B),
      description: 'Need a break',
    ),
    MoodOption(
      emoji: '😴',
      label: 'Tired',
      color: const Color(0xFF95A5A6),
      description: 'Looking for relaxation',
    ),
    MoodOption(
      emoji: '🤗',
      label: 'Grateful',
      color: const Color(0xFF2ECC71),
      description: 'Appreciative and content',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'How are you feeling today?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A7BB3),
                    ),
                  ).animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Select your mood to get personalized recommendations',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ).animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0),
                ],
              ),
            ),
            // Mood Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _moods.length,
                itemBuilder: (context, index) {
                  final mood = _moods[index];
                  final isSelected = _selectedMood == mood.label;
                  return _buildMoodCard(mood, isSelected, index);
                },
              ),
            ),
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _selectedMood != null
                    ? () => context.go('/interests')
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFF5BB32A),
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
                child: Text(
                  'Continue',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard(MoodOption mood, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = mood.label),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? mood.color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? mood.color : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: mood.color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mood.emoji,
              style: const TextStyle(fontSize: 32),
            ).animate()
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
              .then()
              .shake(duration: 300.ms),
            const SizedBox(height: 8),
            Text(
              mood.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mood.description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ).animate()
        .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: index * 100)),
    );
  }
}

class MoodOption {
  final String emoji;
  final String label;
  final Color color;
  final String description;

  MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
    required this.description,
  });
} 