import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

enum LocationError {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unknown
}

class LocationResult {
  final Position? position;
  final LocationError? error;

  LocationResult({this.position, this.error});
}

class LocationService {
  static const defaultLocation = {
    'id': 'rotterdam',
    'name': 'Rotterdam',
    'latitude': 51.9244,
    'longitude': 4.4777,
  };

  static Future<LocationResult> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationResult(
        position: Position(
          latitude: defaultLocation['latitude'] as double,
          longitude: defaultLocation['longitude'] as double,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
          isMocked: false,
        ),
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationResult(error: LocationError.permissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationResult(error: LocationError.permissionDeniedForever);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LocationResult(position: position);
    } catch (e) {
      return LocationResult(
        position: Position(
          latitude: defaultLocation['latitude'] as double,
          longitude: defaultLocation['longitude'] as double,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
          isMocked: false,
        ),
      );
    }
  }

  static Future<String?> getCurrentCity() async {
    try {
      final result = await _handlePermission();
      
      if (result.error != null) {
        switch (result.error!) {
          case LocationError.serviceDisabled:
          case LocationError.permissionDenied:
          case LocationError.permissionDeniedForever:
          case LocationError.unknown:
            return defaultLocation['name'] as String;
        }
      }

      if (result.position == null) return defaultLocation['name'] as String;

      final placemarks = await placemarkFromCoordinates(
        result.position!.latitude,
        result.position!.longitude,
      );

      if (placemarks.isEmpty) return defaultLocation['name'] as String;

      final place = placemarks.first;
      final city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea;
      
      return city ?? defaultLocation['name'] as String;
    } catch (e) {
      return defaultLocation['name'] as String;
    }
  }

  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
} 