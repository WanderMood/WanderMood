import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../domain/models/user_preferences.dart';

/// Provider to access the current user preferences
final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier();
});

/// Notifier that manages the user preferences state
class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  static const String _prefsKey = 'user_preferences';
  
  UserPreferencesNotifier() : super(UserPreferences.defaults()) {
    _loadPreferences();
  }

  /// Load preferences from persistent storage
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString(_prefsKey);
      
      if (prefsJson != null) {
        final Map<String, dynamic> prefsMap = jsonDecode(prefsJson);
        state = UserPreferences.fromJson(prefsMap);
      }
    } catch (e) {
      // If loading fails, keep default preferences
      print('Failed to load preferences: $e');
    }
  }

  /// Save preferences to persistent storage
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = jsonEncode(state.toJson());
      await prefs.setString(_prefsKey, prefsJson);
    } catch (e) {
      print('Failed to save preferences: $e');
    }
  }

  /// Toggle dark mode
  void toggleDarkMode() {
    final newState = state.copyWith(
      darkMode: !(state.darkMode ?? false),
      useSystemTheme: false,
    );
    state = newState;
    _savePreferences();
  }

  /// Set specific dark mode value
  void setDarkMode(bool isDark) {
    final newState = state.copyWith(
      darkMode: isDark,
      useSystemTheme: false,
    );
    state = newState;
    _savePreferences();
  }

  /// Toggle using system theme
  void toggleUseSystemTheme() {
    final newState = state.copyWith(
      useSystemTheme: !state.useSystemTheme,
    );
    state = newState;
    _savePreferences();
  }

  /// Set system theme usage
  void setUseSystemTheme(bool useSystem) {
    final newState = state.copyWith(
      useSystemTheme: useSystem,
    );
    state = newState;
    _savePreferences();
  }

  /// Toggle animations
  void toggleAnimations() {
    final newState = state.copyWith(
      showAnimations: !state.showAnimations,
    );
    state = newState;
    _savePreferences();
  }

  /// Update a specific animation setting
  void setAnimationSetting(String type, bool value) {
    UserPreferences newState;
    
    switch (type) {
      case 'all':
        newState = state.copyWith(showAnimations: value);
        break;
      case 'confetti':
        newState = state.copyWith(showConfetti: value);
        break;
      case 'progress':
        newState = state.copyWith(showProgress: value);
        break;
      default:
        return;
    }
    
    state = newState;
    _savePreferences();
  }

  /// Reset all preferences to defaults
  void resetToDefaults() {
    state = UserPreferences.defaults();
    _savePreferences();
  }
} 
 
 
 