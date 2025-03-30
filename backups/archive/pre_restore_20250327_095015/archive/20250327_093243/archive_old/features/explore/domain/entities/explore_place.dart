import 'package:freezed_annotation/freezed_annotation.dart';

part 'explore_place.freezed.dart';

@freezed
class ExplorePlace with _$ExplorePlace {
  const factory ExplorePlace({
    required String id,
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    required List<String> photos,
    required double rating,
    required int reviewCount,
    required String address,
    required List<String> categories,
    required Map<String, dynamic> additionalInfo,
  }) = _ExplorePlace;
} 