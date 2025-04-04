import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_location.freezed.dart';
part 'weather_location.g.dart';

@freezed
class WeatherLocation with _$WeatherLocation {
  const factory WeatherLocation({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
  }) = _WeatherLocation;

  factory WeatherLocation.fromJson(Map<String, dynamic> json) =>
      _$WeatherLocationFromJson(json);
} 