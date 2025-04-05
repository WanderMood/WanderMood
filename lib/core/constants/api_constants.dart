import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Google Places API
  static String get placesApiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
  static const String placesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  // OpenAI API
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  
  // API Endpoints
  static const String nearbySearch = '/nearbysearch/json';
  static const String placeDetails = '/details/json';
  static const String placePhotos = '/photo';
  
  // OpenAI Endpoints
  static const String completions = '/chat/completions';
  
  // Place Types based on Moods
  static Map<String, List<String>> moodPlaceTypes = {
    'happy': ['amusement_park', 'park', 'restaurant', 'cafe'],
    'relaxed': ['spa', 'park', 'library', 'art_gallery'],
    'energetic': ['gym', 'stadium', 'amusement_park', 'shopping_mall'],
    'romantic': ['restaurant', 'cafe', 'movie_theater', 'art_gallery'],
    'adventurous': ['tourist_attraction', 'museum', 'zoo', 'aquarium'],
    'focused': ['library', 'cafe', 'book_store'],
  };
} 