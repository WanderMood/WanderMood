import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wandermood/core/config/supabase_config.dart';
import 'package:wandermood/features/auth/presentation/screens/login_screen.dart';
import 'package:wandermood/features/auth/presentation/screens/register_screen.dart';
import 'package:wandermood/features/home/presentation/screens/home_screen.dart';
import 'package:wandermood/features/mood/presentation/pages/mood_page.dart';
import 'package:wandermood/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:wandermood/features/recommendations/presentation/pages/recommendations_page.dart';
import 'package:wandermood/features/splash/presentation/screens/splash_screen.dart';
import 'package:wandermood/features/weather/presentation/pages/weather_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash and Onboarding
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Authentication
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/mood',
        builder: (context, state) => const MoodPage(),
      ),
      GoRoute(
        path: '/weather',
        builder: (context, state) => const WeatherPage(),
      ),
      GoRoute(
        path: '/recommendations',
        builder: (context, state) => const RecommendationsPage(),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = SupabaseConfig.auth.currentUser != null;
      final isOnAuthPage = state.matchedLocation.startsWith('/login') || 
                          state.matchedLocation.startsWith('/register');
      final isOnSplashPage = state.matchedLocation == '/';
      final isOnOnboardingPage = state.matchedLocation == '/onboarding';
      
      // Always allow splash screen
      if (isOnSplashPage) return null;
      
      // Handle authentication flow
      if (!isAuthenticated) {
        // Allow onboarding and auth pages when not authenticated
        if (isOnOnboardingPage || isOnAuthPage) return null;
        // Redirect to onboarding if not on auth pages
        return '/onboarding';
      }
      
      // Redirect to home if authenticated and trying to access auth pages
      if (isAuthenticated && (isOnAuthPage || isOnOnboardingPage)) {
        return '/home';
      }
      
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Error: ${state.error}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
}); 