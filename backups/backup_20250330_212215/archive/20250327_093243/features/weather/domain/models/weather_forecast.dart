import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_forecast.freezed.dart';
part 'weather_forecast.g.dart';

@freezed
class WeatherForecast with _$WeatherForecast {
  const factory WeatherForecast({
    required String id,
    required DateTime date,
    required double maxTemperature,
    required double minTemperature,
    required String conditions,
    required int humidity,
    @JsonKey(name: 'wind_speed')
    required double windSpeed,
    required double precipitation,
    String? description,
    String? icon,
    @JsonKey(name: 'sunrise')
    required DateTime sunrise,
    @JsonKey(name: 'sunset')
    required DateTime sunset,
    @JsonKey(name: 'uv_index')
    required double uvIndex,
  }) = _WeatherForecast;

  factory WeatherForecast.fromJson(Map<String, dynamic> json) =>
      _$WeatherForecastFromJson(json);
} 