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
import 'package:wandermood/features/location/providers/location_provider.dart';
import 'package:wandermood/features/location/services/location_service.dart';

part 'weather_service.g.dart';

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}

@riverpod
class WeatherService extends _$WeatherService {
  final _cacheService = WeatherCacheService();
  static const String _baseUrl = 'https://api.open-meteo.com/v1';

  @override
  FutureOr<WeatherData> build() async {
    final locationState = ref.watch(locationProvider);
    return locationState.when(
      data: (locationName) async {
        if (locationName == null) {
          // Fallback to default location if none is set
          final defaultLocation = Location(
            id: 'rotterdam',
            name: 'Rotterdam',
            latitude: 51.9244,
            longitude: 4.4777,
          );
          return getCurrentWeather(defaultLocation);
        }
        
        try {
          final coordinates = await LocationService.getCoordinatesForCity(locationName);
          final locationObj = Location(
            id: locationName.toLowerCase(),
            name: locationName,
            latitude: coordinates.latitude,
            longitude: coordinates.longitude,
          );
          return getCurrentWeather(locationObj);
        } catch (e) {
          // Fallback to default location if geocoding fails
          final defaultLocation = Location(
            id: 'rotterdam',
            name: 'Rotterdam',
            latitude: 51.9244,
            longitude: 4.4777,
          );
          return getCurrentWeather(defaultLocation);
        }
      },
      loading: () async {
        final defaultLocation = Location(
          id: 'rotterdam',
          name: 'Rotterdam',
          latitude: 51.9244,
          longitude: 4.4777,
        );
        return getCurrentWeather(defaultLocation);
      },
      error: (_, __) async {
        final defaultLocation = Location(
          id: 'rotterdam',
          name: 'Rotterdam',
          latitude: 51.9244,
          longitude: 4.4777,
        );
        return getCurrentWeather(defaultLocation);
      },
    );
  }

  Future<WeatherData> getCurrentWeather(Location location) async {
    try {
      final response = await http.get(Uri.parse(
        '$_baseUrl/forecast?'
        'latitude=${location.latitude}'
        '&longitude=${location.longitude}'
        '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation,weather_code'
        '&timezone=auto'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        
        // Map OpenMeteo weather codes to conditions
        final weatherCode = current['weather_code'] as int;
        final (conditions, description, icon) = _mapWeatherCode(weatherCode);

        return WeatherData(
          temperature: current['temperature_2m'].toDouble(),
          conditions: conditions,
          humidity: current['relative_humidity_2m'].toDouble(),
          windSpeed: current['wind_speed_10m'].toDouble(),
          precipitation: current['precipitation'].toDouble(),
          description: description,
          icon: icon,
          timestamp: DateTime.parse(current['time']),
        );
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  Future<List<WeatherForecast>> getWeatherForecast(
    Location location, {
    int days = 5,
  }) async {
    try {
      // Try to load cached forecasts first
      final cachedForecasts = await _cacheService.getCachedForecasts(location);
      if (cachedForecasts != null) {
        return cachedForecasts;
      }

      final response = await http.get(Uri.parse(
        '$_baseUrl/forecast?'
        'latitude=${location.latitude}'
        '&longitude=${location.longitude}'
        '&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code,precipitation_sum,sunrise,sunset,uv_index_max,relative_humidity_2m_max'
        '&timezone=auto'
        '&forecast_days=$days'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final daily = data['daily'];
        
        final List<WeatherForecast> forecasts = [];
        for (int i = 0; i < days; i++) {
          final weatherCode = daily['weather_code'][i] as int;
          final (conditions, description, icon) = _mapWeatherCode(weatherCode);
          
          forecasts.add(WeatherForecast(
            date: DateTime.parse(daily['time'][i]),
            maxTemperature: daily['temperature_2m_max'][i].toDouble(),
            minTemperature: daily['temperature_2m_min'][i].toDouble(),
            conditions: conditions,
            precipitationProbability: daily['precipitation_probability_max'][i].toDouble(),
            humidity: daily['relative_humidity_2m_max'][i].toDouble(),
            precipitation: daily['precipitation_sum'][i].toDouble(),
            sunrise: DateTime.parse(daily['sunrise'][i]),
            sunset: DateTime.parse(daily['sunset'][i]),
            uvIndex: daily['uv_index_max'][i].toDouble(),
            description: description,
            icon: icon,
          ));
        }
        
        // Cache the forecasts
        await _cacheService.cacheForecasts(location, forecasts);
        
        return forecasts;
      } else {
        throw Exception('Failed to load weather forecast');
      }
    } catch (e) {
      print('Error fetching forecasts: $e');
      return [];
    }
  }

  // Helper method to map OpenMeteo weather codes to conditions
  (String, String, String) _mapWeatherCode(int code) {
    switch (code) {
      case 0:
        return ('Clear', 'Clear sky', '01d');
      case 1:
      case 2:
      case 3:
        return ('Clouds', 'Partly cloudy', '02d');
      case 45:
      case 48:
        return ('Fog', 'Foggy', '50d');
      case 51:
      case 53:
      case 55:
        return ('Drizzle', 'Light drizzle', '09d');
      case 61:
      case 63:
      case 65:
        return ('Rain', 'Rain', '10d');
      case 71:
      case 73:
      case 75:
        return ('Snow', 'Snow', '13d');
      case 77:
        return ('Snow', 'Snow grains', '13d');
      case 80:
      case 81:
      case 82:
        return ('Rain', 'Heavy rain', '10d');
      case 85:
      case 86:
        return ('Snow', 'Heavy snow', '13d');
      case 95:
        return ('Thunderstorm', 'Thunderstorm', '11d');
      case 96:
      case 99:
        return ('Thunderstorm', 'Thunderstorm with hail', '11d');
      default:
        return ('Unknown', 'Unknown weather condition', '01d');
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
        '$_baseUrl/forecast?'
        'latitude=${location.latitude}'
        '&longitude=${location.longitude}'
        '&daily=weather_code'
        '&timezone=auto'
        '&forecast_days=1'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final daily = data['daily'];
        
        final List<WeatherAlert> alerts = [];
        for (int i = 0; i < 1; i++) {
          final weatherCode = daily['weather_code'][i] as int;
          final (conditions, description, icon) = _mapWeatherCode(weatherCode);
          
          alerts.add(WeatherAlert(
            date: DateTime.parse(daily['time'][i]),
            conditions: conditions,
            description: description,
            icon: icon,
          ));
        }
        
        // Cache the alerts
        await _cacheService.cacheAlerts(alerts);
        
        return alerts;
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