import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

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
      return LocationResult(error: LocationError.serviceDisabled);
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
      return LocationResult(error: LocationError.unknown);
    }
  }

  static Future<String?> getCurrentCity() async {
    try {
      final result = await _handlePermission();
      
      if (result.error != null) {
        throw result.error.toString();
      }

      if (result.position == null) {
        throw 'Could not get current position';
      }

      final placemarks = await placemarkFromCoordinates(
        result.position!.latitude,
        result.position!.longitude,
      );

      if (placemarks.isEmpty) {
        throw 'No location found';
      }

      final place = placemarks.first;
      final city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea;
      
      if (city == null) {
        throw 'Could not determine city name';
      }
      
      return city;
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  static Future<bool> checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  static Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  static Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return place.locality ?? place.subLocality ?? place.administrativeArea;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<double> calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
} 