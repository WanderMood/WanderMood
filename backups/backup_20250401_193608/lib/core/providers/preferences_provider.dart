import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferences_provider.freezed.dart';

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default([]) List<String> selectedMoods,
    @Default([]) List<String> travelInterests,
    @Default([]) List<String> travelStyles,
    @Default('Mid-Range') String budgetLevel,
    @Default(false) bool hasCompletedOnboarding,
  }) = _UserPreferences;
}

// Notifier class for managing user preferences state
class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier() : super(const UserPreferences());

  void updateSelectedMoods(List<String> moods) {
    debugPrint('Updating moods to: $moods');
    state = state.copyWith(selectedMoods: moods);
    debugPrint('Updated state moods: ${state.selectedMoods}');
  }

  void updateTravelInterests(List<String> interests) {
    debugPrint('Updating interests to: $interests');
    state = state.copyWith(travelInterests: interests);
  }

  void updateBudgetLevel(String level) {
    debugPrint('Updating budget level to: $level');
    state = state.copyWith(budgetLevel: level);
  }

  void updateTravelStyles(List<String> styles) {
    debugPrint('Updating travel styles to: $styles');
    state = state.copyWith(travelStyles: styles);
  }

  void completeOnboarding() {
    state = state.copyWith(hasCompletedOnboarding: true);
  }

  void reset() {
    state = const UserPreferences();
  }
}

// Provider for accessing user preferences
final preferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier();
}); 