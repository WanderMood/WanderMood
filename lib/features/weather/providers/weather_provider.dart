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

  factory WeatherData.fromOpenWeatherMap(Map<String, dynamic> json, String location) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    
    return WeatherData(
      location: location,
      temperature: (main['temp'] as num).toDouble(),
      condition: weather['main'],
      iconUrl: 'https://openweathermap.org/img/wn/${weather['icon']}@2x.png',
      details: {
        'feelsLike': main['feels_like'],
        'humidity': main['humidity'],
        'windSpeed': json['wind']['speed'],
        'pressure': main['pressure'],
        'description': weather['description'],
      },
    );
  }
}

// Mock weather data for demo purposes
WeatherData getMockWeatherData(String location) {
  return WeatherData(
    location: location,
    temperature: 22,
    condition: 'Clear',
    iconUrl: 'https://openweathermap.org/img/wn/01d@2x.png',
    details: {
      'feelsLike': 23,
      'humidity': 65,
      'windSpeed': 5.2,
      'pressure': 1013,
      'description': 'clear sky',
    },
  );
}

// Weather provider that depends on location
final weatherProvider = FutureProvider.autoDispose<WeatherData?>((ref) async {
  try {
    final locationState = ref.watch(locationNotifierProvider);
    
    if (locationState.isLoading) {
      return getMockWeatherData('Loading...');
    }
    
    if (locationState.hasError) {
      throw locationState.error!;
    }
    
    if (!locationState.hasCity) {
      return getMockWeatherData('Unknown Location');
    }

    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null) {
      debugPrint('⚠️ OpenWeather API key not found');
      return getMockWeatherData(locationState.city!);
    }

    final url = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      {
        'q': locationState.city,
        'appid': apiKey,
        'units': 'metric',
      },
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeatherData.fromOpenWeatherMap(data, locationState.city!);
    } else {
      debugPrint('⚠️ Weather API error: ${response.statusCode}');
      return getMockWeatherData(locationState.city!);
    }
  } catch (e) {
    debugPrint('❌ Error getting weather: $e');
    return getMockWeatherData('Unknown Location');
  }
}); 