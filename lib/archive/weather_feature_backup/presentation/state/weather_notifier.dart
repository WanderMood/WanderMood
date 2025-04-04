import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../application/weather_service.dart';
import '../../domain/models/location.dart';
import '../../domain/models/weather_data.dart';
import 'weather_state.dart';

part 'weather_notifier.g.dart';

@riverpod
class WeatherNotifier extends _$WeatherNotifier {
  late final WeatherService _weatherService;
  StreamSubscription<WeatherData>? _weatherSubscription;

  @override
  WeatherState build() {
    _weatherService = ref.watch(weatherServiceProvider);
    return const WeatherState.initial();
  }

  Future<void> getCurrentWeather(Location location) async {
    state = const WeatherState.loading();

    try {
      final weatherData = await _weatherService.getCurrentWeather(location);
      state = WeatherState.loaded(
        currentWeather: weatherData,
        location: location,
      );
    } catch (e) {
      state = WeatherState.error(e.toString());
    }
  }

  Future<void> getHistoricalWeather(
    Location location,
    DateTime start,
    DateTime end,
  ) async {
    state = const WeatherState.loading();

    try {
      final range = DateRange(start: start, end: end);
      final historicalData = await _weatherService.getHistoricalWeather(
        location,
        range,
      );

      // Haal ook huidige weer op als we dat nog niet hebben
      final currentWeather = state.maybeMap(
        loaded: (s) => s.currentWeather,
        orElse: () => null,
      );

      if (currentWeather == null) {
        final current = await _weatherService.getCurrentWeather(location);
        state = WeatherState.loaded(
          currentWeather: current,
          location: location,
          historicalWeather: historicalData,
        );
      } else {
        state = WeatherState.loaded(
          currentWeather: currentWeather,
          location: location,
          historicalWeather: historicalData,
        );
      }
    } catch (e) {
      state = WeatherState.error(e.toString());
    }
  }

  void startWatchingWeather(Location location) {
    _weatherSubscription?.cancel();
    
    _weatherSubscription = _weatherService
        .watchWeatherUpdates(location)
        .listen(
          (weatherData) => state = WeatherState.loaded(
            currentWeather: weatherData,
            location: location,
            historicalWeather: state.maybeMap(
              loaded: (s) => s.historicalWeather,
              orElse: () => null,
            ),
          ),
          onError: (e) => state = WeatherState.error(e.toString()),
        );
  }

  void stopWatchingWeather() {
    _weatherSubscription?.cancel();
    _weatherSubscription = null;
  }

  @override
  void dispose() {
    _weatherSubscription?.cancel();
    super.dispose();
  }
} 