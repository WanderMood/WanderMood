import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wandermood/features/mood/domain/models/mood.dart';
import 'package:wandermood/features/mood/domain/models/activity.dart';

part 'mood_state.freezed.dart';

@freezed
class MoodState with _$MoodState {
  const factory MoodState.initial() = _Initial;
  
  const factory MoodState.loading() = _Loading;
  
  const factory MoodState.loaded({
    @Default([]) List<Mood> moods,
    @Default([]) List<Activity> activities,
    @Default({}) Map<String, dynamic> stats,
  }) = _Loaded;
  
  const factory MoodState.error(String message) = _Error;
} 