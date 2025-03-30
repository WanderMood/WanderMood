import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood.freezed.dart';
part 'mood.g.dart';

@freezed
class Mood with _$Mood {
  const factory Mood({
    required String id,
    required String userId,
    required String mood,
    required String activity,
    required double energyLevel,
    String? notes,
    required DateTime createdAt,
  }) = _Mood;

  factory Mood.fromJson(Map<String, dynamic> json) => _$MoodFromJson(json);
} 