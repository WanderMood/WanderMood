import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required String userId,
    @Default([]) List<String> preferredCities,
    @Default([]) List<String> preferredActivities,
    @Default('') String preferredTimeOfDay,
    @Default('') String preferredWeather,
    @Default(false) bool isOnboardingComplete,
    @Default(false) bool isDarkMode,
    @Default('en') String language,
    @Default(true) bool notificationsEnabled,
    @Default([]) List<String> moods,
    @Default([]) List<String> interests,
    @Default([]) List<String> travelStyles,
    @Default('medium') String budget,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
} 