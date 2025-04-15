import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'package:flutter/foundation.dart';

class PlacesService {
  final String apiKey = ApiConstants.placesApiKey;
  final String baseUrl = ApiConstants.placesBaseUrl;
  bool _isInitialized = false;

  PlacesService() {
    _initialize();
  }

  void _initialize() {
    if (apiKey.isNotEmpty && baseUrl.isNotEmpty) {
      _isInitialized = true;
      debugPrint('✅ Places service initialized');
    } else {
      debugPrint('❌ Places service initialization failed: Missing API key or base URL');
    }
  }

  Future<List<Map<String, dynamic>>> searchPlacesByMood({
    required String mood,
    required double lat,
    required double lng,
    int radius = 5000,  // 5km radius - not required, just has default
  }) async {
    final placeTypes = ApiConstants.moodPlaceTypes[mood.toLowerCase()] ?? [];
    List<Map<String, dynamic>> allPlaces = [];

    for (final type in placeTypes) {
      final url = Uri.parse('$baseUrl${ApiConstants.nearbySearch}'
          '?location=$lat,$lng'
          '&radius=$radius'
          '&type=$type'
          '&key=$apiKey');

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK') {
            final places = List<Map<String, dynamic>>.from(data['results']);
            allPlaces.addAll(places);
          }
        }
      } catch (e) {
        print('Error fetching places for type $type: $e');
      }
    }

    // Remove duplicates based on place_id
    final uniquePlaces = allPlaces.fold<Map<String, Map<String, dynamic>>>(
      {},
      (map, place) {
        final placeId = place['place_id'] as String;
        if (!map.containsKey(placeId)) {
          map[placeId] = place;
        }
        return map;
      },
    );

    return uniquePlaces.values.toList();
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Places service not initialized');
      throw Exception('Places service not initialized');
    }

    final url = Uri.parse('$baseUrl${ApiConstants.placeDetails}'
        '?place_id=$placeId'
        '&fields=name,rating,formatted_phone_number,formatted_address,opening_hours,website,price_level,reviews,photos,editorial_summary,types,geometry,vicinity,user_ratings_total'
        '&key=$apiKey');

    try {
      final response = await http.get(url);
      debugPrint('🏷️ Place details status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          
          // Get the editorial summary if available
          String description = result['editorial_summary']?['overview'] ?? '';
          
          // If no editorial summary, try to create one from the top review
          if (description.isEmpty && result['reviews']?.isNotEmpty == true) {
            final topReview = result['reviews'][0];
            if (topReview['rating'] >= 4) {
              description = topReview['text'];
            }
          }
          
          // If still no description, create one from the place type
          if (description.isEmpty) {
            final types = result['types'] as List<dynamic>? ?? [];
            description = _generateDescriptionFromTypes(types.cast<String>(), result['name']);
          }

          // Extract and format photos with validation
          final List<String> photos = [];
          if (result['photos'] != null) {
            for (var photo in result['photos']) {
              final photoRef = photo['photo_reference'] as String?;
              if (photoRef != null && isValidPhotoReference(photoRef)) {
                photos.add(photoRef);
              }
            }
          }
          
          // If no valid photos found, add a default photo reference
          if (photos.isEmpty) {
            debugPrint('⚠️ No valid photos found for place: ${result['name']}');
          }
          
          // Create a structured response
          final details = {
            'name': result['name'],
            'address': result['formatted_address'],
            'vicinity': result['vicinity'],
            'rating': result['rating']?.toDouble() ?? 0.0,
            'user_ratings_total': result['user_ratings_total'] ?? 0,
            'photos': photos,
            'types': result['types'] ?? [],
            'description': description,
            'location': {
              'lat': result['geometry']?['location']?['lat'] ?? 0.0,
              'lng': result['geometry']?['location']?['lng'] ?? 0.0,
            },
            'price_level': result['price_level'],
            'opening_hours': result['opening_hours'] == null ? null : {
              'open_now': result['opening_hours']['open_now'] ?? false,
              'weekday_text': result['opening_hours']['weekday_text'] ?? [],
            },
            'phone': result['formatted_phone_number'],
            'website': result['website'],
            'is_asset': false,
            'activities': _getActivitiesFromTypes(result['types'] ?? []),
          };

          debugPrint('✅ Successfully fetched details for ${details['name']}');
          return details;
        } else {
          debugPrint('❌ API Error: ${data['status']} - ${data['error_message']}');
          throw Exception('Failed to get place details: ${data['error_message']}');
        }
      } else {
        debugPrint('❌ HTTP Error: ${response.statusCode}');
        throw Exception('HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching place details: $e');
      rethrow;
    }
  }

  /// Helper method to generate activities from place types
  List<String> _getActivitiesFromTypes(List<String> types) {
    final activities = <String>[];
    
    for (final type in types) {
      switch (type) {
        case 'restaurant':
          activities.add('Dining');
          break;
        case 'cafe':
          activities.add('Coffee');
          break;
        case 'bar':
          activities.add('Drinks');
          break;
        case 'museum':
          activities.add('Culture');
          break;
        case 'park':
          activities.add('Nature');
          break;
        case 'shopping_mall':
          activities.add('Shopping');
          break;
        case 'tourist_attraction':
          activities.add('Sightseeing');
          break;
      }
    }
    
    return activities.toSet().toList(); // Remove duplicates
  }

  /// Helper method to validate photo references
  bool isValidPhotoReference(String reference) {
    // Photo references should be non-empty strings
    return reference.isNotEmpty;
  }

  /// Helper method to generate description from place types
  String _generateDescriptionFromTypes(List<String> types, String name) {
    if (types.isEmpty) return 'Discover $name';
    
    final mainType = types[0].replaceAll('_', ' ');
    
    switch (mainType) {
      case 'restaurant':
        return 'A dining establishment offering delicious cuisine';
      case 'cafe':
        return 'A cozy cafe perfect for coffee and light bites';
      case 'bar':
        return 'A vibrant spot for drinks and socializing';
      case 'museum':
        return 'A cultural institution showcasing art and history';
      case 'park':
        return 'A peaceful green space for outdoor activities';
      case 'shopping_mall':
        return 'A retail destination with various shops';
      case 'tourist_attraction':
        return 'A popular attraction worth visiting';
      default:
        return 'Discover $name, a $mainType establishment';
    }
  }

  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    if (photoReference.isEmpty) {
      debugPrint('⚠️ Empty photo reference provided');
      return ''; // Return empty string for invalid photo reference
    }

    try {
      return '$baseUrl${ApiConstants.placePhotos}'
          '?maxwidth=$maxWidth'
          '&maxheight=$maxWidth' // Adding maxheight parameter
          '&photo_reference=$photoReference'
          '&key=$apiKey';
    } catch (e) {
      debugPrint('❌ Error constructing photo URL: $e');
      return '';
    }
  }
} 