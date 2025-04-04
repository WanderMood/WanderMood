import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_alert.freezed.dart';
part 'weather_alert.g.dart';

@freezed
class WeatherAlert with _$WeatherAlert {
  const factory WeatherAlert({
    required DateTime date,
    required String conditions,
    required String description,
    required String icon,
  }) = _WeatherAlert;

  factory WeatherAlert.fromJson(Map<String, dynamic> json) =>
      _$WeatherAlertFromJson(json);
} 