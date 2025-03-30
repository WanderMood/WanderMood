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
  };

  @override
  Future<List<Place>> build({String? city}) async {
    final service = ref.read(placesServiceProvider.notifier);
    List<Place> allResults = [];

    // Use the provided city or default to Rotterdam
    final cityName = city ?? 'Rotterdam';
    final placesList = _cityPlaces[cityName] ?? _cityPlaces['Rotterdam']!;

    for (final location in placesList) {
      try {
        final results = await service.searchPlaces(location);
        if (results.isNotEmpty) {
          final result = results.first;
          final place = Place(
            id: result.placeId ?? '',
            name: result.name ?? '',
            address: result.formattedAddress ?? '',
            rating: result.rating ?? 0.0,
            photos: result.photos?.map((p) => p.photoReference).toList() ?? [],
            types: result.types ?? [],
            location: PlaceLocation(
              lat: result.geometry?.location.lat ?? 0.0,
              lng: result.geometry?.location.lng ?? 0.0,
            ),
          );
          allResults.add(place);
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