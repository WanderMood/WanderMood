import 'dart:convert';
import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_maps_webservices/places.dart' as places;
import 'package:flutter_google_maps_webservices/places.dart' show Location;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/place.dart';
import 'package:wandermood/core/config/api_keys.dart';
import 'package:wandermood/core/services/places_service.dart' as core_service;
import 'dart:async';

part 'places_service.g.dart';

// Define LatLng class if it's not imported from elsewhere
class LatLng {
  final double latitude;
  final double longitude;
  
  const LatLng({required this.latitude, required this.longitude});
}

@Riverpod(keepAlive: true)
class PlacesService extends _$PlacesService {
  late places.GoogleMapsPlaces _places;
  bool _isInitialized = false;
  final String _apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
  
  @override
  Future<void> build() async {
    if (_isInitialized) return;
    
    if (_apiKey.isEmpty) {
      throw Exception('Google Places API key not found in environment variables');
    }
    
    _places = places.GoogleMapsPlaces(apiKey: _apiKey);
    _isInitialized = true;
    debugPrint('✅ Places service initialized');
  }

  /// Get photo URL from photo reference
  String getPlacePhotoUrl(String? photoReference, {int maxWidth = 600, int maxHeight = 400}) {
    if (photoReference == null || photoReference.isEmpty) {
      debugPrint('⚠️ Invalid photo reference');
      return '';
    }

    try {
      // If it's a mock reference (not the correct format for Google Places API),
      // return a placeholder image URL instead
      if (!photoReference.startsWith('Aap_') && photoReference.length < 40) {
        debugPrint('⚠️ Mock or invalid photo reference detected, using placeholder');
        // Return a placeholder image from Unsplash based on a seed derived from the reference
        final seed = photoReference.hashCode % 1000;
        return 'https://source.unsplash.com/featured/600x400?travel,landmark&sig=$seed';
      }

      final url = Uri.https('maps.googleapis.com', '/maps/api/place/photo', {
        'maxwidth': maxWidth.toString(),
        'maxheight': maxHeight.toString(),
        'photo_reference': photoReference,
        'key': _apiKey,
      }).toString();
      
      debugPrint('📸 Generated photo URL for reference: ${photoReference.substring(0, min(10, photoReference.length))}...');
      return url;
    } catch (e) {
      debugPrint('❌ Error generating photo URL: $e');
      // Return a random Unsplash image as fallback
      final seed = DateTime.now().millisecondsSinceEpoch % 1000;
      return 'https://source.unsplash.com/featured/600x400?travel&sig=$seed';
    }
  }
  
  /// Alias for getPlacePhotoUrl to maintain backward compatibility
  String getPhotoUrl(String? photoReference, {int maxWidth = 600, int maxHeight = 400}) {
    return getPlacePhotoUrl(photoReference, maxWidth: maxWidth, maxHeight: maxHeight);
  }
  
  /// Fetch an image from the Places Photos API and return it as a byte array
  Future<Uint8List?> getPlacePhotoBytes(String photoReference, {int maxWidth = 600, int maxHeight = 400}) async {
    if (photoReference.isEmpty) {
      debugPrint('❌ Empty photo reference');
      return null;
    }
    
    try {
      final url = getPlacePhotoUrl(photoReference, maxWidth: maxWidth, maxHeight: maxHeight);
      if (url.isEmpty) {
        debugPrint('❌ Invalid photo URL generated');
        return null;
      }

      debugPrint('📷 Fetching photo: ${url.substring(0, min(100, url.length))}...');
      
      final response = await http.get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        debugPrint('✅ Photo fetched successfully (${response.bodyBytes.length} bytes)');
        return response.bodyBytes;
      } else {
        debugPrint('❌ Failed to fetch photo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching photo: $e');
      return null;
    }
  }

