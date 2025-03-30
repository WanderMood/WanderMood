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
    PlaceLocation? location,
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
        '${location != null ? '&location=${location.lat},${location.lng}' : ''}'
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
          address: result['formatted_address'],
          description: result['formatted_address'] ?? result['name'],
          rating: result['rating']?.toDouble() ?? 0.0,
          photos: result['photos']?.map<String>(
            (photo) => 'https://maps.googleapis.com/maps/api/place/photo'
                     '?maxwidth=400'
                     '&photo_reference=${photo['photo_reference']}'
                     '&key=$apiKey'
          ).toList() ?? [],
          types: List<String>.from(result['types'] ?? []),
          location: PlaceLocation(
            lat: result['geometry']['location']['lat'],
            lng: result['geometry']['location']['lng'],
          ),
          priceLevel: result['price_level'],
          openingHours: result['opening_hours'],
          isOpen: result['opening_hours']?['open_now'] ?? false,
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
          '&fields=name,formatted_address,rating,photos,types,geometry,price_level,opening_hours,vicinity'
          '&key=$apiKey'
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'];
        
        return Place(
          id: placeId,
          name: result['name'],
          address: result['formatted_address'] ?? '',
          description: result['vicinity'] ?? result['formatted_address'] ?? '',
          rating: result['rating']?.toDouble() ?? 0.0,
          photos: result['photos']?.map<String>(
            (photo) => 'https://maps.googleapis.com/maps/api/place/photo'
                     '?maxwidth=400'
                     '&photo_reference=${photo['photo_reference']}'
                     '&key=$apiKey'
          ).toList() ?? [],
          types: List<String>.from(result['types'] ?? []),
          location: PlaceLocation(
            lat: result['geometry']['location']['lat'],
            lng: result['geometry']['location']['lng'],
          ),
          priceLevel: result['price_level'],
          openingHours: result['opening_hours'],
          isOpen: result['opening_hours']?['open_now'] ?? false,
        );
      } else {
        throw Exception('Failed to get place details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting place by ID: $e');
      throw Exception('Failed to get place details: $e');
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