import 'dart:math' as math;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/place.dart';

final placesServiceProvider = AsyncNotifierProvider<PlacesService, List<Place>>(
  PlacesService.new,
);

class PlacesService extends AsyncNotifier<List<Place>> {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const double rotterdamLat = 51.9244;
  static const double rotterdamLng = 4.4777;

  @override
  Future<List<Place>> build() async {
    return [];
  }

  Future<List<Place>> getPlaces() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/nearbysearch/json?'
            'location=$rotterdamLat,$rotterdamLng'
            '&radius=5000'
            '&type=tourist_attraction'
            '&key=${dotenv.env['GOOGLE_PLACES_API_KEY']}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final places = (data['results'] as List)
              .map((place) => Place.fromJson(place))
              .toList();
          state = AsyncData(places);
          return places;
        }
      }
      throw Exception('Failed to load places');
    } catch (e) {
      debugPrint('❌ Places API Error: $e');
      throw e;
    }
  }

  Future<List<Place>> searchPlaces(String query) async {
    try {
      debugPrint('🔍 Searching for places with query: $query');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/textsearch/json?'
            'query=$query'
            '&location=$rotterdamLat,$rotterdamLng'
            '&radius=5000'
            '&key=${dotenv.env['GOOGLE_PLACES_API_KEY']}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('📍 Places API Response Status: ${data['status']}');
        
        if (data['status'] == 'OK') {
          final places = (data['results'] as List)
              .map((place) => Place.fromJson(place))
              .toList();
          debugPrint('✅ Found ${places.length} places');
          places.forEach((place) => debugPrint('  - ${place.name} (${place.placeId})'));
          return places;
        } else if (data['status'] == 'ZERO_RESULTS') {
          debugPrint('❌ Places API Error: ZERO_RESULTS');
          return [];
        }
      }
      throw Exception('Failed to search places');
    } catch (e) {
      debugPrint('❌ Places API Error: $e');
      throw e;
    }
  }

  double calculateDistance(double lat, double lng) {
    final dlat = (lat - rotterdamLat) * 111.32;
    final dlng = (lng - rotterdamLng) * (111.32 * math.cos(rotterdamLat * 0.018));
    return math.sqrt(dlat * dlat + dlng * dlng);
  }
} 