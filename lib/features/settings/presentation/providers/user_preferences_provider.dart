import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wandermood/core/domain/models/user_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return UserPreferencesNotifier(sharedPrefs);
});

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final SharedPreferences _prefs;
  static const String _prefsKey = 'user_preferences';

  UserPreferencesNotifier(this._prefs) : super(UserPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefsJson = _prefs.getString(_prefsKey);
    if (prefsJson != null) {
      try {
        state = UserPreferences.fromJson(prefsJson);
      } catch (e) {
        // If there's an error parsing, use default preferences
        state = UserPreferences();
      }
    }
  }

  Future<void> _savePreferences() async {
    await _prefs.setString(_prefsKey, state.toJson());
  }

  // Update methods for settings screen
  Future<void> updateUseSystemTheme(bool value) async {
    state = state.copyWith(useSystemTheme: value);
    await _savePreferences();
  }

  Future<void> updateDarkMode(bool value) async {
    state = state.copyWith(darkMode: value);
    await _savePreferences();
  }

  Future<void> updateUseAnimations(bool value) async {
    state = state.copyWith(useAnimations: value);
    await _savePreferences();
  }

  Future<void> updateTripReminders(bool value) async {
    state = state.copyWith(tripReminders: value);
    await _savePreferences();
  }

  Future<void> updateWeatherUpdates(bool value) async {
    state = state.copyWith(weatherUpdates: value);
    await _savePreferences();
  }

  Future<void> updateShowConfetti(bool value) async {
    state = state.copyWith(showConfetti: value);
    await _savePreferences();
  }

  Future<void> updateShowProgress(bool value) async {
    state = state.copyWith(showProgress: value);
    await _savePreferences();
  }

  // Original setter methods
  Future<void> setUseSystemTheme(bool value) async {
    state = state.copyWith(useSystemTheme: value);
    await _savePreferences();
  }

  Future<void> setDarkMode(bool value) async {
    state = state.copyWith(darkMode: value);
    await _savePreferences();
  }

  Future<void> setUseAnimations(bool value) async {
    state = state.copyWith(useAnimations: value);
    await _savePreferences();
  }

  Future<void> setTripReminders(bool value) async {
    state = state.copyWith(tripReminders: value);
    await _savePreferences();
  }

  Future<void> setWeatherUpdates(bool value) async {
    state = state.copyWith(weatherUpdates: value);
    await _savePreferences();
  }

  Future<void> setShowConfetti(bool value) async {
    state = state.copyWith(showConfetti: value);
    await _savePreferences();
  }

  Future<void> setShowProgress(bool value) async {
    state = state.copyWith(showProgress: value);
    await _savePreferences();
  }

  Future<void> resetToDefaults() async {
    state = UserPreferences();
    await _savePreferences();
  }
} 
 
 
 