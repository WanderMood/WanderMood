import 'package:flutter_google_maps_webservices/places.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../services/places_service.dart';

part 'explore_places_provider.g.dart';

@riverpod
class ExplorePlaces extends _$ExplorePlaces {
  final Map<String, List<String>> _cityPlaces = {
    'Rotterdam': [
      "Markthal Rotterdam",
      "Kunsthal Rotterdam",
      "Fenix Food Factory",
      "Euromast Rotterdam",
      "SS Rotterdam",
      "Cube Houses Rotterdam",
      "Erasmus Bridge Rotterdam",
      "Rotterdam Zoo",
      "Hotel New York Rotterdam",
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
    'Eindhoven': [
      "Strijp-S",
      "Van Abbemuseum",
      "Philips Museum",
      "Evoluon",
      "PSV Stadium",
      "DAF Museum",
      "Eindhoven City Center",
      "Genneper Parks",
      "High Tech Campus",
    ],
    'Groningen': [
      "Groninger Museum",
      "Martini Tower",
      "Grote Markt",
      "Prinsentuin",
      "Noorderplantsoen",
      "University Museum",
      "Noordelijk Scheepvaartmuseum",
      "Forum Groningen",
      "City Park",
    ],
    'Maastricht': [
      "Vrijthof",
      "Bonnefanten Museum",
      "St. Servatius Bridge",
      "Helpoort",
      "Saint Peter's Caves",
      "Market Square",
      "City Park",
      "Basilica of Saint Servatius",
      "Natural History Museum",
    ],
    'Tilburg': [
      "De Pont Museum",
      "Textile Museum",
      "Spoorzone",
      "Doloris Meta Maze",
      "Stadhuisplein",
      "Tilburg University Campus",
      "013 Poppodium",
      "Piushaven",
      "Tilburg Railway Station",
    ],
  };

  @override
  Future<List<PlacesSearchResult>> build({String? city}) async {
    final service = ref.read(placesServiceProvider.notifier);
    List<PlacesSearchResult> allResults = [];

    // Use the provided city or default to Rotterdam
    final cityName = city ?? 'Rotterdam';
    final placesList = _cityPlaces[cityName] ?? _cityPlaces['Rotterdam']!;

    for (final location in placesList) {
      try {
        final results = await service.searchPlaces(location);
        if (results.isNotEmpty) {
          allResults.add(results.first);
        }
      } catch (e) {
        debugPrint('Error fetching location $location: $e');
      }
    }

    return allResults;
  }

  String getPhotoUrl(String photoReference) {
    final service = ref.read(placesServiceProvider.notifier);
    return service.getPhotoUrl(photoReference);
  }
} 