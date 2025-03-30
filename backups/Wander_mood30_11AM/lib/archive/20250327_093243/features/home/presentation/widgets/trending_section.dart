import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/places/providers/trending_destinations_provider.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TrendingSection extends ConsumerWidget {
  final String? city;
  final String? category;

  const TrendingSection({
    Key? key,
    this.city,
    this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingDestinations = ref.watch(trendingDestinationsProvider(city: city, category: category));

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Trending',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Handle see all
                },
                child: Text(
                  'See All',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF12B347),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Trending Places Carousel
        SizedBox(
          height: 260,
          child: trendingDestinations.when(
            data: (places) => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TrendingPlaceCard(
                    place: place,
                    onTap: () {
                      // Handle place tap
                    },
                  ),
                );
              },
            ),
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: ShimmerTrendingCard(),
                );
              },
            ),
            error: (error, stackTrace) => Center(
              child: Text(
                'Error loading trending places',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TrendingPlaceCard extends StatelessWidget {
  final PlacesSearchResult place;
  final VoidCallback onTap;

  const TrendingPlaceCard({
    Key? key,
    required this.place,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: place.photos.isNotEmpty
                ? Image.network(
                    'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${place.photos.first.photoReference}&key=${dotenv.env['GOOGLE_PLACES_API_KEY']}',
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 260,
                        width: double.infinity,
                        color: Colors.grey[800],
                        child: const Icon(Icons.image_not_supported, size: 40, color: Colors.white),
                      );
                    },
                  )
                : Container(
                    height: 260,
                    width: double.infinity,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image, size: 40, color: Colors.white),
                  ),
            ),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.4, 0.9],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12B347),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${24 + place.hashCode % 8} booked today',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Distance Badge
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '15 km',
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
                      const SizedBox(height: 8),
                      
                      // Place Name
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.apartment,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              place.vicinity ?? '',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Image.asset(
                            'assets/images/netherlands-flag.png',
                            width: 16,
                            height: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerTrendingCard extends StatelessWidget {
  const ShimmerTrendingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 140,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 