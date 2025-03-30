import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wandermood/features/places/models/place.dart';
import 'package:wandermood/features/places/services/google_places_service.dart';
import 'package:wandermood/features/recommendations/services/openai_service.dart';
import 'package:wandermood/features/recommendations/services/recommendation_service.dart';
import 'package:wandermood/core/config/env.dart';

final openAIServiceProvider = Provider((ref) {
  return OpenAIService(apiKey: Env.openAIKey);
});

final googlePlacesServiceProvider = Provider((ref) {
  return GooglePlacesService(apiKey: Env.googlePlacesKey);
});

final recommendationServiceProvider = Provider((ref) {
  final placesService = ref.watch(googlePlacesServiceProvider);
  final openAIService = ref.watch(openAIServiceProvider);
  
  return RecommendationService(
    openAIService: openAIService,
    placesService: placesService,
  );
});

final recommendationProvider = StateNotifierProvider<RecommendationNotifier, AsyncValue<List<Place>>>((ref) {
  final recommendationService = ref.watch(recommendationServiceProvider);
  return RecommendationNotifier(recommendationService);
});

class RecommendationNotifier extends StateNotifier<AsyncValue<List<Place>>> {
  final RecommendationService _recommendationService;
  
  RecommendationNotifier(this._recommendationService) : super(const AsyncValue.data([]));

  Future<void> generateRecommendations({
    required String mood,
    required String location,
    String timeOfDay = '',  // Can be derived from DateTime
    String weather = '',    // Can be fetched from weather service
  }) async {
    try {
      state = const AsyncValue.loading();
      
      // Derive time of day if not provided
      final currentTime = DateTime.now();
      final derivedTimeOfDay = timeOfDay.isEmpty 
        ? _getTimeOfDay(currentTime)
        : timeOfDay;

      final recommendations = await _recommendationService.getMoodBasedRecommendations(
        mood: mood,
        location: location,
        timeOfDay: derivedTimeOfDay,
        weather: weather,
      );

      state = AsyncValue.data(recommendations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  String _getTimeOfDay(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  void clearRecommendations() {
    state = const AsyncValue.data([]);
  }
} 