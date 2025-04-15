import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import '../entities/location.dart';

class LocationState {
  final String? city;
  final double? currentLatitude;
  final double? currentLongitude;
  final bool isLoading;
  final String? error;

  LocationState({
    this.city,
    this.currentLatitude,
    this.currentLongitude,
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    String? city,
    double? currentLatitude,
    double? currentLongitude,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      city: city ?? this.city,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasLocation => currentLatitude != null && currentLongitude != null;
  bool get hasError => error != null;
  bool get hasCity => city != null;
  
  // Helper methods for compatibility with AsyncValue pattern
  T maybeWhen<T>({
    T Function()? data,
    T Function()? loading,
    T Function(Object, StackTrace)? error,
    required T Function() orElse,
  }) {
    if (isLoading) return loading?.call() ?? orElse();
    if (this.error != null) return error?.call(this.error!, StackTrace.current) ?? orElse();
    return data?.call() ?? orElse();
  }
  
  // Compatibility with AsyncValue pattern
  T when<T>({
    required T Function(String?) data,
    required T Function() loading,
    required T Function(Object, StackTrace) error,
  }) {
    if (isLoading) return loading();
    if (this.error != null) return error(this.error!, StackTrace.current);
    return data(city);
  }
  
  // For backwards compatibility
  String? get value => city;
}

final locationNotifierProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState(isLoading: true)) {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            error: 'Location permissions are denied',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permissions are permanently denied',
        );
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
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
        state = state.copyWith(
          city: cityName,
          currentLatitude: position.latitude,
          currentLongitude: position.longitude,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not determine location name',
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setCity(String cityName) async {
    try {
      state = state.copyWith(isLoading: true);
      final locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        state = state.copyWith(
          city: cityName,
          currentLatitude: locations.first.latitude,
          currentLongitude: locations.first.longitude,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          city: cityName,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('Error getting coordinates for city: $e');
      state = state.copyWith(
        city: cityName,
        isLoading: false,
      );
    }
  }

  Future<void> retryLocationAccess() async {
    await getCurrentLocation();
  }
}

// Add this provider after the locationNotifierProvider
final locationStateProvider = Provider<AsyncValue<LocationState>>((ref) {
  final state = ref.watch(locationNotifierProvider);
  
  if (state.isLoading) {
    return const AsyncValue.loading();
  }
  
  if (state.hasError) {
    return AsyncValue.error(state.error!, StackTrace.current);
  }
  
  return AsyncValue.data(state);
}); 