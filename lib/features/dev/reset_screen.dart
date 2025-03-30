import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../splash/application/splash_service.dart';

class ResetScreen extends ConsumerWidget {
  const ResetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Tools'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await ref.read(splashServiceProvider).resetOnboardingFlag();
                if (context.mounted) {
                  context.go('/');
                }
              },
              child: const Text('Reset Onboarding'),
            ),
          ],
        ),
      ),
    );
  }
} 