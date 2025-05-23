import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/weather_data.dart';
import '../domain/models/weather_forecast.dart';
import '../domain/models/weather_alert.dart';
import '../domain/models/weather_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'weather_cache_service.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';
import 'package:wandermood/features/location/services/location_service.dart';
import 'package:wandermood/features/weather/domain/models/weather.dart';
import 'package:wandermood/core/config/api_config.dart';

part 'weather_service.g.dart';

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}

@riverpod
class WeatherService extends _$WeatherService {
  final _cacheService = WeatherCacheService();
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  String get _apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  @override
  FutureOr<Weather?> build() async {
    final locationState = ref.watch(locationNotifierProvider);
    
    return locationState.when(
      data: (location) async {
        if (location == null) return null;
        final locationData = WeatherLocation(
          id: location.toLowerCase(),
          name: location,
          latitude: 0,
          longitude: 0,
        );
        return getCurrentWeather(locationData);
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Future<Weather> getCurrentWeather(WeatherLocation location) async {
    try {
      if (_apiKey.isEmpty) {
        throw Exception('OpenWeather API key is not configured');
      }

      final url = '$_baseUrl/weather?lat=${location.latitude}&lon=${location.longitude}&appid=$_apiKey&units=metric';
      print('Fetching weather from: $url');
      
      final response = await http.get(Uri.parse(url));
      print('Weather API response code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather(
          temperature: data['main']['temp'].toDouble(),
          condition: data['weather'][0]['main'],
          humidity: data['main']['humidity'],
          windSpeed: data['wind']['speed'].toDouble(),
          icon: data['weather'][0]['icon'],
          description: data['weather'][0]['description'],
          feelsLike: data['main']['feels_like'].toDouble(),
          minTemp: data['main']['temp_min'].toDouble(),
          maxTemp: data['main']['temp_max'].toDouble(),
          pressure: data['main']['pressure'],
          sunrise: DateTime.fromMillisecondsSinceEpoch(data['sys']['sunrise'] * 1000),
          sunset: DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000),
          location: location,
        );
      } else {
        print('Weather API error: ${response.body}');
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather: $e');
      throw Exception('Failed to load weather data: $e');
    }
  }

  Future<List<WeatherForecast>> getWeatherForecast(
    WeatherLocation location, {
    int days = 5,
  }) async {
    try {
      if (_apiKey.isEmpty) {
        throw Exception('OpenWeather API key is not configured');
      }

      // Try to load cached forecasts first
      final cachedForecasts = await _cacheService.getCachedForecasts(location);
      if (cachedForecasts != null) {
        return cachedForecasts;
      }

      final url = '$_baseUrl/forecast?lat=${location.latitude}&lon=${location.longitude}&appid=$_apiKey&units=metric';
      print('Fetching forecast from: $url');
      
      final response = await http.get(Uri.parse(url));
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<WeatherForecast> forecasts = [];
        
        // Group forecasts by day
        final Map<String, List<dynamic>> dailyForecasts = {};
        for (var item in data['list']) {
          final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          final dateKey = '${date.year}-${date.month}-${date.day}';
          
          if (!dailyForecasts.containsKey(dateKey)) {
            dailyForecasts[dateKey] = [];
          }
          dailyForecasts[dateKey]!.add(item);
        }
        
        // Process each day's forecasts
        for (var entry in dailyForecasts.entries.take(days)) {
          final forecasts = entry.value;
          final dayData = forecasts[0]; // Use first forecast of the day
          
          final temps = forecasts.map((f) => f['main']['temp'].toDouble()).toList();
          final maxTemp = temps.reduce((a, b) => a > b ? a : b);
          final minTemp = temps.reduce((a, b) => a < b ? a : b);
          
          forecasts.add(WeatherForecast(
            date: DateTime.fromMillisecondsSinceEpoch(dayData['dt'] * 1000),
            maxTemperature: maxTemp,
            minTemperature: minTemp,
            conditions: dayData['weather'][0]['main'],
            precipitationProbability: (dayData['pop'] * 100).toDouble(),
            humidity: dayData['main']['humidity'].toDouble(),
            precipitation: dayData['rain']?['3h']?.toDouble() ?? 0.0,
            sunrise: DateTime.now(), // Not available in free API
            sunset: DateTime.now(), // Not available in free API
            uvIndex: 0, // Not available in free API
            description: dayData['weather'][0]['description'],
            icon: dayData['weather'][0]['icon'],
          ));
        }
        
        // Cache the forecasts
        await _cacheService.cacheForecasts(location, forecasts);
        
        return forecasts;
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to load weather forecast: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching forecasts: $e');
      return [];
    }
  }

  Future<List<WeatherAlert>> getWeatherAlerts(WeatherLocation location) async {
    // Alerts are not available in the free API
    return [];
  }

  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }
} 