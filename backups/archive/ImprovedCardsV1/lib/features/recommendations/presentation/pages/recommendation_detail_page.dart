import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/recommendation.dart';
import '../../application/ai_recommendation_service.dart';

class RecommendationDetailPage extends ConsumerWidget {
  final Recommendation recommendation;

  const RecommendationDetailPage({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aanbeveling Details'),
        actions: [
          if (!recommendation.isCompleted)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () {
                ref
                    .read(aiRecommendationServiceProvider.notifier)
                    .markAsCompleted(recommendation.id);
                Navigator.pop(context);
              },
              tooltip: 'Markeer als voltooid',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recommendation.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  recommendation.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: recommendation.isCompleted ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  recommendation.isCompleted ? 'Voltooid' : 'Nog niet voltooid',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Beschrijving',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              recommendation.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Categorie',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(recommendation.category),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            const SizedBox(height: 24),
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recommendation.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Betrouwbaarheid',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: recommendation.confidence,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
            ),
            Text(
              '${(recommendation.confidence * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (recommendation.currentMood != null) ...[
              Text(
                'Stemming',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.mood),
                title: Text(recommendation.currentMood!.label),
                subtitle: Text(
                  'Geregistreerd op ${_formatDateTime(recommendation.currentMood!.timestamp)}',
                ),
              ),
            ],
            if (recommendation.currentWeather != null) ...[
              const SizedBox(height: 16),
              Text(
                'Weer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.wb_sunny),
                title: Text(recommendation.currentWeather!.conditions),
                subtitle: Text(
                  '${recommendation.currentWeather!.temperature}°C, ${recommendation.currentWeather!.humidity}% luchtvochtigheid',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 