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
    'San Francisco': [
      "Golden Gate Bridge",
      "Alcatraz Island",
      "Fisherman's Wharf",
      "Pier 39",
      "Lombard Street",
      "Palace of Fine Arts",
      "Chinatown San Francisco",
      "Twin Peaks",
      "Painted Ladies",
      "Golden Gate Park",
      "Exploratorium",
      "Coit Tower",
    ],
    'Barendrecht': [
      "Carnisse Grienden",
      "Zuidpolder Barendrecht",
      "Oude Maas",
      "Watertoren Barendrecht",
      "Historische Haven Barendrecht",
      "Kleine Duiker",
      "Koedood River",
      "Gaatkensplas",
      "Doormanpark",
    ],
  };

  // Fallback places for each city when API calls fail
  final Map<String, List<Place>> _fallbackPlaces = {
    'San Francisco': [
      Place(
        id: 'golden_gate',
        name: 'Golden Gate Bridge',
        address: 'Golden Gate Bridge, San Francisco, CA 94129',
        rating: 4.8,
        photos: ['assets/images/fallbacks/default.jpg'],
        types: ['point_of_interest', 'tourist_attraction'],
        location: const PlaceLocation(lat: 37.8199, lng: -122.4783),
        description: 'Iconic suspension bridge spanning the Golden Gate Strait',
        emoji: '🌉',
        tag: 'Landmark',
        isAsset: true,
        activities: ['Sightseeing', 'Photography', 'Walking'],
      ),
      Place(
        id: 'alcatraz',
        name: 'Alcatraz Island',
        address: 'San Francisco, CA 94133',
        rating: 4.7,
        photos: ['assets/images/fallbacks/default.jpg'],
        types: ['tourist_attraction', 'museum'],
        location: const PlaceLocation(lat: 37.8270, lng: -122.4230),
        description: 'Historic federal prison on an island in San Francisco Bay',
        emoji: '🏝️',
        tag: 'History',
        isAsset: true,
        activities: ['Tour', 'Museum', 'Boat Trip'],
      ),
      Place(
        id: 'pier39',
        name: 'Pier 39',
        address: 'Beach St & The Embarcadero, San Francisco, CA 94133',
        rating: 4.6,
        photos: ['assets/images/fallbacks/default.jpg'],
        types: ['tourist_attraction', 'shopping'],
        location: const PlaceLocation(lat: 37.8087, lng: -122.4098),
        description: 'Popular shopping center and tourist attraction with sea lions',
        emoji: '🦭',
        tag: 'Entertainment',
        isAsset: true,
        activities: ['Shopping', 'Dining', 'Sea Lion Watching'],
      ),
    ],
    'Rotterdam': [
      Place(
        id: 'markthal',
        name: 'Markthal Rotterdam',
        address: 'Dominee Jan Scharpstraat 298, 3011 GZ Rotterdam',
        rating: 4.6,
        photos: ['assets/images/fallbacks/default.jpg'],
        types: ['point_of_interest', 'food', 'establishment'],
        location: const PlaceLocation(lat: 51.920, lng: 4.487),
        description: 'Stunning market hall with food stalls and apartments',
        emoji: '🍲',
        tag: 'Food & Culture',
        isAsset: true,
        activities: ['Food Tour', 'Shopping', 'Architecture'],
      ),
      Place(
        id: 'euromast',
        name: 'Euromast Rotterdam',
        address: 'Parkhaven 20, 3016 GM Rotterdam',
        rating: 4.7,
        photos: ['assets/images/fallbacks/default.jpg'],
        types: ['point_of_interest', 'tourist_attraction'],
        location: const PlaceLocation(lat: 51.905, lng: 4.467),
        description: 'Iconic tower with panoramic city views',
        emoji: '🗼',
        tag: 'Landmark',
        isAsset: true,
        activities: ['Observation', 'Fine Dining', 'Abseiling'],
      ),
    ],
    'Barendrecht': [
      Place(
        id: 'carnisse_grienden',
        name: 'Carnisse Grienden',
        address: 'Oude Maas, 2992 Barendrecht',
        rating: 4.5,
        photos: ['assets/images/fallbacks/park.jpg'],
        types: ['park', 'natural_feature', 'point_of_interest'],
        location: const PlaceLocation(lat: 51.8583, lng: 4.5372),
        description: 'Beautiful nature reserve along the Oude Maas river',
        emoji: '🌳',
        tag: 'Nature',
        isAsset: true,
        activities: ['Walking', 'Cycling', 'Bird Watching'],
      ),
      Place(
        id: 'kleine_duiker',
        name: 'Kleine Duiker',
        address: 'Rijksstraatweg 9, 2988 BA Barendrecht',
        rating: 4.4,
        photos: ['assets/images/fallbacks/default.jpg'],
        types: ['farm', 'point_of_interest'],
        location: const PlaceLocation(lat: 51.8444, lng: 4.5348),
        description: 'Educational farm with various animals and activities',
        emoji: '🐑',
        tag: 'Family',
        isAsset: true,
        activities: ['Animal Feeding', 'Family Outings', 'Learning'],
      ),
      Place(
        id: 'historische_haven',
        name: 'Historische Haven Barendrecht',
        address: 'Binnenlandse Baan, 2991 Barendrecht',
        rating: 4.3,
        photos: ['assets/images/fallbacks/default.jpg'],
        types: ['point_of_interest', 'tourist_attraction'],
        location: const PlaceLocation(lat: 51.8556, lng: 4.5471),
        description: 'Historic harbor showcasing maritime heritage',
        emoji: '⚓',
        tag: 'History',
        isAsset: true,
        activities: ['Sightseeing', 'Photography', 'History'],
      ),
    ],
  };

  @override
  Future<List<Place>> build({String? city}) async {
    final service = ref.read(placesServiceProvider.notifier);
    List<Place> allResults = [];
    bool hasApiError = false;

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
            rating: result.rating != null ? result.rating!.toDouble() : 0.0,
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
        hasApiError = true;
      }
    }

    // If we failed to fetch places or got no results, use fallback places
    if (allResults.isEmpty || hasApiError) {
      debugPrint('Using fallback places for $cityName');
      // Find exact match first or use a default
      final fallbacksForCity = _fallbackPlaces[cityName] ?? 
                             _fallbackPlaces['San Francisco'] ?? 
                             [_getDefaultPlace(cityName)];
      
      // If we have some results but had errors, append fallbacks
      if (allResults.isNotEmpty) {
        allResults.addAll(fallbacksForCity);
      } else {
        // If we have no results, just use fallbacks
        allResults = fallbacksForCity;
      }
    }

    return allResults;
  }

  Place _getDefaultPlace(String cityName) {
    return Place(
      id: 'default_place',
      name: 'Popular Place in $cityName',
      address: '$cityName, Netherlands',
      rating: 4.5,
      photos: ['assets/images/fallbacks/default.jpg'],
      types: ['point_of_interest', 'tourist_attraction'],
      location: const PlaceLocation(lat: 0.0, lng: 0.0),
      description: 'A popular destination in $cityName',
      emoji: '🏙️',
      tag: 'Popular',
      isAsset: true,
      activities: ['Sightseeing', 'Culture', 'Food'],
    );
  }

  String getPhotoUrl(String photoReference) {
    final service = ref.read(placesServiceProvider.notifier);
    return service.getPhotoUrl(photoReference);
  }
} 