import 'package:freezed_annotation/freezed_annotation.dart';

part 'place.freezed.dart';
part 'place.g.dart';

@freezed
class Place with _$Place {
  const factory Place({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    required double latitude,
    required double longitude,
    required String address,
    required List<String> tags,
    required String priceRange,
    required double rating,
    double? moodMatchScore,
    String? moodMatchExplanation,
    Map<String, dynamic>? openingHours,
    String? phoneNumber,
    String? website,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
} 