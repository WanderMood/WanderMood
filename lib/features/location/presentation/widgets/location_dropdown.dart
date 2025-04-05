import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';
import 'package:wandermood/features/location/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationDropdown extends ConsumerWidget {
  const LocationDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationNotifierProvider);

    return locationAsync.when(
      data: (location) => InkWell(
        onTap: () => ref.read(locationNotifierProvider.notifier).getCurrentLocation(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 4),
              Text(
                location ?? 'Current Location',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.refresh, size: 12),
            ],
          ),
        ),
      ),
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Getting location...'),
          ],
        ),
      ),
      error: (error, stack) => InkWell(
        onTap: () async {
          try {
            await Geolocator.openLocationSettings();
          } catch (_) {
            // Fallback if settings can't be opened
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enable location services in your device settings.'),
                ),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                'Enable Location',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 