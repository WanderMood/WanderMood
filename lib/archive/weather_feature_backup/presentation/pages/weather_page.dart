import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/weather_card.dart';
import '../widgets/weather_history_chart.dart';
import '../widgets/weather_forecast_card.dart';
import '../widgets/location_selector.dart';
import '../../application/weather_service.dart' hide Location;
import '../../domain/models/weather_data.dart';
import '../../domain/models/weather_forecast.dart';
import '../../domain/models/location.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';
import 'package:wandermood/features/weather/application/weather_service.dart';
import 'package:wandermood/features/weather/domain/models/weather.dart';

class WeatherPage extends ConsumerWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherServiceProvider);

    return weatherAsync.when(
      data: (weather) {
        if (weather == null) {
          return const Center(
            child: Text('No weather data available'),
          );
        }

        return Column(
          children: [
            Text(
              '${weather.temperature.toStringAsFixed(1)}°C',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              weather.condition,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              weather.location.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading weather data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(weatherServiceProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
} 