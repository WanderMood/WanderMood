import 'package:flutter/material.dart';
import 'package:wandermood/core/theme/app_theme.dart';
import 'package:wandermood/features/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WanderMood',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return Container(
          decoration: AppTheme.backgroundGradient,
          child: child!,
        );
      },
    );
  }
} 