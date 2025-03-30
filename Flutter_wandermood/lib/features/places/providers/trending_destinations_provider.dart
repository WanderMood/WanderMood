import 'package:flutter_google_maps_webservices/places.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../services/places_service.dart';

part 'trending_destinations_provider.g.dart';

@riverpod
class TrendingDestinations extends _$TrendingDestinations {
  // Improved search terms based on API logs
  final Map<String, List<String>> _cityDestinations = {
    'Rotterdam': [
      "Rotterdam Centrum",
      "Euromast", 
      "Markthal Tours",
      "Unesco Werelderfgoed Kinderdijk", // Changed from "Kinderdijk ⚡"
      "Erasmusbrug", // Changed from "Erasmusbrug 🌉"
      "Rivièrahal Blijdorp Rotterdam Zoo", // Changed from "Blijdorp Zoo 🦁"
      "Kunsthal Rotterdam", // Changed from "Kunsthal 🎨"
      "ss Rotterdam", // Changed from "SS Rotterdam 🚢"
      "Museum Boijmans Van Beuningen", // Changed from "Boijmans Depot 🏺"
      "Witte Huis Rotterdam", // Instead of "Witte de Withstraat 🍹"
      "Arboretum trompenburg", // Instead of "Kralingse Bos 🌳"
      "The Rotterdam", // New addition
    ],
    'Amsterdam': [
      "Amsterdam Centrum 🏙️",
      "Anne Frank House 🏠",
      "Van Gogh Museum 🎨",
      "Vondelpark 🌳",
      "Rijksmuseum 🏛️",
      "Amsterdam Canals 🚢",
      "NEMO Science Museum 🔬",
      "A'DAM Lookout 🗼"
    ],
    'Utrecht': [
      "Utrecht Dom Tower 🗼",
      "Utrecht Canals 🚢",
      "Railway Museum 🚂",
      "Centraal Museum 🏛️",
      "Botanic Gardens 🌺",
      "Oudegracht 🏙️",
      "St. Martin's Cathedral 🏛️",
      "Museum Speelklok 🎵"
    ],
    'The Hague': [
      "Peace Palace 🏛️",
      "Mauritshuis 🎨",
      "Scheveningen Beach 🏖️",
      "Binnenhof 🏛️",
      "Madurodam 🏙️",
      "Kunstmuseum 🎨",
      "Escher Museum 🖼️",
      "Panorama Mesdag 🖼️"
    ]
  };
  
  // Map of emojis for trending destinations
  final Map<String, String> _placeEmojis = {
    "Rotterdam Centrum": "🏙️",
    "Euromast": "🗼",
    "Markthal Tours": "🏛️",
    "Unesco Werelderfgoed Kinderdijk": "⚡",
    "Erasmusbrug": "🌉", 
    "Rivièrahal Blijdorp Rotterdam Zoo": "🦁",
    "Kunsthal Rotterdam": "🎨",
    "ss Rotterdam": "🚢",
    "Museum Boijmans Van Beuningen": "🏺",
    "Witte Huis Rotterdam": "🍹",
    "Arboretum trompenburg": "🌳",
    "The Rotterdam": "🏢",
  };
  
  // Custom descriptions for better place information
  final Map<String, String> _placeDescriptions = {
    "Rotterdam Centrum": "Vibrant city center with modern architecture and shopping",
    "Euromast": "Iconic observation tower with panoramic views of Rotterdam",
    "Markthal Tours": "Stunning indoor market with apartments and food stalls",
    "Unesco Werelderfgoed Kinderdijk": "Historic windmills and UNESCO World Heritage site",
    "Erasmusbrug": "Elegant swan-shaped bridge spanning the Nieuwe Maas river",
    "Rivièrahal Blijdorp Rotterdam Zoo": "Award-winning zoo with diverse animal habitats",
    "Kunsthal Rotterdam": "Contemporary art museum with rotating exhibitions",
    "ss Rotterdam": "Historic cruise ship converted to hotel and attraction",
    "Museum Boijmans Van Beuningen": "Renowned art museum with mirrored depot building",
    "Witte Huis Rotterdam": "Europe's first skyscraper in Art Nouveau style",
    "Arboretum trompenburg": "Beautiful botanical garden with rare plants",
    "The Rotterdam": "Iconic vertical city designed by Rem Koolhaas",
  };
  
