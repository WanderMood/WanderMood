import 'package:flutter_google_maps_webservices/places.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../services/places_service.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';

part 'explore_places_provider.g.dart';

@riverpod
class ExplorePlaces extends _$ExplorePlaces {
  @override
  Future<List<Place>> build({String? city}) async {
    // Get the current location from the location provider
    final locationState = ref.watch(locationNotifierProvider);
    
    // Use the city parameter if provided, otherwise use the location state
    final cityName = city ?? locationState.value ?? 'Rotterdam';
    
    debugPrint('🔄 ExplorePlaces rebuilding for city: $cityName');
    
    ref.onDispose(() {
      debugPrint('🗑️ Disposing explore places provider for $cityName');
    });

    final service = ref.read(placesServiceProvider.notifier);
    List<Place> allResults = [];

    // Try different query types to ensure we get results for any city
    final queryTypes = [
      'popular places in $cityName',
      'top attractions in $cityName',
      'places to visit in $cityName',
      'must see in $cityName',
      'things to do in $cityName',
      'tourist attractions in $cityName',
      'hidden gems in $cityName',
      'local experiences in $cityName',
    ];
    
    // Keep track of place IDs to avoid duplicates
    final addedPlaceIds = <String>{};

    // Try each query type to get comprehensive results
    for (final query in queryTypes) {
      try {
        debugPrint('🔍 Searching for: $query');
        final results = await service.searchPlaces(query);
        
        if (results.isNotEmpty) {
          debugPrint('✅ Found ${results.length} results for "$query"');
          
          // Process all results - no limit here
          for (final result in results) {
            // Skip if we already have this place
            if (result['placeId'] == null || addedPlaceIds.contains(result['placeId'])) {
              continue;
            }
            
            // Only add places that are actually in the requested city
            final isInRequestedCity = _isPlaceInCity(result, cityName);
            if (!isInRequestedCity) {
              debugPrint('⚠️ Skipping ${result['name']} as it appears to be outside $cityName');
              continue;
            }
            
            // Create Place object
            final place = Place(
              id: result['placeId']!,
              name: result['name'] ?? 'Unknown Place',
              address: result['address'] ?? '',
              rating: (result['rating'] ?? 0).toDouble(),
              photos: (result['photos'] as List<dynamic>?)?.cast<String>() ?? [],
              types: (result['types'] as List<dynamic>?)?.cast<String>() ?? [],
              location: PlaceLocation(
                lat: (result['location']?['lat'] as num?)?.toDouble() ?? 0.0,
                lng: (result['location']?['lng'] as num?)?.toDouble() ?? 0.0,
              ),
            );
            
            // Add to results and track ID
            allResults.add(place);
            addedPlaceIds.add(result['placeId']!);
            debugPrint('✅ Added explore place: ${place.name}');
          }
        }
      } catch (e) {
        debugPrint('❌ Error fetching "$query": $e');
      }
    }
    
    // Also add category-based queries to get more specific results
    final categoryQueries = [
      'restaurants in $cityName',
      'museums in $cityName',
      'parks in $cityName',
      'shopping in $cityName',
      'cafes in $cityName',
      'bars in $cityName',
      'historic sites in $cityName',
      'entertainment in $cityName',
      'family activities in $cityName',
      'outdoor activities in $cityName',
    ];
    
    for (final query in categoryQueries) {
      try {
        debugPrint('🔍 Searching for: $query');
        final results = await service.searchPlaces(query);
        
        if (results.isNotEmpty) {
          debugPrint('✅ Found ${results.length} results for "$query"');
          
          // Process all results
          for (final result in results) {
            // Skip if we already have this place
            if (result['placeId'] == null || addedPlaceIds.contains(result['placeId'])) {
              continue;
            }
            
            // Only add places that are actually in the requested city
            final isInRequestedCity = _isPlaceInCity(result, cityName);
            if (!isInRequestedCity) {
              continue;
            }
            
            // Create Place object
            final place = Place(
              id: result['placeId']!,
              name: result['name'] ?? 'Unknown Place',
              address: result['address'] ?? '',
              rating: (result['rating'] ?? 0).toDouble(),
              photos: (result['photos'] as List<dynamic>?)?.cast<String>() ?? [],
              types: (result['types'] as List<dynamic>?)?.cast<String>() ?? [],
              location: PlaceLocation(
                lat: (result['location']?['lat'] as num?)?.toDouble() ?? 0.0,
                lng: (result['location']?['lng'] as num?)?.toDouble() ?? 0.0,
              ),
            );
            
            // Add to results and track ID
            allResults.add(place);
            addedPlaceIds.add(result['placeId']!);
          }
        }
      } catch (e) {
        debugPrint('❌ Error fetching "$query": $e');
      }
    }

    debugPrint('✅ Total places found for $cityName: ${allResults.length}');
    return allResults;
  }
  
  // Helper method to check if a place is in the requested city
  bool _isPlaceInCity(dynamic place, String cityName) {
    if (place is Map<String, dynamic>) {
      // Check the address field
      if (place['address'] != null && 
          place['address'].toString().toLowerCase().contains(cityName.toLowerCase())) {
        return true;
      }
      
      // For places with no address information, we'll trust the API's search results
      return true;
    } else {
      // Original implementation for PlacesSearchResult type
      // Check the vicinity field
      if (place.vicinity != null && 
          place.vicinity.toLowerCase().contains(cityName.toLowerCase())) {
        return true;
      }
      
      // Check the formatted address
      if (place.formattedAddress != null && 
          place.formattedAddress.toLowerCase().contains(cityName.toLowerCase())) {
        return true;
      }
      
      // For places with no address information, we'll trust the API's search results
      return true;
    }
  }

  String getPhotoUrl(String photoReference) {
    final service = ref.read(placesServiceProvider.notifier);
    return service.getPlacePhotoUrl(photoReference);
  }
} 