import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            color: Colors.black87,
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
              'Location error',
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
            color: Colors.black87,
            size: 20,
          ),
        ],
      ),
    );
  }
} 