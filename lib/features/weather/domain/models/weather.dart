import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/weather_location.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

@freezed
class Weather with _$Weather {
  const factory Weather({
    required String condition,
    required double temperature,
    required int humidity,
    required double windSpeed,
    required WeatherLocation location,
    String? icon,
    String? description,
    double? feelsLike,
    double? minTemp,
    double? maxTemp,
    int? pressure,
    DateTime? sunrise,
    DateTime? sunset,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) => _$WeatherFromJson(json);
} 