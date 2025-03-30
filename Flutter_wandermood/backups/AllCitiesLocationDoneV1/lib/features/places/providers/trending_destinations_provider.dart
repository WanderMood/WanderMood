import 'package:flutter_google_maps_webservices/places.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../services/places_service.dart';

part 'trending_destinations_provider.g.dart';

@riverpod
class TrendingDestinations extends _$TrendingDestinations {
  final Map<String, List<String>> _cityDestinations = {
    'Rotterdam': [
      "Rotterdam Centrum 🏙️",
      "Euromast 🗼",
      "Markthal 🏛️",
      "Kinderdijk ⚡",
      "Erasmusbrug 🌉",
      "Blijdorp Zoo 🦁",
      "Kunsthal 🎨",
      "SS Rotterdam 🚢"
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
    ],
    'Eindhoven': [
      "Strijp-S 🏭",
      "Van Abbemuseum 🎨",
      "Philips Museum 💡",
      "Glow Festival 🌈",
      "PSV Stadium 🏟️",
      "DAF Museum 🚗",
      "Dutch Design Week 🎭",
      "Evoluon 🛸"
    ],
    'Groningen': [
      "Groninger Museum 🏛️",
      "Martini Tower 🗼",
      "Grote Markt 🏙️",
      "University Museum 🎓",
      "Northern Shipping Museum 🚢",
      "Noorderplantsoen 🌳",
      "Forum Groningen 📚",
      "Prinsenhof Gardens 🌸"
    ],
    'Maastricht': [
      "Vrijthof Square 🏙️",
      "Maastricht Underground 🧱",
      "Basilica of St. Servatius 🏛️",
      "Mount Saint Peter 🏔️",
      "Museum aan het Vrijthof 🎨",
      "Bonnefanten Museum 🏛️",
      "Helpoort 🏰",
      "Maastricht City Hall 🏛️"
    ],
    'Tilburg': [
      "De Pont Museum 🎨",
      "Textile Museum 🧵",
      "Spoorzone 🚂",
      "Doloris Meta Maze 🌀",
      "Stadhuisplein 🏙️",
      "Tilburg University 🎓",
      "013 Poppodium 🎵",
      "Piushaven 🚤"
    ]
  };

  @override
  Future<List<PlacesSearchResult>> build({String? city}) async {
    final service = ref.read(placesServiceProvider.notifier);
    List<PlacesSearchResult> allResults = [];

    // Use the provided city or default to Rotterdam
    final cityName = city ?? 'Rotterdam';
    
    // If we have pre-defined destinations for this city, use them
    final destinations = _cityDestinations[cityName] ?? _cityDestinations['Rotterdam']!;

    for (final destination in destinations) {
      try {
        // Try to search for the destination in the specific city
        final results = await service.searchPlaces("${destination.split(' ')[0]} $cityName");
        if (results.isNotEmpty) {
          allResults.add(results.first);
        }
      } catch (e) {
        debugPrint('Error fetching destination $destination: $e');
      }
    }

    return allResults;
  }

  String getPhotoUrl(String photoReference) {
    final service = ref.read(placesServiceProvider.notifier);
    return service.getPhotoUrl(photoReference);
  }
}