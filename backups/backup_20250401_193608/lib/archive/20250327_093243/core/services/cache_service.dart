import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wandermood/features/mood/models/mood_based_plan.dart';

class CacheService {
  static const String _recommendationsKey = 'cached_recommendations';
  static const Duration _cacheDuration = Duration(hours: 1);

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  Future<void> cacheRecommendations(MoodBasedPlanData recommendations) async {
    final recommendationsJson = recommendations.toJson();
    final timestamp = DateTime.now().toIso8601String();
    
    await _prefs.setString(_recommendationsKey, jsonEncode({
      'timestamp': timestamp,
      'data': recommendationsJson,
    }));
  }

  Future<MoodBasedPlanData?> getCachedRecommendations() async {
    final cachedData = _prefs.getString(_recommendationsKey);
    if (cachedData == null) return null;

    final decoded = jsonDecode(cachedData);
    final timestamp = DateTime.parse(decoded['timestamp']);
    
    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      await _prefs.remove(_recommendationsKey);
      return null;
    }

    return MoodBasedPlanData.fromJson(decoded['data']);
  }

  Future<void> clearCache() async {
    await _prefs.remove(_recommendationsKey);
  }
} 