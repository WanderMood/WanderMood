import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wandermood/features/mood/models/mood_based_plan.dart';
import 'package:wandermood/features/mood/providers/mood_recommendations_provider.dart';
import 'package:wandermood/features/places/screens/explore_screen.dart';

class MoodSelectionScreen extends ConsumerWidget {
  const MoodSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moods = MoodBasedPlanData.predefinedMoods;

    return Scaffold(
      appBar: AppBar(
        title: const Text('How are you feeling?'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your mood to get personalized recommendations',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: moods.length,
                itemBuilder: (context, index) {
                  final mood = moods[index];
                  return _MoodCard(
                    mood: mood,
                    onTap: () => _handleMoodSelection(context, ref, mood),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMoodSelection(BuildContext context, WidgetRef ref, MoodOption mood) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Show dialog to open settings
        if (context.mounted) {
          Navigator.of(context).pop(); // Dismiss loading dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Permission Required'),
              content: const Text('Please enable location services in your device settings to get personalized recommendations.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await Geolocator.openLocationSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Get user's current location
      final position = await Geolocator.getCurrentPosition();
      
      // Generate recommendations
      await ref.read(moodRecommendationsProvider.notifier)
          .generateRecommendations(mood.name, position);

      // Navigate to explore screen
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ExploreScreen(),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _MoodCard extends StatelessWidget {
  final MoodOption mood;
  final VoidCallback onTap;

  const _MoodCard({
    required this.mood,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mood.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                mood.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 