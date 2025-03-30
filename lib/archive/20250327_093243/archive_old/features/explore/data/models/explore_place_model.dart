import 'package:freezed_annotation/freezed_annotation.dart';

part 'explore_place_model.freezed.dart';
part 'explore_place_model.g.dart';

@freezed
class ExplorePlaceModel with _$ExplorePlaceModel {
  const factory ExplorePlaceModel({
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
  }) = _ExplorePlaceModel;

  factory ExplorePlaceModel.fromJson(Map<String, dynamic> json) =>
      _$ExplorePlaceModelFromJson(json);
} 