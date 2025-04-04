import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';
import 'package:wandermood/features/location/services/location_service.dart';

class LocationDropdown extends ConsumerWidget {
  const LocationDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationNotifierProvider);

    return locationAsync.when(
      data: (location) => DropdownButton<String>(
        value: location,
        hint: const Text('Select location'),
        onChanged: (newLocation) {
          if (newLocation != null) {
            ref.read(locationNotifierProvider.notifier).setLocation(newLocation);
          }
        },
        items: [
          if (location != null)
            DropdownMenuItem(
              value: location,
              child: Text(location),
            ),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () => ref.refresh(locationNotifierProvider),
      ),
    );
  }
} 