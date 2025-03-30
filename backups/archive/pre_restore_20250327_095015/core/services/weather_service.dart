import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class DayForecast {
  final DateTime date;
  final double temperature;
  final String condition;
  final double windSpeed;
  final int uvIndex;
  final String sunriseTime;
  final String sunsetTime;
  final int aqi;

  DayForecast({
    required this.date,
    required this.temperature,
    required this.condition,
    required this.windSpeed,
    required this.uvIndex,
    required this.sunriseTime,
    required this.sunsetTime,
    required this.aqi,
  });

  factory DayForecast.fromJson(Map<String, dynamic> json) {
    return DayForecast(
      date: DateTime.parse(json['date']),
      temperature: json['temperature'].toDouble(),
      condition: json['condition'],
      windSpeed: json['windSpeed'].toDouble(),
      uvIndex: json['uvIndex'],
      sunriseTime: json['sunriseTime'],
      sunsetTime: json['sunsetTime'],
      aqi: json['aqi'],
    );
  }
}

final weatherServiceProvider = AsyncNotifierProvider<WeatherService, DayForecast>(
  WeatherService.new,
);

class WeatherService extends AsyncNotifier<DayForecast> {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const double rotterdamLat = 51.9244;
  static const double rotterdamLng = 4.4777;

  @override
  Future<DayForecast> build() async {
    return getCurrentWeather();
  }

  Future<DayForecast> getCurrentWeather() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?'
            'lat=$rotterdamLat'
            '&lon=$rotterdamLng'
            '&appid=${dotenv.env['OPENWEATHER_API_KEY']}'
            '&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = DayForecast(
          date: DateTime.now(),
          temperature: data['main']['temp'].toDouble(),
          condition: data['weather'][0]['main'],
          windSpeed: data['wind']['speed'].toDouble(),
          uvIndex: 0, // Not available in free tier
          sunriseTime: DateTime.fromMillisecondsSinceEpoch(data['sys']['sunrise'] * 1000)
              .toString()
              .substring(11, 16),
          sunsetTime: DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000)
              .toString()
              .substring(11, 16),
          aqi: 0, // Not available in free tier
        );
        state = AsyncData(weather);
        return weather;
      }
      throw Exception('Failed to load weather');
    } catch (e) {
      debugPrint('❌ Weather API Error: $e');
      throw e;
    }
  }
} 