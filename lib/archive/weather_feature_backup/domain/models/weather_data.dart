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
    required double precipitation,
    required String description,
    required String icon,
    @Default(null) DateTime? timestamp,
  }) = _WeatherData;

  factory WeatherData.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataFromJson(json);
} 