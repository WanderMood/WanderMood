import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/place.dart';

part 'places_cache_provider.g.dart';

class PlacesCacheNotifier extends StateNotifier<Map<String, List<Place>>> {
  PlacesCacheNotifier() : super({});

  static const int MAX_CACHE_SIZE = 100; // Maximum number of places to cache
  static const Duration CACHE_DURATION = Duration(minutes: 30);
  
  final Map<String, DateTime> _cacheTimestamps = {};

  void cachePlaces(String key, List<Place> places) {
    // Clean old cache entries first
    _cleanCache();
    
    // Add new entry
    state = {...state, key: places};
    _cacheTimestamps[key] = DateTime.now();
  }

  List<Place>? getCachedPlaces(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;

    // Check if cache is still valid
    if (DateTime.now().difference(timestamp) > CACHE_DURATION) {
      // Cache expired, remove it
      _removeCacheEntry(key);
      return null;
    }

    return state[key];
  }

  void _cleanCache() {
    // Remove expired entries
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => now.difference(entry.value) > CACHE_DURATION)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _removeCacheEntry(key);
    }

    // If still too many entries, remove oldest
    while (state.length >= MAX_CACHE_SIZE) {
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _removeCacheEntry(oldestKey);
    }
  }

  void _removeCacheEntry(String key) {
    state = Map.from(state)..remove(key);
    _cacheTimestamps.remove(key);
  }

  String generateCacheKey(String city, String mood, int page) {
    return '$city:$mood:$page';
  }
}

@riverpod
class PlacesCache extends _$PlacesCache {
  @override
  PlacesCacheNotifier build() {
    return PlacesCacheNotifier();
  }
} 