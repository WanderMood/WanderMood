import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences.dart';
import 'package:wandermood/features/auth/domain/models/user_preferences.dart';

part 'onboarding_service.g.dart';

@riverpod
class OnboardingService extends _$OnboardingService {
  static const String _onboardingKey = 'onboarding_complete';

  @override
  Future<void> build() async {
    // Initialize the service
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    
    // Update user preferences
    final userPrefs = ref.read(userPreferencesServiceProvider).value;
    if (userPrefs != null) {
      await ref.read(userPreferencesServiceProvider.notifier).updatePreferences(
        userPrefs.copyWith(isOnboardingComplete: true),
      );
    }
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }
} 
 
 
import 'package:shared_preferences.dart';
import 'package:wandermood/features/auth/domain/models/user_preferences.dart';

part 'onboarding_service.g.dart';

@riverpod
class OnboardingService extends _$OnboardingService {
  static const String _onboardingKey = 'onboarding_complete';

  @override
  Future<void> build() async {
    // Initialize the service
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    
    // Update user preferences
    final userPrefs = ref.read(userPreferencesServiceProvider).value;
    if (userPrefs != null) {
      await ref.read(userPreferencesServiceProvider.notifier).updatePreferences(
        userPrefs.copyWith(isOnboardingComplete: true),
      );
    }
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }
} 
 
 