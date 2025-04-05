import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_data.freezed.dart';
part 'weather_data.g.dart';

@freezed
class WeatherData with _$WeatherData {
  const factory WeatherData({
    required double temperature,
    required String conditions,
    required num humidity,
    required double windSpeed,
    required String description,
    required String icon,
    required String location,
    double? feelsLike,
    double? minTemp,
    double? maxTemp,
    int? pressure,
    DateTime? sunrise,
    DateTime? sunset,
    @Default(null) DateTime? timestamp,
  }) = _WeatherData;

  factory WeatherData.fromJson(Map<String, dynamic> json) => _$WeatherDataFromJson(json);

  factory WeatherData.fromOpenWeatherMap(Map<String, dynamic> json, String location) {
    final main = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final sys = json['sys'] as Map<String, dynamic>;
    
    return WeatherData(
      temperature: (main['temp'] as num).toDouble(),
      conditions: weather['main'] as String,
      humidity: main['humidity'] as num,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      location: location,
      feelsLike: (main['feels_like'] as num).toDouble(),
      minTemp: (main['temp_min'] as num).toDouble(),
      maxTemp: (main['temp_max'] as num).toDouble(),
      pressure: main['pressure'] as int,
      sunrise: DateTime.fromMillisecondsSinceEpoch((sys['sunrise'] as int) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch((sys['sunset'] as int) * 1000),
      timestamp: DateTime.now(),
    );
  }
} 