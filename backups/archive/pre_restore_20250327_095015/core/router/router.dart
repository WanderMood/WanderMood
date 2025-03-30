import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/adventure/presentation/screens/adventure_plan_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/places/presentation/screens/place_detail_screen.dart';
// import '../../features/home/presentation/screens/explore_screen.dart';  // TODO: Re-enable when new explore screen is implemented
import '../../features/home/presentation/screens/plan_generation_screen.dart';
import '../../features/places/providers/place_detail_provider.dart';

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
      // GoRoute(  // TODO: Re-enable when new explore screen is implemented
      //   path: '/explore',
      //   builder: (context, state) => const ExploreScreen(),
      // ),
      GoRoute(
        path: '/plan-generation',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PlanGenerationScreen(
            selectedMood: extra['selectedMood'] as String,
            location: extra['location'] as String,
          );
        },
      ),
      GoRoute(
        path: '/adventure-plan',
        builder: (context, state) => const AdventurePlanScreen(),
      ),
      GoRoute(
        path: '/place/:id',
        name: 'place_detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final place = ref.read(placeDetailProvider(id));
          return place.when(
            data: (place) => PlaceDetailScreen(place: place),
            loading: () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stackTrace) => Scaffold(
              body: Center(
                child: Text('Error loading place: $error'),
              ),
            ),
          );
        },
      ),
    ],
  );
} 