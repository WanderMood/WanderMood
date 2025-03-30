import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:wandermood/core/config/env_config.dart';

part 'place.freezed.dart';
part 'place.g.dart';

@freezed
class Place with _$Place {
  const factory Place({
    required String id,
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required String address,
    required List<String> categories,
    required double rating,
    required int reviewCount,
    required String imageUrl,
    required bool isOpen,
    required Map<String, dynamic> openingHours,
    required List<String> photos,
    required Map<String, dynamic> contact,
    required Map<String, dynamic> location,
    required List<Map<String, dynamic>> amenities,
    required double distance,
    required bool isFavorite,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

  factory Place.fromPlacesSearchResult(PlacesSearchResult result) {
    Map<String, dynamic> convertPeriods(Map<Object, dynamic>? periods) {
      if (periods == null) return {};
      return Map<String, dynamic>.from(periods);
    }

    return Place(
      id: 'google_${result.placeId}',
      name: result.name,
      description: result.vicinity ?? result.formattedAddress ?? '',
      latitude: result.geometry?.location.lat ?? 0,
      longitude: result.geometry?.location.lng ?? 0,
      address: result.formattedAddress ?? result.vicinity ?? '',
      categories: result.types ?? [],
      rating: (result.rating ?? 0).toDouble(),
      reviewCount: 0,
      imageUrl: result.photos?.isNotEmpty == true
          ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${result.photos![0].photoReference}&key=${EnvConfig.googlePlacesApiKey}'
          : '',
      isOpen: result.openingHours?.openNow ?? false,
      openingHours: convertPeriods(result.openingHours?.periods?.asMap()),
      photos: result.photos?.map((p) => p.photoReference).toList() ?? [],
      contact: {
        'phone': '',
        'website': '',
      },
      location: {
        'lat': result.geometry?.location.lat ?? 0,
        'lng': result.geometry?.location.lng ?? 0,
      },
      amenities: (result.types ?? []).map((type) => {
        'name': type,
        'icon': _getAmenityIcon(type),
      }).toList(),
      distance: 0,
      isFavorite: false,
    );
  }

  static String _getAmenityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'restaurant':
        return '🍽️';
      case 'cafe':
        return '☕';
      case 'bar':
        return '🍸';
      case 'hotel':
        return '🏨';
      case 'museum':
        return '🏛️';
      case 'park':
        return '🌳';
      case 'shopping_mall':
        return '🛍️';
      case 'tourist_attraction':
        return '🎯';
      default:
        return '📍';
    }
  }
}

@freezed
class PlaceLocation with _$PlaceLocation {
  const factory PlaceLocation({
    required double lat,
    required double lng,
  }) = _PlaceLocation;

  factory PlaceLocation.fromJson(Map<String, dynamic> json) => 
      _$PlaceLocationFromJson(json);
} 