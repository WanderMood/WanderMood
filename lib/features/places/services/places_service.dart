import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/place.dart';
import 'package:wandermood/core/config/api_keys.dart';
import 'package:wandermood/features/places/models/mock_data.dart';
import 'dart:async';

part 'places_service.g.dart';

@Riverpod(keepAlive: true)
class PlacesService extends _$PlacesService {
  late GoogleMapsPlaces _places;
  bool _isInitialized = false;

  @override
  Future<void> build() async {
    if (_isInitialized) return;
    
    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'];
    if (apiKey == null) {
      throw Exception('Google Places API key not found in environment variables');
    }
    
    _places = GoogleMapsPlaces(apiKey: apiKey);
    _isInitialized = true;
    debugPrint('✅ Places service initialized');
  }

  /// Search for places based on a query string
  Future<List<PlacesSearchResult>> searchPlaces(String query) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Places service not initialized, initializing now...');
      await build();
    }

    try {
      debugPrint('🔍 Searching for places with query: $query');
      
      // Add a timeout to prevent getting stuck
      final response = await _places.searchByText(
        query,
        language: "en",
        region: "nl",
        type: 'establishment',
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Places API search timed out after 10 seconds');
      });
      
      if (response.status == 'OK' && response.results.isNotEmpty) {
        debugPrint('✅ Found ${response.results.length} results for: $query');
        
        // Process results and get details for each place
        final detailedResults = await Future.wait(
          response.results.take(8).map((result) => 
            _enrichPlaceDetails(result).timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                debugPrint('⚠️ Enriching place ${result.name} timed out');
                return result; // Return original result on individual timeout
              },
            )
          ),
        ).timeout(const Duration(seconds: 15), onTimeout: () {
          // If enriching takes too long, just return the original results
          debugPrint('⚠️ Enriching places timed out, returning basic results');
          return response.results.take(8).toList();
        });
        
        return detailedResults.where((result) => result != null).cast<PlacesSearchResult>().toList();
      } else {
        debugPrint('❌ Places API Error: ${response.status}');
        throw Exception('Failed to fetch places: ${response.errorMessage ?? response.status}');
      }
    } on TimeoutException catch (e) {
      debugPrint('⏱️ Search timed out: $e');
      throw Exception('Search timed out: Please check your internet connection');
    } catch (e) {
      debugPrint('❌ Error fetching places: $e');
      throw Exception('Failed to fetch places: $e');
    }
  }

  /// Helper method to safely convert num to double
  double _toDouble(num? value) {
    if (value == null) return 0.0;
    return value is double ? value : value.toDouble();
  }

  /// Enrich a place with detailed information
  Future<PlacesSearchResult?> _enrichPlaceDetails(PlacesSearchResult result) async {
    try {
      final details = await _places.getDetailsByPlaceId(
        result.placeId,
        fields: [
          'name',
          'formatted_address',
          'geometry/location',
          'photos',
          'place_id',
          'rating',
          'price_level',
          'opening_hours',
          'types',
          'vicinity'
        ],
      );

      if (details.status != 'OK') {
        debugPrint('❌ Failed to get details for ${result.name}: ${details.errorMessage}');
        return null;
      }

      // Just return the original result since we can't modify the rating field type
      // We'll extract the detailed information when converting to Place objects
      debugPrint('✅ Got details for ${details.result.name}, returning original result');
      return result;
    } catch (e) {
      debugPrint('❌ Error enriching place details for ${result.name}: $e');
      return null;
    }
  }

  /// Get place details by ID
  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    if (!_isInitialized) {
      await build();
    }

    try {
      final response = await _places.getDetailsByPlaceId(
        placeId,
        fields: [
          'name',
          'formatted_address',
          'geometry/location',
          'photos',
          'place_id',
          'rating',
          'price_level',
          'opening_hours',
          'types',
          'vicinity'
        ],
      );

      if (response.status != 'OK') {
        throw Exception('Failed to get place details: ${response.errorMessage ?? response.status}');
      }

      return response.result;
    } catch (e) {
      debugPrint('❌ Error getting place details: $e');
      throw Exception('Failed to get place details: $e');
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
        
        if (details.geometry?.location == null) {
          debugPrint('⚠️ No details found for place ID: $placeId');
          throw Exception('Place details not found');
        }

        return Place(
          id: placeId,
          name: details.name ?? 'Unknown Place',
          address: details.formattedAddress ?? 'No address',
          rating: (details.rating ?? 0.0).toDouble(),
          photos: List<String>.from(details.photos?.map((p) => p.photoReference) ?? []),
          types: List<String>.from(details.types ?? []),
          location: PlaceLocation(
            lat: details.geometry?.location.lat ?? 0.0,
            lng: details.geometry?.location.lng ?? 0.0,
          ),
          isAsset: false,
        );
      } else {
        // This is for our hardcoded places
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
        isAsset: false,
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
        types: ['food', 'market', 'architecture'],
        location: const PlaceLocation(lat: 51.920, lng: 4.487),
        description: 'Iconic market hall with stunning interior architecture and food stalls',
        isAsset: true,
      ),
      Place(
        id: 'euromast',
        name: 'Euromast',
        address: 'Parkhaven 20, 3016 GM Rotterdam',
        rating: 4.5,
        photos: ['assets/images/pietro-de-grandi-T7K4aEPoGGk-unsplash.jpg'],
        types: ['landmark', 'tourist_attraction', 'observation_deck'],
        location: const PlaceLocation(lat: 51.905, lng: 4.467),
        description: 'Iconic observation tower with panoramic views of Rotterdam',
        isAsset: true,
      ),
      Place(
        id: 'erasmusbrug',
        name: 'Erasmus Bridge',
        address: 'Erasmusbrug, Rotterdam',
        rating: 4.7,
        photos: ['assets/images/mesut-kaya-eOcyhe5-9sQ-unsplash.jpg'],
        types: ['landmark', 'bridge', 'tourist_attraction'],
        location: const PlaceLocation(lat: 51.909, lng: 4.488),
        description: 'Iconic cable-stayed bridge connecting the north and south of Rotterdam',
        isAsset: true,
      ),
      Place(
        id: 'cubic_houses',
        name: 'Cubic Houses',
        address: 'Overblaak 70, 3011 MH Rotterdam',
        rating: 4.4,
        photos: ['assets/images/tom-podmore-1zkHXas1GIo-unsplash.jpg'],
        types: ['architecture', 'tourist_attraction', 'landmark'],
        location: const PlaceLocation(lat: 51.920, lng: 4.490),
        description: 'Innovative cube-shaped houses tilted at 45 degrees',
        isAsset: true,
      ),
      Place(
        id: 'rotterdam_harbour',
        name: 'Rotterdam Harbour',
        address: 'Wilhelminakade, Rotterdam',
        rating: 4.5,
        photos: ['assets/images/philipp-kammerer-6Mxb_mZ_Q8E-unsplash.jpg'],
        types: ['harbour', 'tourist_attraction', 'scenic'],
        location: const PlaceLocation(lat: 51.896, lng: 4.483),
        description: 'One of the largest ports in the world with stunning waterfront views',
        isAsset: true,
      ),
    ];
  }

  /// Get photo URL from photo reference
  String getPhotoUrl(String photoReference) {
    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'];
    
    // If already a full URL, return it
    if (photoReference.startsWith('http')) {
      return photoReference;
    }
    
    // If it's an asset path, return unchanged
    if (photoReference.startsWith('assets/')) {
      return photoReference;
    }
    
    // Handle empty or invalid references with a fallback
    if (photoReference.isEmpty) {
      return 'https://via.placeholder.com/400x300?text=No+Image';
    }
    
    // Construct proper Google Places API photo URL
    return 'https://maps.googleapis.com/maps/api/place/photo'
           '?maxwidth=800'
           '&photo_reference=$photoReference'
           '&key=$apiKey';
  }

  /// Create a place if it doesn't exist, otherwise return the existing place
  Future<Place> createIfNotExists(PlacesSearchResult result) async {
    try {
      // First check if the place exists by ID
      final existingPlace = await getPlaceById('google_${result.placeId}');
      if (existingPlace.id != 'error') {
        debugPrint('✅ Place already exists: ${existingPlace.name}');
        return existingPlace;
      }

      // If not exists, get detailed information
      final details = await getPlaceDetails(result.placeId);

      if (details.geometry?.location == null) {
        throw Exception('Failed to get place details');
      }

      // Create a new place with the detailed information
      final newPlace = Place(
        id: 'google_${details.placeId}',
        name: details.name ?? 'Unknown Place',
        address: details.formattedAddress ?? 'No address',
        rating: (details.rating ?? 0.0).toDouble(),
        photos: List<String>.from(details.photos?.map((p) => p.photoReference) ?? []),
        types: List<String>.from(details.types ?? []),
        location: PlaceLocation(
          lat: details.geometry?.location.lat ?? 0.0,
          lng: details.geometry?.location.lng ?? 0.0,
        ),
        description: _generateDescription(details),
        isAsset: false,
      );

      debugPrint('✅ Created new place: ${newPlace.name}');
      return newPlace;
    } catch (e) {
      debugPrint('❌ Error in createIfNotExists: $e');
      return Place(
        id: 'error',
        name: 'Error Creating Place',
        address: 'Please try again later',
        location: const PlaceLocation(lat: 0, lng: 0),
      );
    }
  }

  String _generateDescription(PlaceDetails result) {
    final types = result.types;
    if (types.isEmpty) return 'Discover this interesting location';

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

    final mainType = types.first.replaceAll('_', ' ');
    return 'Discover this amazing $mainType destination';
  }
} 