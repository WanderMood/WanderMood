import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../domain/models/user_preferences.dart';

class PreferencesNotifier extends StateNotifier<UserPreferences> {
  final SharedPreferences prefs;
  
  PreferencesNotifier(this.prefs) : super(UserPreferences.defaults) {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefsJson = prefs.getString('user_preferences');
    
    if (prefsJson != null) {
      try {
        final prefsMap = jsonDecode(prefsJson) as Map<String, dynamic>;
        state = UserPreferences.fromJson(prefsMap);
      } catch (e) {
        print('Error loading preferences: $e');
        // Fallback to defaults on error
      }
    }
  }
  
  Future<void> _savePreferences() async {
    try {
      final prefsJson = jsonEncode(state.toJson());
      await prefs.setString('user_preferences', prefsJson);
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }
  
  // Update theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _savePreferences();
  }
  
  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final currentMode = state.themeMode;
    final newMode = currentMode == ThemeMode.dark 
      ? ThemeMode.light 
      : ThemeMode.dark;
    
    await setThemeMode(newMode);
  }
  
  // Update animation level
  Future<void> setAnimationLevel(AnimationLevel level) async {
    state = state.copyWith(animationLevel: level);
    await _savePreferences();
  }
  
  // Toggle live UI elements
  Future<void> toggleLiveUI() async {
    state = state.copyWith(useLiveUI: !state.useLiveUI);
    await _savePreferences();
  }
  
  // Toggle streaks visibility
  Future<void> toggleStreakVisibility() async {
    state = state.copyWith(showStreak: !state.showStreak);
    await _savePreferences();
  }
  
  // Toggle achievement visibility
  Future<void> toggleAchievementVisibility() async {
    state = state.copyWith(showAchievements: !state.showAchievements);
    await _savePreferences();
  }
  
  // Toggle notifications
  Future<void> toggleNotifications() async {
    state = state.copyWith(enableNotifications: !state.enableNotifications);
    await _savePreferences();
  }
  
  // Update a custom preference
  Future<void> setCustomPreference(String key, dynamic value) async {
    final updatedCustomizations = Map<String, dynamic>.from(state.customizations);
    updatedCustomizations[key] = value;
    
    state = state.copyWith(customizations: updatedCustomizations);
    await _savePreferences();
  }
}

// Provider for user preferences
final userPreferencesProvider = StateNotifierProvider<PreferencesNotifier, UserPreferences>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesNotifier(prefs);
});

// Re-use shared preferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
}); 
 
 
 