  /// Search for places using the provided query string
  Future<List<Map<String, dynamic>>> searchPlaces(String query, {String? type, LatLng? location, int radius = 10000}) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Places service not initialized, initializing now...');
      await build();
    }

    if (query.trim().isEmpty) {
      debugPrint('⚠️ Empty query provided to searchPlaces');
      return [];
    }

    try {
      debugPrint('🔍 Searching places for: "$query"');
      
      // Build parameters for search request
      final searchParams = {
        'input': query,
        'radius': radius.toString(),
      };
      
      if (location != null) {
        searchParams['location'] = '${location.latitude},${location.longitude}';
      }
      
      if (type != null && type.isNotEmpty) {
        searchParams['type'] = type;
      }
      
      final response = await _places.searchByText(
        query,
        location: location != null ? places.Location(lat: location.latitude, lng: location.longitude) : null,
        radius: radius,
        type: type,
      );

      if (response.status != 'OK' && response.status != 'ZERO_RESULTS') {
        debugPrint('❌ Search error: ${response.errorMessage}');
        throw Exception('Places search failed: ${response.errorMessage}');
      }

      if (response.status == 'ZERO_RESULTS' || response.results.isEmpty) {
        debugPrint('ℹ️ No results found for "$query"');
        return [];
      }

      debugPrint('✅ Found ${response.results.length} results for "$query"');
      
      // Process the results into a simpler Map format
      final results = response.results.map((place) {
        // Use fallback image based on place type
        String fallbackImage = 'assets/images/fallbacks/default.jpg';
        if (place.types?.isNotEmpty == true) {
          final placeType = place.types![0];
          if (placeType == 'restaurant') fallbackImage = 'assets/images/fallbacks/restaurant.jpg';
          else if (placeType == 'cafe') fallbackImage = 'assets/images/fallbacks/cafe.jpg';
          else if (placeType == 'bar') fallbackImage = 'assets/images/fallbacks/bar.jpg';
          else if (placeType == 'museum') fallbackImage = 'assets/images/fallbacks/museum.jpg';
          else if (placeType == 'park') fallbackImage = 'assets/images/fallbacks/park.jpg';
          else if (placeType == 'lodging' || placeType == 'hotel') fallbackImage = 'assets/images/fallbacks/hotel.jpg';
        }
        
        // Generate a description based on the place types
        String description = '';
        if (place.types?.isNotEmpty == true) {
          description = _generateDescription(place.types!);
        } else {
          description = 'A place of interest in ${place.vicinity ?? 'the area'}';
        }
        
        return {
          'placeId': place.placeId,
          'name': place.name,
          'address': place.vicinity ?? place.formattedAddress ?? '',
          'location': {
            'lat': place.geometry?.location.lat,
            'lng': place.geometry?.location.lng,
          },
          'photos': place.photos?.map((p) => p.photoReference).toList() ?? [],
          'types': place.types ?? [],
          'rating': place.rating ?? 0.0,
          'fallbackImage': fallbackImage,
          'description': description,
          'priceLevel': place.priceLevel,
        };
      }).toList();

      // Check if there's a next page token
      if (response.nextPageToken != null && response.nextPageToken!.isNotEmpty) {
        debugPrint('ℹ️ Next page token available: ${response.nextPageToken}');
        // Wait required time before requesting next page (Google API requirement)
        await Future.delayed(const Duration(seconds: 2));
        
        try {
          // Get more results using the next page token
          final moreResults = await _getMoreResults(response.nextPageToken!);
          results.addAll(moreResults);
          debugPrint('✅ Added ${moreResults.length} more results from next page');
        } catch (e) {
          debugPrint('⚠️ Error getting next page: $e');
          // Continue with current results even if next page fails
        }
      }

      return results;
    } catch (e) {
      debugPrint('❌ Error searching places: $e');
      throw Exception('Failed to search places: $e');
    }
  }

  /// Helper method to fetch more results using a page token
  Future<List<Map<String, dynamic>>> _getMoreResults(String nextPageToken) async {
    try {
      debugPrint('🔍 Fetching next page with token: $nextPageToken');
      
      // Google Places API requires pageToken to be the only parameter
      final response = await _places.searchByText(
        '',  // Empty query when using page token
        pagetoken: nextPageToken,
      );

      if (response.status != 'OK') {
        debugPrint('❌ Next page error: ${response.errorMessage}');
        throw Exception('Failed to get next page: ${response.errorMessage}');
      }

      debugPrint('✅ Found ${response.results.length} results in next page');
      
      // Process the results similar to the main search
      return response.results.map((place) {
        String fallbackImage = 'assets/images/fallbacks/default.jpg';
        if (place.types?.isNotEmpty == true) {
          final placeType = place.types![0];
          if (placeType == 'restaurant') fallbackImage = 'assets/images/fallbacks/restaurant.jpg';
          else if (placeType == 'cafe') fallbackImage = 'assets/images/fallbacks/cafe.jpg';
          else if (placeType == 'bar') fallbackImage = 'assets/images/fallbacks/bar.jpg';
          else if (placeType == 'museum') fallbackImage = 'assets/images/fallbacks/museum.jpg';
          else if (placeType == 'park') fallbackImage = 'assets/images/fallbacks/park.jpg';
          else if (placeType == 'lodging' || placeType == 'hotel') fallbackImage = 'assets/images/fallbacks/hotel.jpg';
        }
        
        String description = '';
        if (place.types?.isNotEmpty == true) {
          description = _generateDescription(place.types!);
        } else {
          description = 'A place of interest in ${place.vicinity ?? 'the area'}';
        }
        
        return {
          'placeId': place.placeId,
          'name': place.name,
          'address': place.vicinity ?? place.formattedAddress ?? '',
          'location': {
            'lat': place.geometry?.location.lat,
            'lng': place.geometry?.location.lng,
          },
          'photos': place.photos?.map((p) => p.photoReference).toList() ?? [],
          'types': place.types ?? [],
          'rating': place.rating ?? 0.0,
          'fallbackImage': fallbackImage,
          'description': description,
          'priceLevel': place.priceLevel,
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting next page results: $e');
      throw Exception('Failed to get next page results: $e');
    }
  }

  /// Helper method to safely convert num to double
  double _toDouble(num? value) {
    if (value == null) return 0.0;
    return value is double ? value : value.toDouble();
  }

  /// Enrich a place with detailed information
  Future<places.PlacesSearchResult?> _enrichPlaceDetails(places.PlacesSearchResult result) async {
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
          'vicinity',
        ],
      );

      if (details.status != 'OK') {
        debugPrint('❌ Failed to get details for ${result.name}: ${details.errorMessage}');
        return null;
      }

      debugPrint('✅ Got details for ${details.result.name}, returning original result');
      return result;
    } catch (e) {
      debugPrint('❌ Error enriching place details for ${result.name}: $e');
      return null;
    }
  }

  /// Get place details by ID
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
          'photos',
          'types',
          'geometry',
          'price_level',
          'opening_hours',
          'vicinity',
          'formatted_phone_number',
          'website',
          'reviews',
          'user_ratings_total'
        ],
      );

      debugPrint('🏷️ Place details status: ${response.status}');
      
      if (response.status != 'OK') {
        debugPrint('❌ Details error: ${response.errorMessage}');
        throw Exception('Failed to get place details: ${response.errorMessage}');
      }
      
      final result = response.result;
      
      // Generate description from types if no reviews available
      String description = '';
      if (result.types?.isNotEmpty == true) {
        final mainType = result.types![0].replaceAll('_', ' ');
        description = 'A popular $mainType located in ${result.vicinity ?? result.formattedAddress}';
      }
      
      final details = {
        'name': result.name,
        'address': result.formattedAddress ?? result.vicinity ?? '',
        'rating': result.rating ?? 0.0,
        'photos': result.photos?.map((p) => p.photoReference).toList() ?? [],
        'types': result.types ?? [],
        'location': {
          'lat': result.geometry?.location.lat ?? 0.0,
          'lng': result.geometry?.location.lng ?? 0.0,
        },
        'description': description,
        'phone': result.formattedPhoneNumber,
        'website': result.website,
        'priceLevel': result.priceLevel,
        'openingHours': result.openingHours != null ? {
          'openNow': result.openingHours?.openNow ?? false,
          'weekdayText': result.openingHours?.weekdayText,
        } : null,
      };
      debugPrint('✅ Got details for ${result.name}');
      return details;
    } catch (e) {
      debugPrint('❌ Failed to get place details: $e');
      throw Exception('Failed to get place details: $e');
    }
  }

  /// Generate a description based on place types and features
  String _generateDescription(List<String> types) {
    String description = '';
    
    if (types.contains('restaurant') || types.contains('food')) {
      description = 'A popular dining establishment offering delicious food';
    } else if (types.contains('cafe')) {
      description = 'A cozy cafe where you can enjoy coffee and snacks';
    } else if (types.contains('bar')) {
      description = 'A vibrant bar offering a selection of drinks and atmosphere';
    } else if (types.contains('museum')) {
      description = 'A fascinating museum with exhibits and cultural artifacts';
    } else if (types.contains('park')) {
      description = 'A beautiful park where you can relax and enjoy nature';
    } else if (types.contains('shopping_mall')) {
      description = 'A shopping mall with a variety of stores and boutiques';
    } else if (types.contains('tourist_attraction')) {
      description = 'A popular tourist attraction worth visiting';
    } else if (types.contains('lodging') || types.contains('hotel')) {
      description = 'A comfortable accommodation option for your stay';
    } else if (types.isNotEmpty) {
      final type = types.first.replaceAll('_', ' ');
      description = 'A ${type} establishment';
    } else {
      description = 'An interesting place to visit';
    }
    
    return description;
  }

  /// Get place by ID (can be either a place ID or an index for hardcoded places)
  Future<Place> getPlaceById(String placeId) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Places service not initialized, initializing now...');
      await build();
    }

    try {
      // Real Google Place ID - remove the 'google_' prefix if present
      final googlePlaceId = placeId.startsWith('google_') ? placeId.substring('google_'.length) : placeId;
      debugPrint('🔍 Getting details for Google Place ID: $googlePlaceId');
      
      // Get details from Google Places API
      final details = await getPlaceDetails(googlePlaceId);
      
      if (details.isEmpty) {
        throw Exception('Failed to fetch details for place ID: $googlePlaceId');
      }
      
      // Convert the details to a Place object
      return Place(
        id: placeId,
        name: details['name'] ?? 'Unknown Place',
        address: details['address'] ?? 'Address not available',
        location: PlaceLocation(
          lat: (details['location']?['lat'] as num?)?.toDouble() ?? 0.0,
          lng: (details['location']?['lng'] as num?)?.toDouble() ?? 0.0,
        ),
        rating: (details['rating'] as num?)?.toDouble() ?? 0.0,
        photos: (details['photos'] as List<dynamic>?)?.cast<String>() ?? [],
        types: (details['types'] as List<dynamic>?)?.cast<String>() ?? [],
        description: details['description'],
        phoneNumber: details['phone'],
        website: details['website'],
        priceLevel: details['priceLevel'] as int?,
        openingHours: details['openingHours'] != null
            ? details['openingHours'] as Map<String, dynamic>
            : null,
      );
    } catch (e) {
      debugPrint('❌ Error in getPlaceById: $e');
      
      // Create a stub place with error information
      return Place(
        id: placeId,
        name: 'Error Loading Place',
        address: 'Could not load place details',
        location: const PlaceLocation(lat: 0, lng: 0),
        photos: [],
        types: [],
        description: 'There was an error loading this place. Please try again later.',
      );
    }
  }
} 