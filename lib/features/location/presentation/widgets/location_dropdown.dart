import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/core/domain/providers/location_notifier_provider.dart';
import 'package:wandermood/core/domain/providers/recent_cities_provider.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:wandermood/core/config/api_keys.dart';
import 'package:flutter/rendering.dart';

class LocationDropdown extends ConsumerWidget {
  const LocationDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationNotifierProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (_, controller) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Select Location',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search cities...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    // Current location button
                    ListTile(
                      leading: const Icon(Icons.my_location),
                      title: const Text('Use current location'),
                      onTap: () {
                        ref.read(locationNotifierProvider.notifier).getCurrentLocation();
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(),
                    // Popular cities
                    Expanded(
                      child: ListView(
                        controller: controller,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Popular Cities',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: const Text('🇳🇱'),
                            title: const Text('Amsterdam'),
                            onTap: () {
                              ref.read(locationNotifierProvider.notifier).setCity('Amsterdam');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Text('🇳🇱'),
                            title: const Text('Rotterdam'),
                            onTap: () {
                              ref.read(locationNotifierProvider.notifier).setCity('Rotterdam');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Text('🇳🇱'),
                            title: const Text('The Hague'),
                            onTap: () {
                              ref.read(locationNotifierProvider.notifier).setCity('The Hague');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                color: const Color(0xFF12B347),
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                locationState.city ?? 'Select Location',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF12B347),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: const Color(0xFF12B347),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 