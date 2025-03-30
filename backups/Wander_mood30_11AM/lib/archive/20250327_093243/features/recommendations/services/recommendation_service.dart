import 'package:flutter/foundation.dart';
import 'package:wandermood/features/recommendations/services/openai_service.dart';

class RecommendationService {
  final OpenAIService openAIService;

  RecommendationService({
    required this.openAIService,
  });

  Future<List<String>> getMoodBasedRecommendations({
    required String mood,
    required String location,
    required String timeOfDay,
    required String weather,
  }) async {
    try {
      // Get activity suggestions from OpenAI
      final activities = await openAIService.generateRecommendations(
        mood: mood,
        location: location,
        timeOfDay: timeOfDay,
        weather: weather,
      );

      if (activities.isEmpty) {
        debugPrint('No activities suggested by OpenAI');
        return [];
      }

      return activities;
    } catch (e) {
      debugPrint('Error getting mood-based recommendations: $e');
      return [];
    }
  }

  String _getActivityIcon(String activity) {
    switch (activity.toLowerCase()) {
      case 'restaurant':
      case 'dining':
      case 'food':
        return '🍽️';
      case 'cafe':
      case 'coffee':
        return '☕';
      case 'bar':
      case 'nightlife':
        return '🍸';
      case 'museum':
      case 'art':
      case 'culture':
        return '🏛️';
      case 'park':
      case 'nature':
        return '🌳';
      case 'shopping':
      case 'mall':
        return '🛍️';
      case 'attraction':
      case 'sightseeing':
        return '🎯';
      case 'sports':
      case 'activity':
        return '⚽';
      default:
        return '📍';
    }
  }
} 