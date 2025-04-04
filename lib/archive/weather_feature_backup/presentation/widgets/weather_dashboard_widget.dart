import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/weather_service.dart';
import '../../domain/models/weather_data.dart';
import '../../domain/models/weather_forecast.dart';

class WeatherDashboardWidget extends ConsumerStatefulWidget {
  final Location location;

  const WeatherDashboardWidget({
    super.key,
    required this.location,
  });

  @override
  ConsumerState<WeatherDashboardWidget> createState() => _WeatherDashboardWidgetState();
}

class _WeatherDashboardWidgetState extends ConsumerState<WeatherDashboardWidget> {
  List<WeatherForecast>? _forecasts;

  @override
  void initState() {
    super.initState();
    _loadForecasts();
  }

  Future<void> _loadForecasts() async {
    try {
      final weatherService = ref.read(weatherServiceProvider.notifier);
      _forecasts = await weatherService.getWeatherForecast(
        widget.location,
        days: 3,
      );
      setState(() {});
    } catch (e) {
      print('Error loading forecasts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherServiceProvider);

    return weatherState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error) => Center(
        child: Text('Fout bij het laden van weergegevens: $error'),
      ),
      data: (currentWeather, historicalWeather) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.location.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      ref.read(weatherServiceProvider.notifier).refreshWeather();
                      _loadForecasts();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCurrentWeather(currentWeather),
              const SizedBox(height: 24),
              _buildForecast(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(WeatherData weather) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            if (weather.icon != null)
              Image.network(
                'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                width: 64,
                height: 64,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.cloud,
                  size: 64,
                ),
              ),
            Text(
              weather.conditions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        Column(
          children: [
            Text(
              '${weather.temperature.round()}°C',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Voelt als ${weather.feelsLike.round()}°C',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Column(
          children: [
            _buildWeatherDetail(
              Icons.water_drop,
              '${weather.humidity}%',
              'Vochtigheid',
            ),
            _buildWeatherDetail(
              Icons.air,
              '${weather.windSpeed} km/h',
              'Wind',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildForecast() {
    if (_forecasts == null || _forecasts!.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voorspelling',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _forecasts!.length,
            itemBuilder: (context, index) {
              final forecast = _forecasts![index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(forecast.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    if (forecast.icon != null)
                      Image.network(
                        'https://openweathermap.org/img/wn/${forecast.icon}.png',
                        width: 32,
                        height: 32,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.cloud,
                          size: 32,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${forecast.maxTemperature.round()}°',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 