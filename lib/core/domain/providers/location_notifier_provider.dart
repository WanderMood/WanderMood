import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../entities/location.dart';

final locationNotifierProvider = AsyncNotifierProvider<LocationNotifier, String?>(() {
  return LocationNotifier();
});

class LocationNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return null;
  }

  Future<void> setLocation(String location) async {
    state = AsyncValue.data(location);
  }

  Future<void> getCurrentLocation() async {
    state = const AsyncValue.loading();
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = AsyncValue.error(
            'Location permissions are denied',
            StackTrace.current,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = AsyncValue.error(
          'Location permissions are permanently denied',
          StackTrace.current,
        );
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();
      
      // Get place name from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final cityName = place.locality ?? place.subAdministrativeArea ?? 'Unknown Location';
        state = AsyncValue.data(cityName);
      } else {
        state = AsyncValue.error(
          'Could not determine location name',
          StackTrace.current,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
} 