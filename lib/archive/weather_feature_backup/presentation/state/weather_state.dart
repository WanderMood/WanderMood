import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/weather_data.dart';
import '../../domain/models/location.dart';

part 'weather_state.freezed.dart';

@freezed
class WeatherState with _$WeatherState {
  const factory WeatherState.initial() = _Initial;
  
  const factory WeatherState.loading() = _Loading;
  
  const factory WeatherState.loaded({
    required WeatherData currentWeather,
    required Location location,
    List<WeatherData>? historicalWeather,
  }) = _Loaded;
  
  const factory WeatherState.error(String message) = _Error;
} 