import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:wandermood/features/mood/providers/selected_moods_provider.dart';
import 'package:wandermood/features/weather/domain/models/weather_data.dart';
import 'package:wandermood/features/home/providers/weather_provider.dart';
import 'package:wandermood/features/mood/presentation/widgets/mood_selector.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMoods = ref.watch(selectedMoodsProvider);
    final weatherAsync = ref.watch(weatherProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather section
            weatherAsync.when(
              data: (weather) => weather != null 
                ? _buildWeatherSection(weather) 
                : const SizedBox(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Failed to load weather'),
            ),

            const SizedBox(height: 24),

            // Mood selector
            Text(
              'How are you feeling today?',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            MoodSelector(
              onMoodsSelected: (moods) {
                ref.read(selectedMoodsProvider.notifier).setMoods(moods);
              },
            ),

            const SizedBox(height: 32),

            // Suggested activities
            Text(
              'Suggested Activities',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSuggestedActivities(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedActivities(BuildContext context) {
    return Column(
      children: [
        _buildActivityCard(
          context,
          'Morning Yoga',
          'Start your day with energizing poses',
          'yoga',
          Icons.self_improvement,
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          context,
          'Nature Walk',
          'Enjoy a peaceful walk in the park',
          'walk',
          Icons.directions_walk,
        ),
        const SizedBox(height: 12),
        _buildActivityCard(
          context,
          'Café Visit',
          'Relax at a cozy local café',
          'cafe',
          Icons.coffee,
        ),
      ],
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    String description,
    String id,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.go('/activity/$id'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: const Color(0xFF12B347)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherSection(WeatherData weather) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.round()}°C',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (weather.feelsLike != null)
                      Text(
                        'Feels like ${weather.feelsLike?.round()}°C',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
                Image.network(
                  'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                  width: 64,
                  height: 64,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWeatherDetail('Humidity', '${weather.humidity}%'),
            _buildWeatherDetail('Wind Speed', '${weather.windSpeed} m/s'),
            if (weather.cloudiness != null)
              _buildWeatherDetail('Cloudiness', '${weather.cloudiness}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 