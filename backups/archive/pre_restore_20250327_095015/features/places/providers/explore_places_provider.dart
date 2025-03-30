import 'package:flutter_google_maps_webservices/places.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../services/places_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wandermood/features/location/services/location_service.dart';

part 'explore_places_provider.g.dart';

@riverpod
class ExplorePlaces extends _$ExplorePlaces {
  final PlacesService _placesService = PlacesService();

  // Improved search queries based on API logs
  final Map<String, List<String>> _cityPlaces = {
    'Rotterdam': [
      "Markthal Tours Rotterdam",
      "Kunsthal Rotterdam",
      "Euromast Rotterdam", 
      "Erasmusbrug Rotterdam",
      "ss Rotterdam",
      "Kijk-Kubus Rotterdam",
      "Museum Boijmans Van Beuningen",
      "Maritime Museum Rotterdam",
      "The Rotterdam",
      "Voorhaven Delfshaven",
      "Arboretum Trompenburg",
      "Witte Huis Rotterdam",
      "Hotel New York",
      "Pilgrim Fathers Church",
      "Miniworld Rotterdam",
      "Dutch Pinball Museum",
      "Dakpark Rotterdam",
      "CityHub Rotterdam",
    ],
    'Amsterdam': [
      "Rijksmuseum Amsterdam",
      "Van Gogh Museum",
      "Anne Frank House",
      "Amsterdam Canal Cruise",
      "Vondelpark",
      "NEMO Science Museum",
      "Royal Palace Amsterdam",
      "Dam Square",
      "Jordaan District",
    ],
    'Utrecht': [
      "Dom Tower Utrecht",
      "Centraal Museum",
      "Utrecht Canals",
      "Railway Museum",
      "Botanical Gardens Utrecht",
      "Oudegracht",
      "Kasteel de Haar",
      "TivoliVredenburg",
      "Museum Speelklok",
    ],
    'The Hague': [
      "Mauritshuis",
      "Peace Palace",
      "Binnenhof",
      "Scheveningen Beach",
      "Madurodam",
      "Panorama Mesdag",
      "Gemeentemuseum Den Haag",
      "Louwman Museum",
      "Escher in The Palace",
    ],
  };
  
  // Custom descriptions for places when API doesn't provide good ones
  final Map<String, String> _placeDescriptions = {
    "Markthal Tours Rotterdam": "Iconic food market with colorful ceiling art and diverse culinary options",
    "Kunsthal Rotterdam": "Contemporary art museum showcasing rotating exhibitions in a modern building",
    "Euromast Rotterdam": "Iconic observation tower offering panoramic views of Rotterdam from 185m high",
    "Erasmusbrug Rotterdam": "Stunning swan-shaped bridge connecting north and south Rotterdam",
    "ss Rotterdam": "Historic cruise ship turned hotel, restaurant and attraction",
    "Kijk-Kubus Rotterdam": "Innovative cube houses designed by Piet Blom representing an urban forest",
    "Museum Boijmans Van Beuningen": "Major art museum with works from the Middle Ages to the present day",
    "Maritime Museum Rotterdam": "Museum showcasing Rotterdam's rich maritime history and port legacy",
    "The Rotterdam": "Iconic vertical city designed by architect Rem Koolhaas",
    "Voorhaven Delfshaven": "Historic harbor district with preserved 17th-century buildings",
    "Arboretum Trompenburg": "Beautiful botanical garden with rare trees and plants",
    "Witte Huis Rotterdam": "Europe's first skyscraper (1898) in stunning Art Nouveau style",
    "Hotel New York": "Former headquarters of the Holland America Line, now a hotel and restaurant",
    "Pilgrim Fathers Church": "Historic church where pilgrims worshipped before sailing to America",
    "Miniworld Rotterdam": "Detailed miniature version of Rotterdam and surroundings",
    "Dutch Pinball Museum": "Interactive museum with playable vintage and modern pinball machines",
    "Dakpark Rotterdam": "Europe's largest rooftop park built on top of a shopping center",
    "CityHub Rotterdam": "Modern pod-style accommodation in the heart of Rotterdam",
  };
  
