import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_alert.freezed.dart';
part 'weather_alert.g.dart';

@freezed
class WeatherAlert with _$WeatherAlert {
  const factory WeatherAlert({
    required String id,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String severity,
    required String type,
    required String source,
    required bool isActive,
    @Default(false) bool isRead,
  }) = _WeatherAlert;

  factory WeatherAlert.fromJson(Map<String, dynamic> json) =>
      _$WeatherAlertFromJson(json);
} 