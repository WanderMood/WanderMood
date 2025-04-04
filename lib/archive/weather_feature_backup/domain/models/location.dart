import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

@freezed
class Location with _$Location {
  const factory Location({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    String? country,
    String? city,
    String? state,
    @Default(false) bool isFavorite,
    DateTime? lastVisited,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
} 