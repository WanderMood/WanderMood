import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wandermood/core/services/cache_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences in main.dart');
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CacheService(prefs);
}); 