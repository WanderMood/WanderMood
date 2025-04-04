import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wandermood/core/domain/providers/location_notifier_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

// Weather data model
class WeatherData {
  final String location;
  final double temperature;
  final String condition;
  final String iconUrl;
  final Map<String, dynamic> details;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
    required this.details,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String location) {
    return WeatherData(
      location: location,
      temperature: json['current']['temp_c'],
      condition: json['current']['condition']['text'],
      iconUrl: 'https:${json['current']['condition']['icon']}',
      details: {
        'feelsLike': json['current']['feelslike_c'],
        'humidity': json['current']['humidity'],
        'windSpeed': json['current']['wind_kph'],
        'uv': json['current']['uv'],
        'precip': json['current']['precip_mm'],
      },
    );
  }
}

// Mock weather data for demo purposes
WeatherData getMockWeatherData(String location) {
  return WeatherData(
    location: location,
    temperature: 32,
    condition: 'Sunny',
    iconUrl: 'https://cdn.weatherapi.com/weather/64x64/day/113.png',
    details: {
      'feelsLike': 34,
      'humidity': 45,
      'windSpeed': 19,
      'uv': 6,
      'precip': 0,
    },
  );
}

// Weather provider that depends on location
final weatherProvider = FutureProvider.autoDispose<WeatherData?>((ref) async {
  final locationState = await ref.watch(locationNotifierProvider.future);
  if (locationState == null) return null;
  
  // Get API key from environment
  final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  debugPrint('🌤️ Weather API Key: ${apiKey.isEmpty ? 'EMPTY' : 'EXISTS (${apiKey.length} chars)'}');
  debugPrint('🌤️ Weather location: $locationState');
  
  // Use real API if key is available
  if (apiKey.isNotEmpty && apiKey != 'YOUR_ACTUAL_API_KEY_HERE') {
    try {
      final url = 'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$locationState&aqi=no';
      debugPrint('🌤️ Weather URL: $url');
      
      final response = await http.get(Uri.parse(url));
      debugPrint('🌤️ Weather API response code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('🌤️ Weather API response: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
        return WeatherData.fromJson(data, locationState);
      } else {
        debugPrint('🌤️ Weather API error: ${response.body}');
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data if API fails
      debugPrint('🌤️ Weather API exception: $e');
      return getMockWeatherData(locationState);
    }
  } else {
    // Use mock data if no valid API key
    debugPrint('🌤️ Using mock data: No valid API key');
    return getMockWeatherData(locationState);
  }
}); 