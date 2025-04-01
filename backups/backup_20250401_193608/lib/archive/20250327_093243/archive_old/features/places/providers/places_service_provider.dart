import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/places_service.dart';
import '../models/place.dart';

// Provider for the places service
final placesServiceProvider = Provider<PlacesService>((ref) {
  return PlacesService();
});

// Provider for the current list of places
final placesProvider = StateNotifierProvider<PlacesNotifier, AsyncValue<List<Place>>>((ref) {
  return PlacesNotifier(ref.watch(placesServiceProvider));
});

// Notifier for managing places state
class PlacesNotifier extends StateNotifier<AsyncValue<List<Place>>> {
  final PlacesService _placesService;

  PlacesNotifier(this._placesService) : super(const AsyncValue.data([]));

  Future<void> searchPlaces(String query) async {
    try {
      state = const AsyncValue.loading();
      final places = await _placesService.searchPlaces(query: query);
      state = AsyncValue.data(places.map((p) => Place.fromPlacesSearchResult(p)).toList());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> getNearbyPlaces() async {
    try {
      state = const AsyncValue.loading();
      final places = await _placesService.searchPlaces();
      state = AsyncValue.data(places.map((p) => Place.fromPlacesSearchResult(p)).toList());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
} 