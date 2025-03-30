import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'places_service.g.dart';

@riverpod
PlacesService placesService(PlacesServiceRef ref) {
  return PlacesService();
}

class PlacesService {
  final _places = GoogleMapsPlaces(
    apiKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '',
  );

  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    String? category,
    int page = 1,
  }) async {
    try {
      final response = await _places.nearbySearch(
        NearbySearchRequest(
          location: Location(lat: latitude, lng: longitude),
          radius: 5000, // 5km radius
          type: category?.toLowerCase(),
          pageToken: page > 1 ? _nextPageToken : null,
        ),
      );

      if (response.errorMessage != null) {
        throw Exception(response.errorMessage);
      }

      _nextPageToken = response.nextPageToken;

      return response.results.map((result) => Place(
        id: result.placeId,
        name: result.name,
        description: result.vicinity ?? '',
        latitude: result.geometry?.location.lat ?? 0,
        longitude: result.geometry?.location.lng ?? 0,
        address: result.vicinity ?? '',
        categories: result.types ?? [],
        rating: result.rating ?? 0,
        reviewCount: result.userRatingsTotal ?? 0,
        imageUrl: result.photos?.isNotEmpty == true
            ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${result.photos!.first.photoReference}&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}'
            : '',
        isOpen: result.openingHours?.isOpen ?? false,
        openingHours: result.openingHours?.weekdayText?.asMap() ?? {},
        photos: result.photos?.map((p) => p.photoReference).toList() ?? [],
        contact: {
          'phone': result.formattedPhoneNumber,
          'website': result.website,
        },
        location: {
          'lat': result.geometry?.location.lat,
          'lng': result.geometry?.location.lng,
        },
        amenities: result.types?.map((type) => {
          'name': type,
          'icon': _getAmenityIcon(type),
        }).toList() ?? [],
        distance: 0, // Calculate distance if needed
        isFavorite: false,
      )).toList();
    } catch (e) {
      throw Exception('Failed to fetch nearby places: $e');
    }
  }

  String? _nextPageToken;

  String _getAmenityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'restaurant':
        return '🍽️';
      case 'cafe':
        return '☕';
      case 'bar':
        return '🍸';
      case 'hotel':
        return '🏨';
      case 'museum':
        return '🏛️';
      case 'park':
        return '🌳';
      case 'shopping_mall':
        return '🛍️';
      case 'tourist_attraction':
        return '🎯';
      default:
        return '📍';
    }
  }

  /// Search for places based on a query string
  Future<List<PlacesSearchResult>> searchPlaces({
    String? city,
    String? query,
    PlaceLocation? location,
  }) async {
    if (!_places.isInitialized) {
      debugPrint('⚠️ Places service not initialized, initializing now...');
      await _places.initialize();
    }
    
    try {
      final searchQuery = [
        if (city != null) city,
        if (query != null) query,
      ].join(' ');
      
      debugPrint('🔍 Searching for places with query: $searchQuery');
      
      final response = await _places.searchByText(
        searchQuery,
        type: 'tourist_attraction',
        language: 'en',
        location: location != null 
          ? Location(lat: location.lat, lng: location.lng)
          : null,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Places API request timed out');
        },
      );

      if (response.status == "OK") {
        debugPrint('✅ Found ${response.results.length} places');
        return response.results;
      } else {
        final error = response.errorMessage ?? 'Unknown error';
        debugPrint('❌ Places API Error: $error');
        throw Exception('Places API Error: $error');
      }
    } catch (e) {
      debugPrint('❌ Error searching places: $e');
      throw Exception('Failed to search places: $e');
    }
  }

  /// Get detailed place information by place ID
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    if (!_places.isInitialized) {
      debugPrint('⚠️ Places service not initialized, initializing now...');
      await _places.initialize();
    }

    try {
      final result = await _places.getDetailsByPlaceId(
        placeId,
        fields: [
          'name',
          'formatted_address',
          'rating',
          'photo',
          'type',
          'geometry',
          'price_level',
          'opening_hours',
          'vicinity',
        ],
      );

      if (result.status != 'OK') {
        throw Exception('Failed to get place details: ${result.errorMessage}');
      }

      final details = {
        'name': result.result.name,
        'address': result.result.formattedAddress,
        'rating': result.result.rating,
        'photos': result.result.photos?.map((p) => p.photoReference).toList() ?? [],
        'types': result.result.types,
        'location': PlaceLocation(
          lat: result.result.geometry?.location.lat ?? 0.0,
          lng: result.result.geometry?.location.lng ?? 0.0,
        ),
        'priceLevel': result.result.priceLevel,
        'openingHours': {
          'weekdayText': result.result.openingHours?.weekdayText,
          'openNow': result.result.openingHours?.openNow,
          'periods': result.result.openingHours?.periods,
        },
        'vicinity': result.result.vicinity,
      };
      debugPrint('✅ Got details for ${result.result.name}');
      return details;
    } catch (e) {
      debugPrint('❌ Failed to get place details: $e');
      return {};
    }
  }

  /// Get place by ID (can be either a place ID or an index for hardcoded places)
  Future<Place> getPlaceById(String placeId) async {
    if (!_places.isInitialized) {
      debugPrint('⚠️ Places service not initialized, initializing now...');
      await _places.initialize();
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
          description: details['address'] ?? 'No description available',
          rating: details['rating'] ?? 0.0,
          photos: List<String>.from(details['photos'] ?? []),
          types: List<String>.from(details['types'] ?? []),
          location: details['location'] as PlaceLocation,
          priceLevel: details['priceLevel'] as int?,
          openingHours: details['openingHours'] as Map<String, dynamic>?,
          isOpen: details['openingHours']?['openNow'] as bool? ?? false,
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
        description: 'An error occurred while loading this place.',
        rating: 0.0,
        photos: [],
        types: [],
        location: PlaceLocation(lat: 0.0, lng: 0.0),
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
        location: PlaceLocation(lat: 51.920, lng: 4.487),
        description: 'Stunning market hall with food stalls and apartments',
        emoji: '🍲',
        tag: 'Food & Culture',
        activities: ['Food Tour', 'Shopping', 'Architecture'],
      ),
      Place(
        id: 'fenixfood',
        name: 'Fenix Food Factory',
        address: 'Veerlaan 19D, 3072 AN Rotterdam',
        rating: 4.6,
        photos: ['assets/images/mesut-kaya-eOcyhe5-9sQ-unsplash.jpg'],
        types: ['point_of_interest', 'food', 'establishment'],
        location: PlaceLocation(lat: 51.898, lng: 4.492),
        description: 'Trendy food hall in historic warehouse',
        emoji: '🍺',
        tag: 'Food & Drinks',
        activities: ['Food Tasting', 'Craft Beer', 'Local Market'],
      ),
      Place(
        id: 'euromast',
        name: 'Euromast Experience',
        address: 'Parkhaven 20, 3016 GM Rotterdam',
        rating: 4.7,
        photos: ['assets/images/pietro-de-grandi-T7K4aEPoGGk-unsplash.jpg'],
        types: ['point_of_interest', 'tourist_attraction'],
        location: PlaceLocation(lat: 51.905, lng: 4.467),
        description: 'Iconic tower with panoramic city views',
        emoji: '🗼',
        tag: 'Landmark',
        activities: ['Observation', 'Fine Dining', 'Abseiling'],
      ),
    ];
  }

  /// Get place photos by photo reference
  String getPhotoUrl(String photoReference) {
    if (!_places.isInitialized) {
      throw Exception('Places service not initialized');
    }
    
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Google Places API key not found');
    }

    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';
  }
} 