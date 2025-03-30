import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/weather_data.dart';
import '../domain/models/weather_forecast.dart';
import '../domain/models/weather_alert.dart';
import '../domain/models/location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'weather_cache_service.dart';
import 'package:weather/weather.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';

part 'weather_service.g.dart';

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}

@riverpod
class WeatherService extends _$WeatherService {
  final _weatherFactory = WeatherFactory('YOUR_OPENWEATHER_API_KEY');
  final _cacheService = WeatherCacheService();
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = 'YOUR_OPENWEATHER_API_KEY';

  @override
  FutureOr<WeatherData> build() async {
    final locationState = ref.watch(locationProvider);
    return locationState.when(
      data: (location) async {
        if (location == null) {
          // Fallback to default location if none is set
          final defaultLocation = Location(
            id: 'amsterdam',
            name: 'Amsterdam',
            latitude: 52.3676,
            longitude: 4.9041,
          );
          return getCurrentWeather(defaultLocation);
        }
        
        final locationObj = Location(
          id: location.toLowerCase(),
          name: location,
          // You might want to implement geocoding here to get lat/long
          latitude: 52.3676, // Default for now
          longitude: 4.9041, // Default for now
        );
        return getCurrentWeather(locationObj);
      },
      loading: () async {
        final defaultLocation = Location(
          id: 'amsterdam',
          name: 'Amsterdam',
          latitude: 52.3676,
          longitude: 4.9041,
        );
        return getCurrentWeather(defaultLocation);
      },
      error: (_, __) async {
        final defaultLocation = Location(
          id: 'amsterdam',
          name: 'Amsterdam',
          latitude: 52.3676,
          longitude: 4.9041,
        );
        return getCurrentWeather(defaultLocation);
      },
    );
  }

  Future<WeatherData> getCurrentWeather(Location location) async {
    try {
      final weather = await _weatherFactory.currentWeatherByLocation(
        location.latitude,
        location.longitude,
      );

      return WeatherData(
        temperature: weather.temperature?.celsius ?? 0,
        conditions: weather.weatherMain ?? '',
        humidity: weather.humidity ?? 0,
        windSpeed: weather.windSpeed ?? 0,
        precipitation: weather.rainLastHour ?? 0,
        description: weather.weatherDescription ?? '',
        icon: weather.weatherIcon ?? '',
        timestamp: weather.date,
      );
    } catch (e) {
      throw Exception('Fout bij het ophalen van het weer: $e');
    }
  }

  Future<List<WeatherForecast>> getWeatherForecast(
    Location location, {
    int days = 5,
  }) async {
    try {
      // Probeer eerst gecachede voorspellingen te laden
      final cachedForecasts = await _cacheService.getCachedForecasts(location);
      if (cachedForecasts != null) {
        return cachedForecasts;
      }

      final response = await http.get(Uri.parse(
        '$_baseUrl/forecast/daily?lat=${location.latitude}&lon=${location.longitude}&appid=$_apiKey&units=metric&lang=nl&cnt=$days'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['daily'];
        final forecasts = list.map((item) => WeatherForecast.fromJson(item)).toList();
        
        // Cache de voorspellingen
        await _cacheService.cacheForecasts(location, forecasts);
        
        return forecasts;
      } else {
        throw Exception('Kon weervoorspellingen niet ophalen');
      }
    } catch (e) {
      print('Error fetching forecasts: $e');
      return [];
    }
  }

  Future<List<WeatherAlert>> getWeatherAlerts(Location location) async {
    try {
      // Probeer eerst gecachede alerts te laden
      final cachedAlerts = await _cacheService.getCachedAlerts();
      if (cachedAlerts != null) {
        return cachedAlerts;
      }

      final response = await http.get(Uri.parse(
        '$_baseUrl/onecall?lat=${location.latitude}&lon=${location.longitude}&appid=$_apiKey&exclude=minutely,hourly,daily&alerts=1'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> alerts = data['alerts'] ?? [];
        final weatherAlerts = alerts.map((alert) => WeatherAlert.fromJson(alert)).toList();
        
        // Cache de alerts
        await _cacheService.cacheAlerts(weatherAlerts);
        
        return weatherAlerts;
      } else {
        throw Exception('Kon weeralerts niet ophalen');
      }
    } catch (e) {
      print('Error fetching alerts: $e');
      return [];
    }
  }

  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }
} 