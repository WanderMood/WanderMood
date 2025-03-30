import 'package:flutter_google_maps_webservices/places.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../services/places_service.dart';

part 'explore_places_provider.g.dart';

@riverpod
class ExplorePlaces extends _$ExplorePlaces {
  // Improved search queries based on API logs
  final Map<String, List<String>> _cityPlaces = {
    'Rotterdam': [
      "Markthal Tours Rotterdam",
      "Kunsthal Rotterdam",
      "Euromast Rotterdam", 
      "Erasmusbrug Rotterdam",
      "ss Rotterdam",
      "Kijk-Kubus Rotterdam", // Instead of "Cube Houses Rotterdam"
      "Museum Boijmans Van Beuningen", // Instead of "Boijmans Van Beuningen Depot"
      "Maritime Museum Rotterdam",
      "The Rotterdam", // Instead of "De Rotterdam Building"
      "Voorhaven Delfshaven", // Instead of "Delfshaven Rotterdam"
      "Arboretum Trompenburg", // Instead of "Kralingse Bos Rotterdam"
      "Witte Huis Rotterdam", // Instead of "Witte de Withstraat Rotterdam"
      "Hotel New York",
      "Pilgrim Fathers Church",
      "Miniworld Rotterdam",
      "Dutch Pinball Museum",
      "Dakpark Rotterdam",
      "CityHub Rotterdam", // Alternative to citizenM
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
    final service = ref.read(placesServiceProvider.notifier);
    List<PlacesSearchResult> allResults = [];

    // Use the provided city or default to Rotterdam
    final cityName = city ?? 'Rotterdam';
    final placesList = _cityPlaces[cityName] ?? _cityPlaces['Rotterdam']!;

    for (final location in placesList) {
      try {
        final results = await service.searchPlaces(location);
        if (results.isNotEmpty) {
          // Add custom description if available
          final result = results.first;
          final enrichedResult = _enrichPlaceResult(result, location);
          allResults.add(enrichedResult);
        }
      } catch (e) {
        debugPrint('Error fetching location $location: $e');
      }
    }
    
    // Filter results by category if one is provided and it's not 'All'
    if (category != null && category != 'All') {
      final relevantTypes = _categoryToPlaceTypes[category] ?? [];
      if (relevantTypes.isNotEmpty) {
        allResults = allResults.where((place) {
          // Check if any of the place types match our category types
          return place.types?.any((type) => relevantTypes.contains(type)) ?? false;
        }).toList();
      }
    }

    return allResults;
  }

  // Helper method to enrich place results with custom descriptions
  PlacesSearchResult _enrichPlaceResult(PlacesSearchResult result, String searchQuery) {
    if (result.formattedAddress == null || result.formattedAddress!.isEmpty) {
      if (_placeDescriptions.containsKey(searchQuery)) {
        // Create a new result with our custom description
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
    final service = ref.read(placesServiceProvider.notifier);
    return service.getPhotoUrl(photoReference);
  }
} 