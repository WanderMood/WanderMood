import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/adventure/presentation/screens/adventure_plan_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/adventure-plan',
        builder: (context, state) => const AdventurePlanScreen(),
      ),
    ],
    redirect: (context, state) async {
      final currentUser = Supabase.instance.client.auth.currentUser;
      final isAuthenticated = currentUser != null;
      final isOnSplashScreen = state.matchedLocation == '/';
      final isOnOnboardingScreen = state.matchedLocation == '/onboarding';
      final isOnLoginScreen = state.matchedLocation == '/login';

      if (isOnSplashScreen) {
        return null; // Sta toegang tot splash screen toe
      }

      // Bescherm authenticatie-vereiste routes
      if (!isAuthenticated && !isOnLoginScreen && !isOnOnboardingScreen) {
        return '/login';
      }

      // Voorkom dat ingelogde gebruikers naar login/onboarding gaan
      if (isAuthenticated && (isOnLoginScreen || isOnOnboardingScreen)) {
        return '/home';
      }

      return null;
    },
  );
} 