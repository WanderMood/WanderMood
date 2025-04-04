class ApiConstants {
  // Google Places API
  static const String placesApiKey = 'YOUR_PLACES_API_KEY';
  static const String placesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  // OpenAI API
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY';
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