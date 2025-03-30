import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_google_maps_webservices/places.dart';

part 'place.freezed.dart';
part 'place.g.dart';

@freezed
class Place with _$Place {
  const factory Place({
    required String id,
    required String name,
    required String address,
    @Default(0.0) double rating,
    @Default([]) List<String> photos,
    @Default([]) List<String> types,
    required PlaceLocation location,
    String? description,
    String? emoji,
    String? tag,
    @Default(false) bool isAsset,
    @Default([]) List<String> activities,
    int? priceLevel,
    @Default(0.0) double distance,
    Map<String, dynamic>? openingHours,
    @Default(false) bool isOpen,
    String? closingTime,
    String? phoneNumber,
    String? website,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

  factory Place.fromPlacesSearchResult(PlacesSearchResult result) {
    return Place(
      id: 'google_${result.placeId}',
      name: result.name,
      address: result.formattedAddress ?? result.vicinity ?? '',
      description: result.vicinity ?? result.formattedAddress ?? '',
      rating: result.rating?.toDouble() ?? 0.0,
      photos: result.photos?.map((p) => p.photoReference).toList() ?? [],
      types: result.types ?? [],
      location: PlaceLocation(
        lat: result.geometry?.location.lat ?? 0,
        lng: result.geometry?.location.lng ?? 0,
      ),
      priceLevel: result.priceLevel?.index,
      isOpen: result.openingHours?.openNow ?? false,
    );
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