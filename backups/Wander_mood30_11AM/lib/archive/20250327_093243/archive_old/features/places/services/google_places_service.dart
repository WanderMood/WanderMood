import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wandermood/features/places/models/place.dart';
import 'package:wandermood/features/mood/models/mood_based_plan.dart';
import 'package:geolocator/geolocator.dart';

class GooglePlacesService {
  final String apiKey;
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';

  GooglePlacesService({required this.apiKey});

  Future<PlacesSearchResult> findPlacesForActivity(
    ActivitySuggestion activity,
    Position userLocation,
    {
      int radius = 5000,
      String? pageToken,
    }
  ) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/nearbysearch/json'
        '?location=${userLocation.latitude},${userLocation.longitude}'
        '&radius=$radius'
        '&type=${activity.placeType}'
        '&keyword=${activity.keywords.join('|')}'
        '${pageToken != null ? '&pagetoken=$pageToken' : ''}'
        '&key=$apiKey'
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];
        final String? nextPageToken = data['next_page_token'];
        
        final places = await Future.wait(
          results.map((result) async {
            final details = await _getPlaceDetails(result['place_id']);
            
            return Place(
              id: result['place_id'],
              name: result['name'],
              address: result['vicinity'],
              description: result['vicinity'] ?? result['name'],
              rating: result['rating']?.toDouble(),
              photos: result['photos']?.map<String>(
                (photo) => 'https://maps.googleapis.com/maps/api/place/photo'
                         '?maxwidth=400'
                         '&photo_reference=${photo['photo_reference']}'
                         '&key=$apiKey'
              ).toList() ?? [],
              types: List<String>.from(result['types']),
              location: PlaceLocation(
                lat: result['geometry']['location']['lat'],
                lng: result['geometry']['location']['lng'],
              ),
              openingHours: details['opening_hours'],
              phoneNumber: details['formatted_phone_number'],
              website: details['website'],
              priceLevel: details['price_level'],
            );
          }),
        );

        return PlacesSearchResult(
          places: places,
          nextPageToken: nextPageToken,
        );
      } else {
        throw Exception('Failed to fetch places: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error finding places for activity: $e');
      return PlacesSearchResult(places: [], nextPageToken: null);
    }
  }

  Future<Map<String, dynamic>> _getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/details/json'
          '?place_id=$placeId'
          '&fields=opening_hours,formatted_phone_number,website,price_level'
          '&key=$apiKey'
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'];
      } else {
        throw Exception('Failed to fetch place details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting place details: $e');
      return {};
    }
  }

  Future<PlacesSearchResult> searchPlaces({
    String? query,
    String? city,
    int radius = 5000,
    String? pageToken,
  }) async {
    try {
      final searchQuery = [
        if (city != null) city,
        if (query != null) query,
      ].join(' ');

      final uri = Uri.parse(
        '$baseUrl/textsearch/json'
        '?query=$searchQuery'
        '&radius=$radius'
        '${pageToken != null ? '&pagetoken=$pageToken' : ''}'
        '&key=$apiKey'
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];
        final String? nextPageToken = data['next_page_token'];
        
        final places = results.map((result) => Place(
          id: result['place_id'],
          name: result['name'],
          description: result['formatted_address'] ?? '',
          latitude: result['geometry']['location']['lat'],
          longitude: result['geometry']['location']['lng'],
          address: result['formatted_address'] ?? '',
          categories: List<String>.from(result['types'] ?? []),
          rating: result['rating']?.toDouble() ?? 0.0,
          reviewCount: result['user_ratings_total'] ?? 0,
          imageUrl: result['photos']?.isNotEmpty == true
              ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${result['photos'][0]['photo_reference']}&key=$apiKey'
              : '',
          isOpen: result['opening_hours']?['open_now'] ?? false,
          openingHours: result['opening_hours']?.weekdayText?.asMap() ?? {},
          photos: result['photos']?.map<String>((p) => p['photo_reference']).toList() ?? [],
          contact: {
            'phone': result['formatted_phone_number'],
            'website': result['website'],
          },
          location: {
            'lat': result['geometry']['location']['lat'],
            'lng': result['geometry']['location']['lng'],
          },
          amenities: (result['types'] as List<dynamic>?)?.map((type) => {
            'name': type,
            'icon': _getAmenityIcon(type.toString()),
          }).toList() ?? [],
          distance: 0,
          isFavorite: false,
        )).toList();

        return PlacesSearchResult(
          places: places,
          nextPageToken: nextPageToken,
        );
      } else {
        throw Exception('Failed to search places: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching places: $e');
      return PlacesSearchResult(places: [], nextPageToken: null);
    }
  }

  Future<Place> getPlaceById(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/details/json'
          '?place_id=$placeId'
          '&fields=name,formatted_address,rating,photos,types,geometry,price_level,opening_hours,vicinity,user_ratings_total,formatted_phone_number,website'
          '&key=$apiKey'
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'];
        
        return Place(
          id: placeId,
          name: result['name'],
          description: result['vicinity'] ?? result['formatted_address'] ?? '',
          latitude: result['geometry']['location']['lat'],
          longitude: result['geometry']['location']['lng'],
          address: result['formatted_address'] ?? '',
          categories: List<String>.from(result['types'] ?? []),
          rating: result['rating']?.toDouble() ?? 0.0,
          reviewCount: result['user_ratings_total'] ?? 0,
          imageUrl: result['photos']?.isNotEmpty == true
              ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${result['photos'][0]['photo_reference']}&key=$apiKey'
              : '',
          isOpen: result['opening_hours']?['open_now'] ?? false,
          openingHours: result['opening_hours']?.weekdayText?.asMap() ?? {},
          photos: result['photos']?.map<String>((p) => p['photo_reference']).toList() ?? [],
          contact: {
            'phone': result['formatted_phone_number'],
            'website': result['website'],
          },
          location: {
            'lat': result['geometry']['location']['lat'],
            'lng': result['geometry']['location']['lng'],
          },
          amenities: (result['types'] as List<dynamic>?)?.map((type) => {
            'name': type,
            'icon': _getAmenityIcon(type.toString()),
          }).toList() ?? [],
          distance: 0,
          isFavorite: false,
        );
      } else {
        throw Exception('Failed to get place details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting place by ID: $e');
      throw Exception('Failed to get place details: $e');
    }
  }

  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    String? category,
    int page = 1,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/nearbysearch/json'
        '?location=$latitude,$longitude'
        '&radius=5000'
        '${category != null ? '&type=$category' : ''}'
        '&key=$apiKey'
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];
        
        return results.map((result) => Place(
          id: result['place_id'],
          name: result['name'],
          description: result['vicinity'] ?? '',
          latitude: result['geometry']['location']['lat'],
          longitude: result['geometry']['location']['lng'],
          address: result['vicinity'] ?? '',
          categories: List<String>.from(result['types'] ?? []),
          rating: result['rating']?.toDouble() ?? 0.0,
          reviewCount: result['user_ratings_total'] ?? 0,
          imageUrl: result['photos']?.isNotEmpty == true
              ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${result['photos'][0]['photo_reference']}&key=$apiKey'
              : '',
          isOpen: result['opening_hours']?['open_now'] ?? false,
          openingHours: result['opening_hours']?.weekdayText?.asMap() ?? {},
          photos: result['photos']?.map<String>((p) => p['photo_reference']).toList() ?? [],
          contact: {
            'phone': result['formatted_phone_number'],
            'website': result['website'],
          },
          location: {
            'lat': result['geometry']['location']['lat'],
            'lng': result['geometry']['location']['lng'],
          },
          amenities: (result['types'] as List<dynamic>?)?.map((type) => {
            'name': type,
            'icon': _getAmenityIcon(type.toString()),
          }).toList() ?? [],
          distance: 0,
          isFavorite: false,
        )).toList();
      } else {
        throw Exception('Failed to fetch nearby places: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting nearby places: $e');
      return [];
    }
  }

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
}

class PlacesSearchResult {
  final List<Place> places;
  final String? nextPageToken;

  PlacesSearchResult({
    required this.places,
    this.nextPageToken,
  });
} 