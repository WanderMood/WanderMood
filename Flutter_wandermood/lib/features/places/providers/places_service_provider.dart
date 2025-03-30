import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/places_service.dart';

part 'places_service_provider.g.dart';

/// Provider for accessing the PlacesService
/// This is a wrapper around the placesServiceProvider to expose the service
/// methods to other providers and widgets
@riverpod
class PlacesServiceProvider extends _$PlacesServiceProvider {
  @override
  PlacesService build() {
    // Return the ref to the PlacesService provider notifier
    return ref.watch(placesServiceProvider.notifier);
  }
  
  // Forward methods to the underlying service
  Future<List<dynamic>> searchPlaces(String query) async {
    return state.searchPlaces(query);
  }
  
  String getPhotoUrl(String photoReference) {
    return state.getPhotoUrl(photoReference);
  }
} 