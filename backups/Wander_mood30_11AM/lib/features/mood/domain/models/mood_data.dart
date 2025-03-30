import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood_data.freezed.dart';
part 'mood_data.g.dart';

@freezed
class MoodData with _$MoodData {
  const factory MoodData({
    required String id,
    required String userId,
    required double moodScore,
    required String moodType,
    required DateTime timestamp,
    String? description,
    String? location,
    @Default([]) List<String> tags,
    @Default({}) Map<String, dynamic> metadata,
  }) = _MoodData;

  factory MoodData.fromJson(Map<String, dynamic> json) =>
      _$MoodDataFromJson(json);
} 