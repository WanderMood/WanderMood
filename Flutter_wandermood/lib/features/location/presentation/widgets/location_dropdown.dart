import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';
import 'package:wandermood/features/location/services/location_service.dart';

class LocationDropdown extends ConsumerWidget {
  const LocationDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () async {
          if (locationState.hasError) {
            final error = locationState.error.toString();
            if (error.contains('permanently denied')) {
              // Show dialog to open app settings
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Location Permission Required'),
                  content: const Text('Please enable location permission in app settings to use this feature.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        LocationService.openAppSettings();
                      },
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
              );
            } else if (error.contains('services are disabled')) {
              // Show dialog to open location settings
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Location Services Disabled'),
                  content: const Text('Please enable location services in your device settings to use this feature.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        LocationService.openLocationSettings();
                      },
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
              );
            }
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              color: locationState.hasError ? Colors.red : Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 8),
            locationState.when(
              data: (location) => Text(
                location ?? 'Location not available',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              loading: () => SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                ),
              ),
              error: (error, _) => Text(
                'Enable Location',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              color: locationState.hasError ? Colors.red : Colors.black87,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
} 