  // Map categories to destination types for filtering
  final Map<String, List<String>> _categoryToDestinationTypes = {
    'Architecture': ['🏛️', '🏙️', '🏠', '🗼', '🌉', '🏢'],
    'Culture': ['🏛️', '🎨', '🖼️', '🎵', '🏠', '🏺'],
    'Food': ['🍴', '🍽️', '🍷', '🍺', '🏛️'],
    'Nature': ['🌳', '🌺', '🦁', '🏖️', '⚡'],
    'History': ['🏛️', '🏠', '🚂', '🚢', '⚡'],
    'Art': ['🎨', '🖼️', '🏛️', '🏺'],
    'Family': ['🦁', '🔬', '🚂', '🏙️', '🗼'],
    'Photography': ['🗼', '🌉', '🏙️', '🏛️', '🌳', '🏖️', '⚡'],
    'Sports': ['🌳', '🏖️', '🚢'],
    'Accommodation': ['🏨', '🚢'],
  };

  @override
  Future<List<PlacesSearchResult>> build({String? city, String? category}) async {
    final service = ref.read(placesServiceProvider.notifier);
    List<PlacesSearchResult> allResults = [];

    // Use the provided city or default to Rotterdam
    final cityName = city ?? 'Rotterdam';
    final destinations = _cityDestinations[cityName] ?? _cityDestinations['Rotterdam']!;
    
    // Filter destinations by category emoji if a category is provided
    List<String> filteredDestinations = destinations;
    if (category != null && category != 'All') {
      final relevantEmojis = _categoryToDestinationTypes[category] ?? [];
      if (relevantEmojis.isNotEmpty) {
        // Since we no longer have emojis in our search terms, we'll filter based on our emoji mapping
        filteredDestinations = destinations.where((dest) {
          String emoji = _placeEmojis[dest] ?? '';
          return relevantEmojis.contains(emoji);
        }).toList();
        
        // If no destinations match the filter, use all destinations
        if (filteredDestinations.isEmpty) {
          filteredDestinations = destinations;
        }
      }
    }

    for (final destination in filteredDestinations) {
      try {
        // Search with just the destination name for better results
        final results = await service.searchPlaces(destination);
        if (results.isNotEmpty) {
          // Enrich with custom description and emoji
          final result = results.first;
          final enrichedResult = _enrichDestinationResult(result, destination);
          allResults.add(enrichedResult);
        }
      } catch (e) {
        debugPrint('Error fetching destination $destination: $e');
      }
    }

    return allResults;
  }

  // Helper method to enrich destination results
  PlacesSearchResult _enrichDestinationResult(PlacesSearchResult result, String searchQuery) {
    // Get the emoji for this destination
    String emoji = _placeEmojis[searchQuery] ?? '';
    
    // Add emoji to name if needed
    String enhancedName = result.name;
    if (emoji.isNotEmpty && !enhancedName.contains(emoji)) {
      enhancedName = "$enhancedName $emoji";
    }
    
    // Use custom description if available
    String description = _placeDescriptions[searchQuery] ?? result.formattedAddress ?? '';
    
    return PlacesSearchResult(
      name: enhancedName,
      placeId: result.placeId,
      formattedAddress: description,
      photos: result.photos,
      geometry: result.geometry,
      types: result.types,
      rating: result.rating,
      priceLevel: result.priceLevel,
      openingHours: result.openingHours,
      reference: result.reference,
    );
  }

  String getPhotoUrl(String photoReference) {
    final service = ref.read(placesServiceProvider.notifier);
    return service.getPhotoUrl(photoReference);
  }
}