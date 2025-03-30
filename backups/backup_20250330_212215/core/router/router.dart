import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/adventure/presentation/screens/adventure_plan_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/places/presentation/screens/place_detail_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/onboarding/presentation/screens/location_permission_screen.dart';
import '../../features/onboarding/presentation/screens/mood_preference_screen.dart';
import '../../features/onboarding/presentation/screens/travel_interests_screen.dart';
import '../../features/onboarding/presentation/screens/budget_preference_screen.dart';
import '../../features/onboarding/presentation/screens/travel_style_screen.dart';
import '../../features/onboarding/presentation/screens/preferences_summary_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_loading_screen.dart';
import '../../features/dev/reset_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
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
        path: '/auth/signup',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/adventure-plan',
        builder: (context, state) => const AdventurePlanScreen(),
      ),
      GoRoute(
        path: '/place/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PlaceDetailScreen(placeId: id);
        },
      ),
      GoRoute(
        path: '/preferences/location',
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: '/preferences/mood',
        builder: (context, state) => const MoodPreferenceScreen(),
      ),
      GoRoute(
        path: '/preferences/interests',
        builder: (context, state) => const TravelInterestsScreen(),
      ),
      GoRoute(
        path: '/preferences/budget',
        builder: (context, state) => const BudgetPreferenceScreen(),
      ),
      GoRoute(
        path: '/preferences/style',
        builder: (context, state) => const TravelStyleScreen(),
      ),
      GoRoute(
        path: '/preferences/loading',
        builder: (context, state) => const OnboardingLoadingScreen(),
      ),
      GoRoute(
        path: '/preferences/summary',
        builder: (context, state) => const PreferencesSummaryScreen(),
      ),
      GoRoute(
        path: '/dev/reset',
        builder: (context, state) => const ResetScreen(),
      ),
    ],
    redirect: (context, state) async {
      final isOnSplashScreen = state.matchedLocation == '/';
      final isOnWelcomeScreen = state.matchedLocation == '/welcome';
      final isOnLoginScreen = state.matchedLocation == '/login';
      final isOnOnboardingScreen = state.matchedLocation == '/onboarding';
      final isInPreferences = state.matchedLocation.startsWith('/preferences/');
      final isDevReset = state.matchedLocation == '/dev/reset';

      // Allow access to dev reset screen
      if (isDevReset) {
        return null;
      }

      // Allow access to splash screen
      if (isOnSplashScreen) {
        return null;
      }

      // Check onboarding status first
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      // If onboarding not completed, force onboarding flow
      if (!hasSeenOnboarding) {
        // Allow onboarding-related screens
        if (isOnWelcomeScreen || isOnOnboardingScreen || isInPreferences) {
          return null;
        }
        // Redirect to welcome screen for any other route
        return '/welcome';
      }

      // Only check authentication after onboarding is complete
      if (hasSeenOnboarding) {
        final currentUser = Supabase.instance.client.auth.currentUser;
        final isAuthenticated = currentUser != null;

        if (!isAuthenticated && !isOnLoginScreen) {
          return '/login';
        }

        if (isAuthenticated && isOnLoginScreen) {
          return '/home';
        }
      }

      return null;
    },
  );
} 