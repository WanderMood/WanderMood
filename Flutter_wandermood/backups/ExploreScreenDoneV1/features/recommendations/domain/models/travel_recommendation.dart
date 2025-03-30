import 'package:freezed_annotation/freezed_annotation.dart';

part 'travel_recommendation.freezed.dart';
part 'travel_recommendation.g.dart';

@freezed
class TravelRecommendation with _$TravelRecommendation {
  const factory TravelRecommendation({
    required String id,
    required String title,
    required String description,
    required String location,
    required String imageUrl,
    required double rating,
    required List<String> tags,
    required double price,
    String? weatherInfo,
    String? moodMatch,
    @Default(false) bool isFavorite,
  }) = _TravelRecommendation;

  factory TravelRecommendation.fromJson(Map<String, dynamic> json) =>
      _$TravelRecommendationFromJson(json);
} 