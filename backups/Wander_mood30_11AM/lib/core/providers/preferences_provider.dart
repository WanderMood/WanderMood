import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

// State class for user preferences
class UserPreferences {
  final List<String> selectedMoods;
  final List<String> travelInterests;
  final String budgetLevel;
  final List<String> travelStyles;
  final bool hasCompletedOnboarding;

  const UserPreferences({
    this.selectedMoods = const [],
    this.travelInterests = const [],
    this.budgetLevel = 'Mid-Range',
    this.travelStyles = const [],
    this.hasCompletedOnboarding = false,
  });

  UserPreferences copyWith({
    List<String>? selectedMoods,
    List<String>? travelInterests,
    String? budgetLevel,
    List<String>? travelStyles,
    bool? hasCompletedOnboarding,
  }) {
    return UserPreferences(
      selectedMoods: selectedMoods ?? this.selectedMoods,
      travelInterests: travelInterests ?? this.travelInterests,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      travelStyles: travelStyles ?? this.travelStyles,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
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
}

// Provider for accessing user preferences
final preferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier();
}); 