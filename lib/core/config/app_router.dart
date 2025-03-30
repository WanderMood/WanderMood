import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/onboarding/presentation/screens/mood_selection_screen.dart';
import '../../features/onboarding/presentation/screens/travel_interests_screen.dart';
import '../../features/onboarding/presentation/screens/location_selection_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/trips/presentation/screens/trips_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final supabase = Supabase.instance.client;

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuth = supabase.auth.currentUser != null;
      final isAuthRoute = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/signup';

      // If not authenticated and not on auth route, redirect to login
      if (!isAuth && !isAuthRoute) {
        return '/login';
      }

      // If authenticated and on auth route, redirect to home
      if (isAuth && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Onboarding Routes
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/preferences/mood',
        builder: (context, state) => const MoodSelectionScreen(),
      ),
      GoRoute(
        path: '/preferences/interests',
        builder: (context, state) => const TravelInterestsScreen(),
      ),
      GoRoute(
        path: '/preferences/location',
        builder: (context, state) => const LocationSelectionScreen(),
      ),

      // Main App Routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/trips',
        builder: (context, state) => const TripsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Initial Route
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final isAuth = supabase.auth.currentUser != null;
          return isAuth ? '/home' : '/welcome';
        },
      ),
    ],
  );
}); 