import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/place.dart';
import '../services/places_service.dart';

part 'place_detail_provider.g.dart';

// Add a provider that can be used to force refresh of place details
@riverpod
class PlaceDetailRefresh extends _$PlaceDetailRefresh {
  @override
  int build() {
    return 0; // Initial state
  }
  
  // Call this method to force a refresh
  void refresh() {
    state++; // Increment the state to invalidate providers watching this
  }
}

@riverpod
Future<Place> placeDetail(PlaceDetailRef ref, String placeId) async {
  // Watch the refresh provider to invalidate this provider when refresh is called
  ref.watch(placeDetailRefreshProvider);
  
  final placesService = ref.watch(placesServiceProvider.notifier);
  await ref.watch(placesServiceProvider.future); // Ensure the service is initialized
  return placesService.getPlaceById(placeId);
} 