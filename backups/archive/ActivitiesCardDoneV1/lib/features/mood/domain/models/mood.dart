import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood.freezed.dart';
part 'mood.g.dart';

@freezed
abstract class Mood with _$Mood {
  const factory Mood({
    required String id,
    required String userId,
    required String label,
    required String emoji,
    required DateTime createdAt,
    String? note,
    double? energyLevel,
    @Default([]) List<String> activities,
    @Default(false) bool isShared,
  }) = _Mood;

  factory Mood.fromJson(Map<String, dynamic> json) => _$MoodFromJson(json);
} 