  // Map categories to place types for filtering
  final Map<String, List<String>> _categoryToPlaceTypes = {
    'Architecture': ['landmark', 'tourist_attraction', 'point_of_interest'],
    'Culture': ['museum', 'art_gallery', 'library', 'tourist_attraction'],
    'Food': ['restaurant', 'cafe', 'bakery', 'food', 'meal_takeaway'],
    'Nature': ['park', 'natural_feature', 'zoo', 'campground'],
    'History': ['museum', 'cemetery', 'church', 'mosque', 'synagogue', 'hindu_temple', 'place_of_worship'],
    'Art': ['art_gallery', 'museum'],
    'Family': ['amusement_park', 'aquarium', 'zoo', 'park'],
    'Photography': ['tourist_attraction', 'natural_feature', 'point_of_interest', 'landmark'],
    'Sports': ['stadium', 'gym', 'park', 'sports_complex'],
    'Accommodation': ['lodging', 'hotel', 'apartment_rental'],
  };

  @override
  Future<List<PlacesSearchResult>> build({String? city, String? category}) async {
    try {
      // Get current location
      final Position currentPosition = await LocationService.getCurrentPosition();
      
      // Get places based on city and category
      final places = await _fetchPlacesForCity(city ?? 'Rotterdam', category, currentPosition);
      return places;
    } catch (e, stack) {
      debugPrint('Error in ExplorePlaces provider: $e\n$stack');
      throw Exception('Failed to load places: $e');
    }
  }

  Future<List<PlacesSearchResult>> _fetchPlacesForCity(
    String cityName,
    String? category,
    Position currentPosition,
  ) async {
    final placesList = _cityPlaces[cityName] ?? _cityPlaces['Rotterdam']!;
    final List<PlacesSearchResult> allResults = [];
    final errors = <String>[];

    final futures = placesList.map((location) async {
      try {
        final results = await _placesService.searchPlaces(
          city: cityName,
          query: location,
          location: PlaceLocation(
            lat: currentPosition.latitude,
            lng: currentPosition.longitude,
          ),
        );
        if (results.isNotEmpty) {
          return _enrichPlaceResult(results.first, location);
        }
      } catch (e) {
        errors.add('Failed to fetch $location: $e');
        debugPrint('Error fetching location $location: $e');
      }
      return null;
    });

    final results = await Future.wait(futures);
    allResults.addAll(results.whereType<PlacesSearchResult>());

    if (errors.isNotEmpty && allResults.isEmpty) {
      throw Exception('Failed to fetch places: ${errors.join(', ')}');
    }

    if (category != null && category != 'All') {
      final relevantTypes = _categoryToPlaceTypes[category] ?? [];
      if (relevantTypes.isNotEmpty) {
        return allResults.where((place) {
          return place.types?.any((type) => relevantTypes.contains(type)) ?? false;
        }).toList();
      }
    }

    return allResults;
  }

