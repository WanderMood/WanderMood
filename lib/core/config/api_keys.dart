import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiKeys {
  static String get googlePlacesApi {
    try {
      // First try to get from .env file
      final envKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (envKey != null && envKey.isNotEmpty) {
        debugPrint('📍 Using Google Maps API key from .env file');
        return envKey;
      }

      // Fallback to build-time environment variable
      final buildTimeKey = const String.fromEnvironment(
        'GOOGLE_MAPS_API_KEY',
        defaultValue: '',
      );
      
      if (buildTimeKey.isNotEmpty) {
        debugPrint('📍 Using Google Maps API key from build-time environment');
        return buildTimeKey;
      }

      debugPrint('⚠️ No Google Maps API key found in environment variables');
      return '';
    } catch (e) {
      debugPrint('❌ Error loading Google Maps API key: $e');
      return '';
    }
  }
} 