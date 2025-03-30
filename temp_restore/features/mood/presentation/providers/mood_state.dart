import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wandermood/features/mood/domain/models/mood.dart';

part 'mood_state.freezed.dart';

@freezed
abstract class MoodState with _$MoodState {
  const factory MoodState.initial({
    @Default([]) List<Mood> moods,
    Map<String, dynamic>? stats,
  }) = _Initial;

  const factory MoodState.loading({
    @Default([]) List<Mood> moods,
    Map<String, dynamic>? stats,
  }) = _Loading;

  const factory MoodState.loaded({
    required List<Mood> moods,
    Map<String, dynamic>? stats,
  }) = _Loaded;

  const factory MoodState.error({
    required String message,
    @Default([]) List<Mood> moods,
    Map<String, dynamic>? stats,
  }) = _Error;
} 