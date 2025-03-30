import 'package:flutter/foundation.dart';
import 'package:wandermood/features/places/models/place.dart';
import 'package:wandermood/features/places/services/google_places_service.dart';
import 'package:wandermood/features/recommendations/services/openai_service.dart';

class RecommendationService {
  final OpenAIService openAIService;
  final GooglePlacesService placesService;

  RecommendationService({
    required this.openAIService,
    required this.placesService,
  });

  Future<List<Place>> getMoodBasedRecommendations({
    required String mood,
    required String location,
    required String timeOfDay,
    required String weather,
  }) async {
    try {
      // Step 1: Get activity suggestions from OpenAI
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

      // Step 2: Search places for each activity type
      final List<Place> allPlaces = [];
      
      for (final activity in activities) {
        final searchResult = await placesService.searchPlaces(
          query: activity,
          city: location,
          radius: 5000,
        );

        // Step 3: Enhance place descriptions with OpenAI
        final enhancedPlaces = await Future.wait(
          searchResult.places.map((place) async {
            final enhancedDescription = await openAIService.generatePlaceDescription(
              placeName: place.name,
              placeTypes: place.types,
              userMood: mood,
            );

            return place.copyWith(
              description: enhancedDescription ?? place.description,
              activities: [...place.activities, activity],
            );
          }),
        );

        allPlaces.addAll(enhancedPlaces);
      }

      // Step 4: Sort and deduplicate places
      final uniquePlaces = _removeDuplicates(allPlaces);
      return _sortByRelevance(uniquePlaces);
    } catch (e) {
      debugPrint('Error getting mood-based recommendations: $e');
      return [];
    }
  }

  List<Place> _removeDuplicates(List<Place> places) {
    final seen = <String>{};
    return places.where((place) => seen.add(place.id)).toList();
  }

  List<Place> _sortByRelevance(List<Place> places) {
    return places
      ..sort((a, b) {
        // Sort by rating first
        final ratingCompare = (b.rating ?? 0).compareTo(a.rating ?? 0);
        if (ratingCompare != 0) return ratingCompare;

        // Then by number of activities
        return b.activities.length.compareTo(a.activities.length);
      });
  }
} 