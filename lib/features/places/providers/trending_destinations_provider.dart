import 'package:flutter_google_maps_webservices/places.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/place.dart';
import '../services/places_service.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

part 'trending_destinations_provider.g.dart';

@riverpod
class TrendingDestinations extends _$TrendingDestinations {
  // Rotterdam central coordinates
  static const double rotterdamLat = 51.9244;
  static const double rotterdamLng = 4.4777;
  Position? _userPosition;

  @override
  Future<List<Place>> build({String? city}) async {
    // Add timeout to prevent infinite loading
    return _fetchTrendingDestinations(city)
      .timeout(const Duration(seconds: 10))
      .catchError((error) {
        debugPrint('⚠️ Trending destinations timed out or failed: $error');
        return _getFallbackPlaces(); // Return fallback places on timeout or error
      });
  }

  // Private method to do the actual fetching
  Future<List<Place>> _fetchTrendingDestinations(String? city) async {
    // Get user's current position or use Rotterdam's coordinates
    try {
      final hasPermission = await _checkLocationPermission();
      if (hasPermission) {
        _userPosition = await Geolocator.getCurrentPosition();
        debugPrint('📍 Got user position: ${_userPosition?.latitude}, ${_userPosition?.longitude}');
      } else {
        _userPosition = Position(
          latitude: rotterdamLat,
          longitude: rotterdamLng,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        debugPrint('📍 Using default Rotterdam position');
      }
    } catch (e) {
      debugPrint('❌ Error getting user position: $e, using Rotterdam coordinates');
      _userPosition = Position(
        latitude: rotterdamLat,
        longitude: rotterdamLng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }

    // Get the current location from the location provider
    final locationState = ref.watch(locationNotifierProvider);
    
    // Use the city parameter if provided, otherwise use the location state
    final cityName = city ?? locationState.value ?? 'Rotterdam';
    
    debugPrint('🔄 TrendingDestinations rebuilding for city: $cityName');
    
    ref.onDispose(() {
      debugPrint('🗑️ Disposing trending destinations provider for $cityName');
    });
    
    final service = ref.read(placesServiceProvider.notifier);
    List<PlacesSearchResult> allResults = [];

    // Just return fallback data for this city immediately if offline
    // This helps prevent long loading times when network is poor
    if (/* Check if offline */ false) {
      debugPrint('📱 Device appears to be offline, using fallback data for $cityName');
      return _getFallbackPlaces();
    }

    // Primary search: tourist attractions
    try {
      final results = await service.searchPlaces('tourist attractions in $cityName');
      if (results.isNotEmpty) {
        debugPrint('✅ Found ${results.length} tourist attractions in $cityName');
        allResults.addAll(results.take(8));
      }
    } catch (e) {
      debugPrint('❌ Error fetching tourist attractions: $e');
    }

    // If still empty after first attempt, immediately return fallbacks
    if (allResults.isEmpty) {
      debugPrint('⚠️ No results from primary search, using fallback places');
      return _getFallbackPlaces();
    }

    return _convertToPlaces(allResults);
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  String _generateDescription(PlacesSearchResult result) {
    final types = result.types;
    if (types.isEmpty) return 'Discover this interesting location in Rotterdam';

    if (types.contains('museum')) {
      return 'Explore art and culture at this renowned museum';
    } else if (types.contains('park')) {
      return 'Enjoy nature and relaxation in this beautiful park';
    } else if (types.contains('restaurant')) {
      return 'Savor delicious local and international cuisine';
    } else if (types.contains('shopping_mall')) {
      return 'Experience premium shopping and entertainment';
    } else if (types.contains('tourist_attraction')) {
      return 'Visit this popular attraction and discover local charm';
    } else if (types.contains('historic')) {
      return 'Step into history at this significant landmark';
    }

    // Generate based on first type
    final mainType = types.first.replaceAll('_', ' ');
    return 'Discover this amazing $mainType destination';
  }

  double _calculateDistance(double? lat, double? lng) {
    if (_userPosition == null || lat == null || lng == null) return 0;
    
    final distance = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      lat,
      lng,
    ) / 1000; // Convert to kilometers

    return double.parse(distance.toStringAsFixed(1)); // Round to 1 decimal place
  }

  List<Place> _convertToPlaces(List<PlacesSearchResult> results) {
    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'];
    return results.map((result) {
      final lat = result.geometry?.location.lat;
      final lng = result.geometry?.location.lng;
      final distance = _calculateDistance(lat, lng);

      // Extract photo references directly
      List<String> photoReferences = [];
      if (result.photos != null && result.photos.isNotEmpty) {
        debugPrint('📸 Found ${result.photos.length} photos for ${result.name}');
        photoReferences = result.photos
            .where((photo) => photo.photoReference != null && photo.photoReference!.isNotEmpty)
            .map((photo) => photo.photoReference!)
            .toList();
      } else {
        debugPrint('⚠️ No photos found for ${result.name}');
      }

      // Handle the address safely
      final address = result.formattedAddress ?? result.vicinity ?? 'No address available';

      return Place(
        id: 'google_${result.placeId}',
        name: result.name,
        address: address,
        location: PlaceLocation(
          lat: result.geometry?.location.lat ?? 0.0,
          lng: result.geometry?.location.lng ?? 0.0,
        ),
        rating: (result.rating ?? 0.0).toDouble(),
        photos: photoReferences.isNotEmpty ? photoReferences : [], 
        types: result.types,
        description: _generateDescription(result),
        isAsset: false,
      );
    }).toList();
  }

  String getPhotoUrl(String photoReference) {
    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'];
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoReference&key=$apiKey';
  }

  // Fallback places when API doesn't return data
  List<Place> _getFallbackPlaces() {
    return [
      Place(
        id: 'rotterdam_markthal',
        name: 'Markthal Rotterdam',
        address: 'Dominee Jan Scharpstraat 298, 3011 GZ Rotterdam',
        location: const PlaceLocation(lat: 51.920, lng: 4.487),
        rating: 4.6,
        photos: ['assets/images/Markthal.jpg'],
        types: ['food', 'market', 'architecture'],
        description: 'Iconic market hall with stunning interior architecture and food stalls',
        isAsset: true,
      ),
      Place(
        id: 'rotterdam_euromast',
        name: 'Euromast Rotterdam',
        address: 'Parkhaven 20, 3016 GM Rotterdam',
        location: const PlaceLocation(lat: 51.905, lng: 4.467),
        rating: 4.5,
        photos: ['assets/images/pietro-de-grandi-T7K4aEPoGGk-unsplash.jpg'],
        types: ['landmark', 'tourist_attraction'],
        description: 'Iconic observation tower with panoramic views of Rotterdam',
        isAsset: true,
      ),
      Place(
        id: 'rotterdam_cube_houses',
        name: 'Cube Houses',
        address: 'Overblaak 70, 3011 MH Rotterdam',
        location: const PlaceLocation(lat: 51.920, lng: 4.490),
        rating: 4.4,
        photos: ['assets/images/tom-podmore-1zkHXas1GIo-unsplash.jpg'],
        types: ['architecture', 'tourist_attraction', 'landmark'],
        description: 'Innovative cube-shaped houses tilted at 45 degrees',
        isAsset: true,
      ),
      Place(
        id: 'rotterdam_erasmus_bridge',
        name: 'Erasmus Bridge',
        address: 'Erasmusbrug, Rotterdam',
        location: const PlaceLocation(lat: 51.909, lng: 4.488),
        rating: 4.7,
        photos: ['assets/images/mesut-kaya-eOcyhe5-9sQ-unsplash.jpg'],
        types: ['landmark', 'bridge', 'tourist_attraction'],
        description: 'Iconic cable-stayed bridge connecting the north and south of Rotterdam',
        isAsset: true,
      ),
    ];
  }
}