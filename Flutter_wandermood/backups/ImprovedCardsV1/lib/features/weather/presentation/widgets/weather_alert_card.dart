import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/weather_alert.dart';

class WeatherAlertCard extends StatelessWidget {
  final WeatherAlert alert;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const WeatherAlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.onDismiss,
  });

  Color _getSeverityColor() {
    switch (alert.severity.toLowerCase()) {
      case 'extreme':
        return Colors.red;
      case 'severe':
        return Colors.orange;
      case 'moderate':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }

  IconData _getAlertIcon() {
    switch (alert.type.toLowerCase()) {
      case 'storm':
        return Icons.flash_on;
      case 'rain':
        return Icons.beach_access;
      case 'wind':
        return Icons.air;
      case 'heat':
        return Icons.wb_sunny;
      case 'cold':
        return Icons.ac_unit;
      default:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: _getSeverityColor().withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getAlertIcon(),
                    color: _getSeverityColor(),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _getSeverityColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onDismiss != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onDismiss,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                alert.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Van ${DateFormat('HH:mm').format(alert.startTime)} tot ${DateFormat('HH:mm').format(alert.endTime)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 