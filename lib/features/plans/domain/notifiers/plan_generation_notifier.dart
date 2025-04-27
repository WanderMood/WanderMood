import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../states/plan_generation_state.dart';
import '../../application/services/places_service.dart';
import '../../application/services/openai_service.dart';
import '../../application/services/location_service.dart';
import '../models/plan.dart';
import '../models/place.dart';
import '../models/place_booking.dart';

class PlanGenerationNotifier extends StateNotifier<PlanGenerationState> {
  final PlacesService placesService;
  final OpenAIService openAIService;
  final LocationService locationService;

  PlanGenerationNotifier({
    required this.placesService,
    required this.openAIService,
    required this.locationService,
  }) : super(const PlanGenerationState.initial());

  Future<void> generatePlan({
    required List<String> moods,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Initial loading state
      state = const PlanGenerationState.loading(
        message: 'Preparing your perfect day...',
        progress: 10,
      );

      // Search for places
      state = const PlanGenerationState.searchingPlaces(
        message: 'Finding places that match your mood...',
        progress: 30,
      );
      
      final placesData = await placesService.searchPlaces(
        query: moods.join(' '),
        location: LatLng(latitude, longitude),
      );

      // Convert Map<String, dynamic> to Place objects
      final places = placesData.map((data) => Place(
        id: data['place_id'] ?? '',
        name: data['name'] ?? 'Unknown Place',
        description: data['vicinity'] ?? data['formatted_address'] ?? '',
        tags: List<String>.from(data['types'] ?? []),
        rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
        location: PlaceLocation(
          lat: data['geometry']?['location']?['lat'] ?? 0.0,
          lng: data['geometry']?['location']?['lng'] ?? 0.0,
        ),
      )).toList();

      // Analyze mood compatibility
      state = const PlanGenerationState.analyzingMood(
        message: 'Analyzing places for the perfect match...',
        progress: 60,
      );
      
      final analyzedPlaces = await openAIService.analyzeMoodCompatibility(
        places: places,
        moods: moods,
      );

      // Generate plan description
      state = const PlanGenerationState.generatingDescription(
        message: 'Crafting your personalized plan...',
        progress: 85,
      );
      
      final description = await openAIService.generatePlanDescription(
        places: analyzedPlaces,
        moods: moods,
      );

      // Create plan
      final plan = Plan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'temp_user_id', // TODO: Get from auth
        mood: moods.join(', '),
        bookings: analyzedPlaces.map((place) => PlaceBooking(
          place: place,
          scheduledTime: DateTime.now().add(const Duration(days: 1)),
          partySize: 2,
        )).toList(),
        description: description,
        createdAt: DateTime.now(),
      );

      // Success state
      state = PlanGenerationState.success(plan: plan);
    } catch (e) {
      state = PlanGenerationState.error(
        message: 'Failed to generate plan: ${e.toString()}',
      );
    }
  }
} 