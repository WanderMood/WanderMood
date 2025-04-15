import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'recent_cities_provider.g.dart';

const _maxRecentCities = 3;
const _recentCitiesKey = 'recent_cities';

@riverpod
class RecentCities extends _$RecentCities {
  late SharedPreferences _prefs;

  @override
  Future<List<String>> build() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getStringList(_recentCitiesKey) ?? [];
  }

  Future<void> addCity(String cityName) async {
    state = const AsyncValue.loading();
    try {
      final currentCities = await future;
      if (currentCities.contains(cityName)) {
        // Move to top if already exists
        currentCities.remove(cityName);
      }
      // Add to beginning
      currentCities.insert(0, cityName);
      // Keep only the most recent cities
      if (currentCities.length > _maxRecentCities) {
        currentCities.removeLast();
      }
      // Save to persistent storage
      await _prefs.setStringList(_recentCitiesKey, currentCities);
      state = AsyncValue.data(currentCities);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearRecentCities() async {
    state = const AsyncValue.loading();
    try {
      await _prefs.remove(_recentCitiesKey);
      state = const AsyncValue.data([]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
} 