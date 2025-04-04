import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/plan_generation_state.dart';
import '../../application/services/places_service.dart';
import '../../application/services/openai_service.dart';
import '../../application/services/location_service.dart';
import '../models/plan.dart';
import '../models/place.dart';

final planGenerationProvider = StateNotifierProvider<PlanGenerationNotifier, PlanGenerationState>((ref) {
  final placesService = ref.watch(placesServiceProvider);
  final openAIService = ref.watch(openAIServiceProvider);
  final locationService = ref.watch(locationServiceProvider);
  
  return PlanGenerationNotifier(
    placesService: placesService,
    openAIService: openAIService,
    locationService: locationService,
  );
});

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
  }) async {
    try {
      // 1. Start loading
      state = const PlanGenerationState.loading(
        message: 'Starting your plan generation...',
        progress: 0.0,
      );

      // 2. Get current location
      state = const PlanGenerationState.loading(
        message: 'Getting your location...',
        progress: 0.1,
      );
      final location = await locationService.getCurrentLocation();
      if (location == null) {
        state = const PlanGenerationState.error(
          message: 'Could not get your location. Please enable location services and try again.',
        );
        return;
      }

      // 3. Search for places based on moods
      state = const PlanGenerationState.searchingPlaces(
        message: 'Finding perfect places for your mood...',
        progress: 0.3,
      );
      final places = await placesService.searchPlacesByMoods(
        moods: moods,
        location: location,
      );
      if (places.isEmpty) {
        state = const PlanGenerationState.error(
          message: 'No places found for your moods. Please try different moods.',
        );
        return;
      }

      // 4. Analyze mood compatibility
      state = const PlanGenerationState.analyzingMood(
        message: 'Analyzing mood compatibility...',
        progress: 0.5,
      );
      final compatiblePlaces = await openAIService.analyzeMoodCompatibility(
        places: places,
        moods: moods,
      );

      // 5. Generate plan description
      state = const PlanGenerationState.generatingDescription(
        message: 'Creating your personalized plan...',
        progress: 0.7,
      );
      final planDescription = await openAIService.generatePlanDescription(
        places: compatiblePlaces,
        moods: moods,
      );

      // 6. Create final plan
      state = const PlanGenerationState.loading(
        message: 'Finalizing your plan...',
        progress: 0.9,
      );
      
      // Create bookings for compatible places
      final bookings = compatiblePlaces.map((place) => PlaceBooking(
        place: place,
        scheduledTime: DateTime.now().add(const Duration(days: 1)),
        partySize: 2,
      )).toList();

      final plan = Plan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'temp_user_id', // TODO: Replace with actual user ID
        mood: moods.join(', '),
        bookings: bookings,
        description: planDescription,
        createdAt: DateTime.now(),
      );

      // 7. Success
      state = PlanGenerationState.success(plan: plan);

    } catch (e) {
      state = PlanGenerationState.error(
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }
} 