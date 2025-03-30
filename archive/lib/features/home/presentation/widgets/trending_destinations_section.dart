import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:wandermood/features/places/providers/trending_destinations_provider.dart';
import 'package:wandermood/features/home/presentation/screens/all_trending_destinations_screen.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:wandermood/features/places/providers/places_service_provider.dart';

class TrendingDestinationsSection extends ConsumerWidget {
  final List<PlacesSearchResult> destinations;

  const TrendingDestinationsSection({
    super.key,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '🔥 Trending',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              ).shimmer(
                duration: const Duration(seconds: 3),
                color: const Color(0xFF12B347).withOpacity(0.3),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // Navigate to all trending destinations screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AllTrendingDestinationsScreen(
                        destinations: destinations,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF12B347),
                  size: 18,
                ),
                label: Text(
                  'See All',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF12B347),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              ).scale(
                duration: const Duration(seconds: 2),
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(trendingDestinationsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: destinations.length + 1,
              itemBuilder: (context, index) {
                if (index == destinations.length) {
                  return _buildSpecialCard(
                    title: 'Hidden\nGems',
                    emoji: '💎',
                    color: Colors.purple,
                    subtitle: 'Discover unique places',
                  );
                }
                final destination = destinations[index];
                return _buildDestinationCard(destination, ref);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationCard(PlacesSearchResult destination, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    final currentCity = locationState.value ?? 'Rotterdam';
    
    // Generate realistic distance for Rotterdam (3-30 km)
    final int distance = 3 + (destination.placeId.hashCode.abs() % 27);
    // Generate realistic bookings count for trending indicator
    final int bookingsCount = 5 + (destination.placeId.hashCode.abs() % 38);
    
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: SizedBox(
        width: 160,
        child: Card(
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (destination.photos?.isNotEmpty ?? false)
                Image.network(
                  ref.read(placesServiceProviderProvider).getPhotoUrl(destination.photos!.first.photoReference),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                ),
              // Semi-transparent overlay for see-through effect
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              // Trending indicator
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12B347).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$bookingsCount booked today',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Contents
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Distance
                      Row(
                        children: [
                          const Spacer(),
                          Text(
                            '→ $distance km',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Name
                      Text(
                        destination.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white54,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$currentCity 🇳🇱',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialCard({
    required String title,
    required String emoji,
    required Color color,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: SizedBox(
        width: 140,
        child: Card(
          elevation: 8,
          shadowColor: color.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.8),
                  color.withOpacity(0.6),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  right: -20,
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 80,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate(
        onPlay: (controller) => controller.repeat(reverse: true),
      ).shimmer(
        duration: const Duration(seconds: 3),
        color: Colors.white.withOpacity(0.3),
      ),
    );
  }
} 