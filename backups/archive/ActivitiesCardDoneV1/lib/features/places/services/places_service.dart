import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/place.dart';

part 'places_service.g.dart';

@Riverpod(keepAlive: true)
class PlacesService extends _$PlacesService {
  late final GoogleMapsPlaces _places;
  bool _isInitialized = false;

  @override
  Future<void> build() async {
    await _initializePlaces();
  }

  Future<void> _initializePlaces() async {
    if (_isInitialized) return;

    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'];
    debugPrint('📍 API Key from env: ${apiKey?.substring(0, 8)}...');
    
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Google Places API key not found in .env file');
    }

    _places = GoogleMapsPlaces(apiKey: apiKey);
    _isInitialized = true;
    debugPrint('✅ Places service initialized with API key');
  }

  /// Search for places based on a query string
  Future<List<PlacesSearchResult>> searchPlaces(String query) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Service not initialized, initializing now...');
      await _initializePlaces();
    }
    
    try {
      debugPrint('🔍 Searching for places with query: $query');
      final response = await _places.searchByText(
        query,
        type: 'tourist_attraction',
        language: 'en',
      );

      debugPrint('📍 Places API Response Status: ${response.status}');
      if (response.errorMessage != null) {
        debugPrint('❌ API Error Message: ${response.errorMessage}');
      }

      if (response.status == "OK") {
        debugPrint('✅ Found ${response.results.length} places');
        for (var place in response.results) {
          debugPrint('  - ${place.name} (${place.placeId})');
        }
        return response.results;
      } else {
        debugPrint('❌ Places API Error: ${response.status}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error searching places: $e');
      return [];
    }
  }

  /// Get detailed place information by place ID
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Places service not initialized, initializing now...');
      await build();
    }

    debugPrint('🏷️ Getting details for place: $placeId');
    
    try {
      final response = await _places.getDetailsByPlaceId(
        placeId,
        fields: [
          'name',
          'formatted_address',
          'rating',
          'photo',
          'type',
          'geometry',
        ],
      );

      debugPrint('🏷️ Place details status: ${response.status}');
      
      if (response.status != 'OK') {
        debugPrint('❌ Details error: ${response.errorMessage}');
        return {};
      }
      
      final result = response.result;
      final details = {
        'name': result.name,
        'address': result.formattedAddress,
        'rating': result.rating,
        'photos': result.photos?.map((p) => p.photoReference).toList() ?? [],
        'types': result.types,
        'location': {
          'lat': result.geometry?.location.lat,
          'lng': result.geometry?.location.lng,
        },
      };
      debugPrint('✅ Got details for ${result.name}');
      return details;
    } catch (e) {
      debugPrint('❌ Failed to get place details: $e');
      return {};
    }
  }

  /// Get place by ID (can be either a place ID or an index for hardcoded places)
  Future<Place> getPlaceById(String placeId) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Places service not initialized, initializing now...');
      await build();
    }

    try {
      // Check if this is a Google Place ID or our internal ID
      if (placeId.startsWith('google_')) {
        // It's a Google Place ID
        final googlePlaceId = placeId.substring('google_'.length);
        final details = await getPlaceDetails(googlePlaceId);
        
        return Place(
          id: placeId,
          name: details['name'] ?? 'Unknown Place',
          address: details['address'] ?? 'No address',
          rating: details['rating'] ?? 0.0,
          photos: List<String>.from(details['photos'] ?? []),
          types: List<String>.from(details['types'] ?? []),
          location: PlaceLocation(
            lat: details['location']['lat'] ?? 0.0,
            lng: details['location']['lng'] ?? 0.0,
          ),
        );
      } else {
        // This is for our hardcoded places
        // Ideally we would fetch this from Supabase
        // For now, we'll return a dummy place
        final dummyPlaces = _getDummyPlaces();
        final place = dummyPlaces.firstWhere(
          (p) => p.id == placeId,
          orElse: () => dummyPlaces[0],
        );
        return place;
      }
    } catch (e) {
      debugPrint('❌ Error getting place by ID: $e');
      // Return a fallback place
      return Place(
        id: 'error',
        name: 'Error Loading Place',
        address: 'Please try again later',
        location: const PlaceLocation(lat: 0, lng: 0),
      );
    }
  }

  /// Temporary method to get hardcoded places
  List<Place> _getDummyPlaces() {
    return [
      Place(
        id: 'markthal',
        name: 'Markthal Rotterdam',
        address: 'Dominee Jan Scharpstraat 298, 3011 GZ Rotterdam',
        rating: 4.6,
        photos: ['assets/images/Markthal.jpg'],
        types: ['point_of_interest', 'food', 'establishment'],
        location: const PlaceLocation(lat: 51.920, lng: 4.487),
        description: 'Stunning market hall with food stalls and apartments',
        emoji: '🍲',
        tag: 'Food & Culture',
        isAsset: true,
        activities: ['Food Tour', 'Shopping', 'Architecture'],
      ),
      Place(
        id: 'fenixfood',
        name: 'Fenix Food Factory',
        address: 'Veerlaan 19D, 3072 AN Rotterdam',
        rating: 4.6,
        photos: ['assets/images/mesut-kaya-eOcyhe5-9sQ-unsplash.jpg'],
        types: ['point_of_interest', 'food', 'establishment'],
        location: const PlaceLocation(lat: 51.898, lng: 4.492),
        description: 'Trendy food hall in historic warehouse',
        emoji: '🍺',
        tag: 'Food & Drinks',
        isAsset: true,
        activities: ['Food Tasting', 'Craft Beer', 'Local Market'],
      ),
      Place(
        id: 'euromast',
        name: 'Euromast Experience',
        address: 'Parkhaven 20, 3016 GM Rotterdam',
        rating: 4.7,
        photos: ['assets/images/pietro-de-grandi-T7K4aEPoGGk-unsplash.jpg'],
        types: ['point_of_interest', 'tourist_attraction'],
        location: const PlaceLocation(lat: 51.905, lng: 4.467),
        description: 'Iconic tower with panoramic city views',
        emoji: '🗼',
        tag: 'Landmark',
        isAsset: true,
        activities: ['Observation', 'Fine Dining', 'Abseiling'],
      ),
    ];
  }

  /// Get place photos by photo reference
  String getPhotoUrl(String photoReference) {
    if (!_isInitialized) {
      debugPrint('⚠️ Warning: Getting photo URL before service initialization');
      _initializePlaces();
    }

    return _places.buildPhotoUrl(
      photoReference: photoReference,
      maxWidth: 400,
    );
  }
} 