import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

final imageServiceProvider = Provider<ImageService>((ref) => ImageService());

class ImageService {
  final _cache = DefaultCacheManager();
  
  // Predefined fallback images for different place types
  final Map<String, String> _fallbackImages = {
    'restaurant': 'assets/images/fallbacks/restaurant.jpg',
    'cafe': 'assets/images/fallbacks/cafe.jpg',
    'bar': 'assets/images/fallbacks/bar.jpg',
    'museum': 'assets/images/fallbacks/museum.jpg',
    'park': 'assets/images/fallbacks/park.jpg',
    'hotel': 'assets/images/fallbacks/hotel.jpg',
    'default': 'assets/images/fallbacks/default.jpg',
  };

  Future<String> getImageUrl(String? photoReference, String placeType, {int maxWidth = 600, int maxHeight = 400}) async {
    if (photoReference == null || photoReference.isEmpty) {
      return _getFallbackImageUrl(placeType);
    }

    try {
      // Try to get from cache first
      final cacheKey = 'place_photo_$photoReference';
      final cachedFile = await _cache.getFileFromCache(cacheKey);
      
      if (cachedFile != null) {
        debugPrint('✅ Found cached image for reference: ${photoReference.substring(0, min(10, photoReference.length))}...');
        return cachedFile.file.path;
      }

      // If not in cache, fetch from Google Places API
      final url = Uri.https('maps.googleapis.com', '/maps/api/place/photo', {
        'maxwidth': maxWidth.toString(),
        'maxheight': maxHeight.toString(),
        'photo_reference': photoReference,
        'key': ApiConstants.placesApiKey,
      });

      debugPrint('📸 Fetching image from Places API: ${photoReference.substring(0, min(10, photoReference.length))}...');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        // Save to cache
        await _cache.putFile(
          cacheKey,
          response.bodyBytes,
          maxAge: const Duration(days: 7), // Cache for 7 days
        );
        
        final cachedFile = await _cache.getFileFromCache(cacheKey);
        return cachedFile!.file.path;
      } else {
        debugPrint('❌ Failed to fetch image: ${response.statusCode}');
        return _getFallbackImageUrl(placeType);
      }
    } catch (e) {
      debugPrint('❌ Error fetching image: $e');
      return _getFallbackImageUrl(placeType);
    }
  }

  String _getFallbackImageUrl(String placeType) {
    final fallbackImage = _fallbackImages[placeType.toLowerCase()] ?? _fallbackImages['default']!;
    debugPrint('🖼️ Using fallback image for type: $placeType');
    return fallbackImage;
  }

  Future<void> preloadFallbackImages(BuildContext context) async {
    for (final image in _fallbackImages.values) {
      precacheImage(AssetImage(image), context);
    }
  }

  Future<void> clearCache() async {
    await _cache.emptyCache();
    debugPrint('🧹 Image cache cleared');
  }
} 