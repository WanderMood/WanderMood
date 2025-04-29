import 'dart:convert';
import 'package:flutter/material.dart';

/// Model representing user preferences for app customization
class UserPreferences {
  /// Whether the user prefers dark mode
  final bool darkMode;
  
  /// Whether to use system theme setting (if null/true) or user preference
  final bool useSystemTheme;
  
  /// Whether to use animations throughout the app
  final bool useAnimations;
  
  /// Whether to show confetti animations for achievements
  final bool showConfetti;
  
  /// Whether to show progress indicators
  final bool showProgress;
  
  /// Whether to show trip reminders
  final bool tripReminders;
  
  /// Whether to show weather updates
  final bool weatherUpdates;

  const UserPreferences({
    this.darkMode = false,
    this.useSystemTheme = true,
    this.useAnimations = true,
    this.showConfetti = true,
    this.showProgress = true,
    this.tripReminders = true,
    this.weatherUpdates = true,
  });

  /// Create a copy of this UserPreferences with the given fields replaced
  UserPreferences copyWith({
    bool? darkMode,
    bool? useSystemTheme,
    bool? useAnimations,
    bool? showConfetti,
    bool? showProgress,
    bool? tripReminders,
    bool? weatherUpdates,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      useAnimations: useAnimations ?? this.useAnimations,
      showConfetti: showConfetti ?? this.showConfetti,
      showProgress: showProgress ?? this.showProgress,
      tripReminders: tripReminders ?? this.tripReminders,
      weatherUpdates: weatherUpdates ?? this.weatherUpdates,
    );
  }
  
  /// Default preferences
  factory UserPreferences.defaults() {
    return const UserPreferences(
      darkMode: false,
      useSystemTheme: true,
      useAnimations: true,
      showConfetti: true,
      showProgress: true,
      tripReminders: true,
      weatherUpdates: true,
    );
  }
  
  /// Determines if dark mode should be active based on settings and context
  bool isDarkMode(BuildContext context) {
    if (useSystemTheme) {
      // Use system setting
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    // Use user preference
    return darkMode;
  }
  
  /// Helper to determine if animations should be shown
  bool shouldShowAnimations(String type) {
    if (!useAnimations) return false;
    
    switch (type) {
      case 'confetti':
        return showConfetti;
      case 'progress':
        return showProgress;
      default:
        return true;
    }
  }
  
  /// Convert to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'darkMode': darkMode,
      'useSystemTheme': useSystemTheme,
      'useAnimations': useAnimations,
      'showConfetti': showConfetti,
      'showProgress': showProgress,
      'tripReminders': tripReminders,
      'weatherUpdates': weatherUpdates,
    };
  }
  
  /// Create from a map from storage
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      darkMode: map['darkMode'] ?? false,
      useSystemTheme: map['useSystemTheme'] ?? true,
      useAnimations: map['useAnimations'] ?? true,
      showConfetti: map['showConfetti'] ?? true,
      showProgress: map['showProgress'] ?? true,
      tripReminders: map['tripReminders'] ?? true,
      weatherUpdates: map['weatherUpdates'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserPreferences.fromJson(String source) => 
      UserPreferences.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserPreferences(darkMode: $darkMode, useSystemTheme: $useSystemTheme, useAnimations: $useAnimations, showConfetti: $showConfetti, showProgress: $showProgress, tripReminders: $tripReminders, weatherUpdates: $weatherUpdates)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserPreferences &&
      other.darkMode == darkMode &&
      other.useSystemTheme == useSystemTheme &&
      other.useAnimations == useAnimations &&
      other.showConfetti == showConfetti &&
      other.showProgress == showProgress &&
      other.tripReminders == tripReminders &&
      other.weatherUpdates == weatherUpdates;
  }

  @override
  int get hashCode {
    return darkMode.hashCode ^
      useSystemTheme.hashCode ^
      useAnimations.hashCode ^
      showConfetti.hashCode ^
      showProgress.hashCode ^
      tripReminders.hashCode ^
      weatherUpdates.hashCode;
  }

  ThemeMode getThemeMode() {
    if (useSystemTheme) {
      return ThemeMode.system;
    }
    return darkMode ? ThemeMode.dark : ThemeMode.light;
  }
} 
 
 
 