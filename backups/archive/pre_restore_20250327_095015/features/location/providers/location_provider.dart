import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/location_service.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, AsyncValue<String>>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<AsyncValue<String>> {
  LocationNotifier() : super(const AsyncValue.data('Rotterdam')) {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      state = const AsyncValue.loading();
      final position = await LocationService.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        state = AsyncValue.data(placemarks.first.locality ?? 'Rotterdam');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void setLocation(String location) {
    state = AsyncValue.data(location);
  }

  void update(String? Function(String? state) callback) {
    final currentState = state.asData?.value;
    final newState = callback(currentState);
    if (newState != null) {
      setLocation(newState);
    }
  }

  void retryLocationAccess() {
    getCurrentLocation();
  }
} 