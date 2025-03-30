import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider voor de splash service
final splashServiceProvider = Provider<SplashService>((ref) {
  return SplashService();
});

class SplashService {
  // Constante key voor shared preferences
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';  // Same key as in router

  Future<void> handleSplashNavigation(BuildContext context) async {
    try {
      // Wait for a better splash experience
      await Future.delayed(const Duration(seconds: 2));
      
      if (!context.mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(_hasSeenOnboardingKey) ?? false;
      
      if (!context.mounted) return;
      
      if (!hasSeenOnboarding) {
        context.go('/onboarding');  // Go directly to onboarding for new users
      } else {
        context.go('/login');
      }
    } catch (e) {
      debugPrint('Error during splash navigation: $e');
      if (context.mounted) {
        context.go('/onboarding');  // Default to onboarding screen on error
      }
    }
  }
  
  // Methode om bij te houden dat gebruiker onboarding heeft gezien
  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }

  // Helper method to reset onboarding flag (FOR TESTING ONLY)
  Future<void> resetOnboardingFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSeenOnboardingKey);
  }
} 