  Future<Place> _enhancePlaceWithDetails(PlacesSearchResult result, Position currentPosition) async {
    try {
      final details = await _placesService.getPlaceDetails(result.placeId);
      
      // Calculate distance
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        result.geometry?.location.lat ?? 0,
        result.geometry?.location.lng ?? 0,
      ) / 1000; // Convert to kilometers

      // Get activities based on place types
      final activities = _getActivitiesFromTypes(result.types ?? []);

      return Place(
        id: 'google_${result.placeId}',
        name: result.name,
        address: result.formattedAddress ?? '',
        description: result.vicinity ?? result.formattedAddress ?? '',
        rating: result.rating?.toDouble() ?? 0.0,
        photos: result.photos?.map((p) => p.photoReference).toList() ?? [],
        types: result.types ?? [],
        location: PlaceLocation(
          lat: result.geometry?.location.lat ?? 0,
          lng: result.geometry?.location.lng ?? 0,
        ),
        priceLevel: details['priceLevel'] as int?,
        openingHours: details['openingHours'] as Map<String, dynamic>?,
        isOpen: details['openingHours']?['openNow'] as bool? ?? false,
        activities: activities,
        distance: distance,
      );
    } catch (e) {
      debugPrint('Error enhancing place details: $e');
      // Return a basic Place object if enhancement fails
      return Place(
        id: 'google_${result.placeId}',
        name: result.name,
        address: result.formattedAddress ?? '',
        location: PlaceLocation(
          lat: result.geometry?.location.lat ?? 0,
          lng: result.geometry?.location.lng ?? 0,
        ),
      );
    }
  }

  // Helper method to enrich place results with custom descriptions
  PlacesSearchResult _enrichPlaceResult(PlacesSearchResult result, String searchQuery) {
    if (result.formattedAddress == null || result.formattedAddress!.isEmpty) {
      if (_placeDescriptions.containsKey(searchQuery)) {
        return PlacesSearchResult(
          name: result.name,
          placeId: result.placeId,
          formattedAddress: _placeDescriptions[searchQuery],
          photos: result.photos,
          geometry: result.geometry,
          types: result.types,
          rating: result.rating,
          priceLevel: result.priceLevel,
          openingHours: result.openingHours,
          reference: result.reference,
        );
      }
    }
    return result;
  }

  String getPhotoUrl(String photoReference) {
    return _placesService.getPhotoUrl(photoReference);
  }

  List<String> _getActivitiesFromTypes(List<String> types) {
    final activities = <String>[];
    
    for (final type in types) {
      switch (type) {
        case 'restaurant':
        case 'cafe':
        case 'bar':
          activities.add('Dining');
          break;
        case 'museum':
        case 'art_gallery':
          activities.add('Culture');
          break;
        case 'park':
        case 'natural_feature':
          activities.add('Nature');
          break;
        case 'tourist_attraction':
        case 'point_of_interest':
          activities.add('Sightseeing');
          break;
        case 'shopping_mall':
        case 'store':
          activities.add('Shopping');
          break;
      }
    }
    
    return activities.toSet().toList(); // Remove duplicates
  }
}

String? _getClosingTime(List<dynamic>? periods) {
  if (periods == null || periods.isEmpty) return null;
  
  final now = DateTime.now();
  final todayPeriod = periods.firstWhere(
    (period) => period['open']['day'] == now.weekday % 7,
    orElse: () => null,
  );
  
  if (todayPeriod == null) return null;
  
  final closeTime = todayPeriod['close']['time'];
  if (closeTime == null) return null;
  
  return '${closeTime.substring(0, 2)}:${closeTime.substring(2)}';
}

List<String> _getActivitiesFromTypes(List<String> types) {
  final activityMap = {
    'park': 'Hiking',
    'museum': 'Sightseeing',
    'art_gallery': 'Art',
    'restaurant': 'Dining',
    'shopping_mall': 'Shopping',
    'tourist_attraction': 'Sightseeing',
    'amusement_park': 'Entertainment',
    'aquarium': 'Family',
    'zoo': 'Family',
    'night_club': 'Nightlife',
    'bar': 'Nightlife',
    'cafe': 'Coffee',
    'gym': 'Fitness',
    'spa': 'Wellness',
    'beach': 'Nature',
    'movie_theater': 'Entertainment',
    'library': 'Culture',
    'church': 'Culture',
    'mosque': 'Culture',
    'temple': 'Culture',
    'synagogue': 'Culture',
  };

  return types
    .map((type) => activityMap[type])
    .where((activity) => activity != null)
    .toSet()
    .toList()
    .cast<String>();
} 