import 'package:freezed_annotation/freezed_annotation.dart';

part 'adventure.freezed.dart';
part 'adventure.g.dart';

@freezed
class Adventure with _$Adventure {
  const factory Adventure({
    required String id,
    required String timeOfDay,
    required String title,
    required String location,
    required double rating,
    required String imageUrl,
    @Default(false) bool isFavorite,
  }) = _Adventure;

  factory Adventure.fromJson(Map<String, dynamic> json) => _$AdventureFromJson(json);
} 