import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlaceCard extends ConsumerWidget {
  final Place place;
  final VoidCallback onTap;
  final bool isFavorite;
  final Function(bool)? onFavoriteToggle;

  const PlaceCard({
    Key? key,
    required this.place,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  }) : super(key: key);

  String _getPriceLevel(int? priceLevel) {
    if (priceLevel == null) return '';
    switch (priceLevel) {
      case 1:
        return '\$';
      case 2:
        return '\$\$';
      case 3:
        return '\$\$\$';
      case 4:
        return '\$\$\$\$';
      default:
        return '';
    }
  }

  String _getPriceLevelText(int? priceLevel) {
    if (priceLevel == null) return '';
    switch (priceLevel) {
      case 1:
        return 'Inexpensive';
      case 2:
        return 'Moderate';
      case 3:
        return 'Expensive';
      case 4:
        return 'Very Expensive';
      default:
        return '';
    }
  }

  String _extractCityName(String address) {
    // Split by comma and get the last meaningful part
    final parts = address.split(',');
    // Try to get city name, fallback to full address if can't extract
    return parts.length > 1 ? parts[parts.length - 2].trim() : address.trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
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
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  // Main image
                  place.photos.isNotEmpty
                    ? Image.network(
                        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photo_reference=${place.photos.first}&key=${dotenv.env['GOOGLE_PLACES_API_KEY']}',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]),
                          );
                        },
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
                      ),
                  // Opening hours banner
                  if (place.isOpen != null)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12B347),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.isOpen 
                                ? 'Open Now${place.closingTime != null ? ' • Closes at ${place.closingTime}' : ''}'
                                : 'Closed',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Share and favorite buttons
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.share, size: 18),
                            onPressed: () => Share.share('Check out ${place.name}!'),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isFavorite ? Colors.red : Colors.black54,
                            ),
                            onPressed: () {
                              if (onFavoriteToggle != null) {
                                onFavoriteToggle!(!isFavorite);
                              }
                            },
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (place.rating != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              place.rating!.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (place.priceLevel != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12B347).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getPriceLevel(place.priceLevel),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF12B347),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getPriceLevelText(place.priceLevel),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    place.description ?? 'No description available',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Location and distance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _extractCityName(place.address),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '🇳🇱',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF12B347),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${place.distance.round()} km',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF12B347),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Activities
                  if (place.activities.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: place.activities.map((activity) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF12B347),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                activity,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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