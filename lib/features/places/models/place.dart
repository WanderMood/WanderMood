import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'place.freezed.dart';
part 'place.g.dart';

class PlaceLocationConverter implements JsonConverter<PlaceLocation, Map<String, dynamic>> {
  const PlaceLocationConverter();

  @override
  PlaceLocation fromJson(Map<String, dynamic> json) {
    return PlaceLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(PlaceLocation location) {
    return {
      'lat': location.lat,
      'lng': location.lng,
    };
  }
}

@freezed
class PlaceLocation with _$PlaceLocation {
  const factory PlaceLocation({
    required double lat,
    required double lng,
  }) = _PlaceLocation;

  factory PlaceLocation.fromJson(Map<String, dynamic> json) => _$PlaceLocationFromJson(json);
}

@freezed
class Place with _$Place {
  const factory Place({
    required String id,
    required String name,
    required String address,
    double? rating,
    required List<String> photos,
    required List<String> types,
    @PlaceLocationConverter() required PlaceLocation location,
    String? description,
    Map<String, dynamic>? openingHours,
    bool? isOpen,
    double? distance,
    @Default(false) bool isAsset,
    int? priceLevel,
    String? phoneNumber,
    String? website,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}

@freezed
class OpeningHours with _$OpeningHours {
  const factory OpeningHours({
    required bool openNow,
    List<String>? weekdayText,
  }) = _OpeningHours;

  factory OpeningHours.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursFromJson(json);
} 