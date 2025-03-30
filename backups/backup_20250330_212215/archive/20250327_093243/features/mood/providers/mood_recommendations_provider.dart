import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wandermood/features/mood/models/mood_based_plan.dart';
import 'package:wandermood/features/mood/services/openai_service.dart';
import 'package:wandermood/features/places/models/place.dart';
import 'package:wandermood/features/places/services/google_places_service.dart';
import 'package:wandermood/core/providers/cache_provider.dart';
import 'package:wandermood/core/services/cache_service.dart';
import 'package:flutter/foundation.dart';

final moodRecommendationsProvider = StateNotifierProvider<MoodRecommendationsNotifier, AsyncValue<MoodBasedPlanData>>((ref) {
  return MoodRecommendationsNotifier(
    openAIService: OpenAIService(apiKey: const String.fromEnvironment('OPENAI_API_KEY')),
    googlePlacesService: GooglePlacesService(apiKey: const String.fromEnvironment('GOOGLE_PLACES_API_KEY')),
    cacheService: ref.watch(cacheServiceProvider),
  );
});

class MoodRecommendationsNotifier extends StateNotifier<AsyncValue<MoodBasedPlanData>> {
  final OpenAIService openAIService;
  final GooglePlacesService googlePlacesService;
  final CacheService cacheService;
  String? _currentMood;
  Position? _currentLocation;
  Map<String, String?> _pageTokens = {};

  MoodRecommendationsNotifier({
    required this.openAIService,
    required this.googlePlacesService,
    required this.cacheService,
  }) : super(const AsyncValue.loading()) {
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final cachedData = await cacheService.getCachedRecommendations();
      if (cachedData != null) {
        state = AsyncValue.data(cachedData);
      }
    } catch (error) {
      // Ignore cache errors and continue with fresh data
    }
  }

  Future<void> generateRecommendations(String selectedMood, Position userLocation) async {
    try {
      state = const AsyncValue.loading();
      _currentMood = selectedMood;
      _currentLocation = userLocation;
      _pageTokens.clear();

      // 1. Get activity suggestions from OpenAI based on mood
      final activities = await openAIService.getActivitiesForMood(selectedMood);

      // 2. Find real places for each activity using Google Places API
      final allPlaces = <Place>[];
      for (final activity in activities) {
        final result = await googlePlacesService.findPlacesForActivity(
          activity,
          userLocation,
        );
        allPlaces.addAll(result.places);
        _pageTokens[activity.type] = result.nextPageToken;
      }

      // 3. Get personalized descriptions for places based on mood
      final enhancedPlaces = await Future.wait(
        allPlaces.map((place) async {
          final description = await openAIService.generatePlaceDescription(
            place,
            selectedMood,
          );
          return place.copyWith(description: description);
        }),
      );

      // 4. Create the final plan data
      final planData = MoodBasedPlanData(
        mood: selectedMood,
        activities: activities,
        places: enhancedPlaces,
        timestamp: DateTime.now(),
        hasMorePlaces: _pageTokens.values.any((token) => token != null),
      );

      // 5. Cache the results
      await cacheService.cacheRecommendations(planData);

      state = AsyncValue.data(planData);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadMorePlaces() async {
    try {
      if (_currentMood == null || _currentLocation == null) return;
      
      final currentState = state;
      if (!currentState.hasValue) return;
      
      final currentData = currentState.value!;
      if (!currentData.hasMorePlaces) return;

      // Load more places for each activity that has a next page token
      final newPlaces = <Place>[];
      for (final activity in currentData.activities) {
        final pageToken = _pageTokens[activity.type];
        if (pageToken != null) {
          final result = await googlePlacesService.findPlacesForActivity(
            activity,
            _currentLocation!,
            pageToken: pageToken,
          );
          
          final enhancedPlaces = await Future.wait(
            result.places.map((place) async {
              final description = await openAIService.generatePlaceDescription(
                place,
                _currentMood!,
              );
              return place.copyWith(description: description);
            }),
          );
          
          newPlaces.addAll(enhancedPlaces);
          _pageTokens[activity.type] = result.nextPageToken;
        }
      }

      // Update state with new places
      state = AsyncValue.data(
        currentData.copyWith(
          places: [...currentData.places, ...newPlaces],
          hasMorePlaces: _pageTokens.values.any((token) => token != null),
        ),
      );
    } catch (error, stackTrace) {
      // On error, keep existing data but notify of error
      state = AsyncValue.data(state.value!);
      debugPrint('Error loading more places: $error');
    }
  }

  Future<void> clearRecommendations() async {
    _currentMood = null;
    _currentLocation = null;
    _pageTokens.clear();
    state = const AsyncValue.loading();
  }

  void reset() {
    _currentMood = null;
    _currentLocation = null;
    _pageTokens.clear();
    state = const AsyncValue.loading();
  }

  Future<void> clearCache() async {
    await cacheService.clearCache();
    reset();
  }

  List<MoodOption> get availableMoods => MoodBasedPlanData.predefinedMoods;
} 