import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import '../entities/location.dart';

final locationNotifierProvider = AsyncNotifierProvider<LocationNotifier, String?>(() {
  return LocationNotifier();
});

class LocationNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    // Always use current location on initialization
    return getCurrentLocation();
  }

  Future<String?> getCurrentLocation() async {
    state = const AsyncValue.loading();
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied');
          state = AsyncValue.error(
            'Location permissions are denied',
            StackTrace.current,
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied');
        state = AsyncValue.error(
          'Location permissions are permanently denied',
          StackTrace.current,
        );
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();
      debugPrint('Got position: ${position.latitude}, ${position.longitude}');
      
      // Get place name from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final cityName = place.locality ?? place.subAdministrativeArea ?? 'Unknown Location';
        debugPrint('Found city name: $cityName');
        state = AsyncValue.data(cityName);
        return cityName;
      } else {
        debugPrint('Could not determine location name');
        state = AsyncValue.error(
          'Could not determine location name',
          StackTrace.current,
        );
        return null;
      }
    } catch (e, stack) {
      debugPrint('Error getting location: $e');
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  // Method to retry getting location
  Future<void> retryLocationAccess() async {
    await getCurrentLocation();
  }
} 