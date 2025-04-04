import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/states/plan_generation_state.dart';
import '../../../core/services/places_service.dart';
import '../../../core/services/openai_service.dart';
import '../../../core/services/location_service.dart';

// Service providers
final placesServiceProvider = Provider((ref) => PlacesService());
final openAIServiceProvider = Provider((ref) => OpenAIService());
final locationServiceProvider = Provider((ref) => LocationService());

// Plan generation state notifier provider
final planGenerationProvider = StateNotifierProvider<PlanGenerationStateNotifier, PlanGenerationState>((ref) {
  return PlanGenerationStateNotifier(
    placesService: ref.watch(placesServiceProvider),
    openAIService: ref.watch(openAIServiceProvider),
    locationService: ref.watch(locationServiceProvider),
  );
});

// Selected mood provider
final selectedMoodProvider = StateProvider<String?>((ref) => null);

// Active plan provider
final activePlanProvider = StateProvider<Plan?>((ref) => null);

// Loading message provider
final loadingMessageProvider = StateProvider<String>((ref) {
  final planState = ref.watch(planGenerationProvider);
  
  return planState.when(
    initial: () => '',
    loading: () => 'Preparing your perfect day...',
    searchingPlaces: () => 'Finding places that match your mood...',
    analyzingMood: () => 'Analyzing places for the perfect match...',
    generatingDescription: () => 'Crafting your personalized plan...',
    success: (_) => 'Plan generated successfully!',
    error: (message) => 'Error: $message',
  );
});

// Loading progress provider (0-100)
final loadingProgressProvider = StateProvider<double>((ref) {
  final planState = ref.watch(planGenerationProvider);
  
  return planState.when(
    initial: () => 0,
    loading: () => 10,
    searchingPlaces: () => 30,
    analyzingMood: () => 60,
    generatingDescription: () => 85,
    success: (_) => 100,
    error: (_) => 0,
  );
}); 