import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wandermood/features/home/presentation/screens/home_screen.dart';
// import 'package:wandermood/features/home/presentation/screens/explore_screen.dart';  // TODO: Re-enable when new explore screen is implemented

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      // GoRoute(  // TODO: Re-enable when new explore screen is implemented
      //   path: '/explore',
      //   builder: (context, state) => const ExploreScreen(),
      // ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
} 