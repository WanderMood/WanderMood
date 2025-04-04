import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationServiceProvider = Provider((ref) => LocationService());

class Location {
  final double latitude;
  final double longitude;
  final String? name;

  Location({
    required this.latitude,
    required this.longitude,
    this.name,
  });
}

class LocationService {
  Future<Location?> getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }
} 