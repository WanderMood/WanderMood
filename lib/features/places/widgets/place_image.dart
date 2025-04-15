import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wandermood/features/places/services/places_service.dart';

class PlaceImage extends ConsumerWidget {
  final String? photoReference;
  final String placeType;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final bool isAsset;

  const PlaceImage({
    super.key,
    this.photoReference,
    required this.placeType,
    this.height,
    this.width,
    this.fit,
    this.borderRadius,
    this.isAsset = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If no photo reference, use fallback image
    if (photoReference == null || photoReference!.startsWith('assets/')) {
      return Image.asset(
        photoReference ?? 'assets/images/fallbacks/${placeType.toLowerCase()}.jpg',
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error loading asset image: $error');
          return Image.asset(
            'assets/images/fallbacks/default.jpg',
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
          );
        },
      );
    }

    // For Google Places photos
    final photoUrl = ref.read(placesServiceProvider.notifier).getPlacePhotoUrl(photoReference!);
    
    return CachedNetworkImage(
      imageUrl: photoUrl,
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) {
        debugPrint('❌ Error loading network image: $error');
        return Image.asset(
          'assets/images/fallbacks/${placeType.toLowerCase()}.jpg',
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/fallbacks/default.jpg',
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF12B347)),
        ),
      ),
    );
  }

  Widget _buildFallbackContainer() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        image: DecorationImage(
          image: AssetImage('assets/images/fallbacks/${placeType.toLowerCase()}.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.1),
            BlendMode.darken,
          ),
        ),
      ),
    );
  }
} 