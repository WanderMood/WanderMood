import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wandermood/features/auth/presentation/screens/login_screen.dart';
import 'package:wandermood/features/home/presentation/screens/home_screen.dart';
import 'package:wandermood/features/onboarding/presentation/screens/onboarding_screen.dart';

// Provider voor de splash service
final splashServiceProvider = Provider<SplashService>((ref) {
  return SplashService();
});

class SplashService {
  // Constante key voor shared preferences
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  Future<void> handleSplashNavigation(BuildContext context) async {
    try {
      // Wacht 2 seconden voor een betere splash ervaring
      await Future.delayed(const Duration(seconds: 2));
      
      if (!context.mounted) return;
      
      // Controleer of de gebruiker al is ingelogd
      final currentUser = Supabase.instance.client.auth.currentUser;
      
      // Controleer of de gebruiker al onboarding heeft gezien
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(_hasSeenOnboardingKey) ?? false;
      
      if (!context.mounted) return;
      
      if (currentUser != null) {
        // Als de gebruiker is ingelogd, navigeer direct naar het home scherm
        context.go('/home');
      } else if (hasSeenOnboarding) {
        // Als de gebruiker al onboarding heeft gezien, ga dan direct naar het login scherm
        context.go('/login');
      } else {
        // Als dit de eerste keer is, navigeer naar het onboarding scherm
        context.go('/onboarding');
      }
    } catch (e) {
      debugPrint('Error tijdens splash navigatie: $e');
      // Bij een error, navigeer naar het login scherm
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
  
  // Methode om bij te houden dat gebruiker onboarding heeft gezien
  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }
} 