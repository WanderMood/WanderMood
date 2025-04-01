import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wandermood/features/mood/application/mood_service.dart';
import 'package:wandermood/features/mood/domain/models/mood.dart';
import 'package:wandermood/features/mood/domain/models/activity.dart';
import 'package:wandermood/features/mood/presentation/providers/mood_state.dart';

final moodNotifierProvider = StateNotifierProvider<MoodNotifier, MoodState>((ref) {
  return MoodNotifier(ref.watch(moodServiceProvider));
});

class MoodNotifier extends StateNotifier<MoodState> {
  final MoodService _service;

  MoodNotifier(this._service) : super(const MoodState.initial());

  Future<void> getMoods({DateTime? startDate, DateTime? endDate}) async {
    try {
      state = const MoodState.loading();
      final moods = await _service.getMoods(startDate: startDate, endDate: endDate);
      state = MoodState.loaded(moods: moods);
    } catch (e) {
      state = MoodState.error(message: e.toString());
    }
  }

  Future<void> createMood(Mood mood) async {
    try {
      state = const MoodState.loading();
      await _service.saveMood(mood);
      final moods = await _service.getMoods();
      state = MoodState.loaded(moods: moods);
    } catch (e) {
      state = MoodState.error(message: e.toString());
    }
  }

  Future<void> updateMood(Mood mood) async {
    try {
      state = const MoodState.loading();
      await _service.saveMood(mood);
      final moods = await _service.getMoods();
      state = MoodState.loaded(moods: moods);
    } catch (e) {
      state = MoodState.error(message: e.toString());
    }
  }

  Future<void> deleteMood(String moodId) async {
    try {
      state = const MoodState.loading();
      await _service.deleteMood(moodId);
      final moods = await _service.getMoods();
      state = MoodState.loaded(moods: moods);
    } catch (e) {
      state = MoodState.error(message: e.toString());
    }
  }

  Future<void> getMoodStats({DateTime? startDate, DateTime? endDate}) async {
    try {
      state = const MoodState.loading();
      final stats = await _service.getMoodStats(startDate: startDate, endDate: endDate);
      state.maybeWhen(
        loaded: (moods, _) => state = MoodState.loaded(moods: moods, stats: stats),
        orElse: () => state = MoodState.initial(stats: stats),
      );
    } catch (e) {
      state = MoodState.error(message: e.toString());
    }
  }

  Future<void> createActivity(Activity activity) async {
    try {
      state = const MoodState.loading();
      await _service.createActivity(activity);
      final moods = await _service.getMoods();
      state = MoodState.loaded(moods: moods);
    } catch (e) {
      state = MoodState.error(message: e.toString());
    }
  }

  Future<void> updateActivity(Activity activity) async {
    try {
      state = const MoodState.loading();
      await _service.updateActivity(activity);
      final moods = await _service.getMoods();
      state = MoodState.loaded(moods: moods);
    } catch (e) {
      state = MoodState.error(message: e.toString());
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      state = const MoodState.loading();
      await _service.deleteActivity(activityId);
      final moods = await _service.getMoods();
      state = MoodState.loaded(moods: moods);
    } catch (e) {
      state = MoodState.error(message: e.toString());
    }
  }

  void watchMoods() {
    _service.watchMoods().listen(
      (moods) => state.maybeWhen(
        loaded: (_, stats) => state = MoodState.loaded(moods: moods, stats: stats),
        orElse: () => state = MoodState.loaded(moods: moods),
      ),
      onError: (error) => state = MoodState.error(message: error.toString()),
    );
  }
} 