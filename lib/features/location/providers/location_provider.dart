import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wandermood/features/location/services/location_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

part 'location_provider.g.dart';

@riverpod
class LocationNotifier extends AutoDisposeAsyncNotifier<String?> {
  @override
  FutureOr<String?> build() async {
    return getCurrentLocation();
  }

  Future<String?> getCurrentLocation() async {
    state = const AsyncValue.loading();
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = const AsyncValue.data(null);
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = const AsyncValue.data(null);
        return null;
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
        final cityName = place.locality ?? 
                        place.subAdministrativeArea ?? 
                        place.administrativeArea;
        if (cityName != null) {
          state = AsyncValue.data(cityName);
          return cityName;
        }
      }

      state = const AsyncValue.data(null);
      return null;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<void> setLocation(String cityName) async {
    state = const AsyncValue.loading();
    try {
      // Validate city exists by trying to get coordinates
      final locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        state = AsyncValue.data(cityName);
      } else {
        state = const AsyncValue.error("City not found", StackTrace.empty);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> retryLocationAccess() async {
    state = const AsyncValue.loading();
    await getCurrentLocation();
  }
} 