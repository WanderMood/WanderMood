import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get openAIKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get googlePlacesKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
  static String get weatherKey => dotenv.env['WEATHER_API_KEY'] ?? '';

  static Future<void> initialize() async {
    await dotenv.load();
    
    // Validate required keys
    if (openAIKey.isEmpty) {
      throw Exception('OPENAI_API_KEY is not set in .env file');
    }
    if (googlePlacesKey.isEmpty) {
      throw Exception('GOOGLE_PLACES_API_KEY is not set in .env file');
    }
    // Weather key is optional for now
  }
} 