import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../mood/application/mood_service.dart';
import '../../weather/application/weather_service.dart';
import '../domain/models/travel_recommendation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../weather/domain/models/location.dart';

part 'recommendation_service.g.dart';

@riverpod
RecommendationService recommendationService(RecommendationServiceRef ref) {
  return RecommendationService();
}

class RecommendationService {
  final _supabase = Supabase.instance.client;

  Future<List<TravelRecommendation>> getRecommendations({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 5,
  }) async {
    try {
      // Probeer eerst gecachede voorspellingen te laden
      final destinations = await _getPopularDestinations();
      final recommendations = <TravelRecommendation>[];

      for (final destination in destinations) {
        final recommendation = TravelRecommendation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: destination.name,
          description: 'Een perfecte bestemming voor je huidige stemming!',
          location: destination.name,
          imageUrl: 'https://example.com/image.jpg',
          rating: 4.5,
          tags: ['cultuur', 'natuur', 'geschiedenis'],
          price: 500.0,
        );

        recommendations.add(recommendation);
      }

      // Sorteer op rating en beperk tot gevraagd aantal
      recommendations.sort((a, b) => b.rating.compareTo(a.rating));
      return recommendations.take(limit).toList();
    } catch (e) {
      print('Error generating recommendations: $e');
      return [];
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final response = await _supabase
          .from('travel_recommendations')
          .select('is_favorite')
          .eq('id', id)
          .single();

      final currentFavorite = response['is_favorite'] as bool;

      await _supabase
          .from('travel_recommendations')
          .update({'is_favorite': !currentFavorite})
          .eq('id', id);
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }

  Future<List<TravelRecommendation>> getFavorites() async {
    try {
      final response = await _supabase
          .from('travel_recommendations')
          .select()
          .eq('is_favorite', true)
          .order('rating', ascending: false);

      return (response as List)
          .map((json) => TravelRecommendation.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  Future<List<TravelRecommendation>> searchRecommendations(String query) async {
    try {
      final response = await _supabase
          .from('travel_recommendations')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%,location.ilike.%$query%')
          .order('rating', ascending: false)
          .limit(20);

      return (response as List)
          .map((json) => TravelRecommendation.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching recommendations: $e');
      return [];
    }
  }

  Future<void> saveRecommendation(TravelRecommendation recommendation) async {
    try {
      await _supabase
          .from('travel_recommendations')
          .insert(recommendation.toJson());
    } catch (e) {
      print('Error saving recommendation: $e');
      rethrow;
    }
  }

  Future<List<Location>> _getPopularDestinations() async {
    return [
      Location(
        id: 'amsterdam',
        name: 'Amsterdam',
        latitude: 52.3676,
        longitude: 4.9041,
      ),
      Location(
        id: 'parijs',
        name: 'Parijs',
        latitude: 48.8566,
        longitude: 2.3522,
      ),
      Location(
        id: 'barcelona',
        name: 'Barcelona',
        latitude: 41.3851,
        longitude: 2.1734,
      ),
      Location(
        id: 'rome',
        name: 'Rome',
        latitude: 41.9028,
        longitude: 12.4964,
      ),
      Location(
        id: 'berlijn',
        name: 'Berlijn',
        latitude: 52.5200,
        longitude: 13.4050,
      ),
    ];
  }
} 