import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/services/image_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class PlaceImage extends ConsumerWidget {
  final String? photoReference;
  final String placeType;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final bool isAsset;

  const PlaceImage({
    this.photoReference,
    required this.placeType,
    this.width = double.infinity,
    this.height = 200,
    this.borderRadius = BorderRadius.zero,
    this.fit = BoxFit.cover,
    this.isAsset = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isAsset && photoReference != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(
          photoReference!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        ),
      );
    }

    return FutureBuilder<String>(
      future: ref.read(imageServiceProvider).getImageUrl(
        photoReference,
        placeType,
        maxWidth: width.toInt(),
        maxHeight: height.toInt(),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          debugPrint('❌ Error loading image: ${snapshot.error}');
          return _buildErrorWidget();
        }

        final imageUrl = snapshot.data!;
        if (imageUrl.startsWith('assets/')) {
          return ClipRRect(
            borderRadius: borderRadius,
            child: Image.asset(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
            ),
          );
        }

        return ClipRRect(
          borderRadius: borderRadius,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: fit,
            placeholder: (context, url) => _buildLoadingWidget(),
            errorWidget: (context, url, error) {
              debugPrint('❌ Error loading image: $error');
              return _buildErrorWidget();
            },
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 300),
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.grey[400],
        ),
      ),
    ).animate().shimmer(duration: 1500.ms);
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.grey[400],
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Image not available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 