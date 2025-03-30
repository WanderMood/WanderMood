import 'package:flutter/material.dart';
import '../../domain/models/weather_data.dart';

class WeatherStatsCard extends StatelessWidget {
  final List<WeatherData> weatherHistory;
  final String title;

  const WeatherStatsCard({
    super.key,
    required this.weatherHistory,
    required this.title,
  });

  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _calculateMax(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a > b ? a : b);
  }

  double _calculateMin(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a < b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final temperatures = weatherHistory.map((w) => w.temperature).toList();
    final humidities = weatherHistory.map((w) => w.humidity.toDouble()).toList();
    final windSpeeds = weatherHistory.map((w) => w.windSpeed).toList();
    final precipitations = weatherHistory.map((w) => w.precipitation).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              context,
              'Temperatuur',
              '${_calculateAverage(temperatures).round()}°C',
              '${_calculateMin(temperatures).round()}°C',
              '${_calculateMax(temperatures).round()}°C',
              Icons.thermostat,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              'Vochtigheid',
              '${_calculateAverage(humidities).round()}%',
              '${_calculateMin(humidities).round()}%',
              '${_calculateMax(humidities).round()}%',
              Icons.water_drop,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              'Windsnelheid',
              '${_calculateAverage(windSpeeds).round()} km/h',
              '${_calculateMin(windSpeeds).round()} km/h',
              '${_calculateMax(windSpeeds).round()} km/h',
              Icons.air,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              'Neerslag',
              '${_calculateAverage(precipitations).toStringAsFixed(1)} mm',
              '${_calculateMin(precipitations).toStringAsFixed(1)} mm',
              '${_calculateMax(precipitations).toStringAsFixed(1)} mm',
              Icons.beach_access,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String average,
    String min,
    String max,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                average,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Min: $min',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Max: $max',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 