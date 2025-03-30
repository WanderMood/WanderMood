import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wandermood/features/location/services/location_service.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, AsyncValue<String?>>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<AsyncValue<String?>> {
  LocationNotifier() : super(const AsyncValue.loading()) {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    state = const AsyncValue.loading();
    try {
      final city = await LocationService.getCurrentCity();
      state = AsyncValue.data(city);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
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
} 