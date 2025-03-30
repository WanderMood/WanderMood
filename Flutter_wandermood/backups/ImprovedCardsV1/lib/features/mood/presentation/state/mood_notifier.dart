import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wandermood/features/mood/domain/models/mood.dart';
import 'package:wandermood/features/mood/domain/models/activity.dart';
import 'package:wandermood/features/mood/domain/repositories/mood_repository.dart';
import 'package:wandermood/features/mood/application/mood_service.dart';
import 'package:wandermood/features/mood/presentation/state/mood_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mood_notifier.g.dart';

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  throw UnimplementedError('Moet worden overschreven met een echte implementatie');
});

final moodServiceProvider = Provider<MoodService>((ref) {
  final repository = ref.watch(moodRepositoryProvider);
  return MoodService(repository);
});

@riverpod
class MoodNotifier extends _$MoodNotifier {
  late final MoodService _service;

  @override
  MoodState build() {
    _service = ref.watch(moodServiceProvider);
    return const MoodState.initial();
  }

  Future<void> getMoods({DateTime? startDate, DateTime? endDate}) async {
    state = const MoodState.loading();
    try {
      final moods = await _service.getMoods(startDate: startDate, endDate: endDate);
      state = MoodState.loaded(moods: moods);
    } catch (e) {
      state = MoodState.error(e.toString());
    }
  }

  Future<void> createMood(Mood mood) async {
    state = const MoodState.loading();
    try {
      final savedMood = await _service.saveMood(mood);
      final currentMoods = state.maybeMap(
        loaded: (s) => s.moods,
        orElse: () => <Mood>[],
      );
      state = MoodState.loaded(moods: [...currentMoods, savedMood]);
    } catch (e) {
      state = MoodState.error(e.toString());
    }
  }

  Future<void> updateMood(Mood mood) async {
    state = const MoodState.loading();
    try {
      final updatedMood = await _service.saveMood(mood);
      final currentMoods = state.maybeMap(
        loaded: (s) => s.moods,
        orElse: () => <Mood>[],
      );
      final updatedMoods = currentMoods.map((m) => m.id == mood.id ? updatedMood : m).toList();
      state = MoodState.loaded(moods: updatedMoods);
    } catch (e) {
      state = MoodState.error(e.toString());
    }
  }

  Future<void> deleteMood(String moodId) async {
    state = const MoodState.loading();
    try {
      await _service.deleteMood(moodId);
      final currentMoods = state.maybeMap(
        loaded: (s) => s.moods,
        orElse: () => <Mood>[],
      );
      final updatedMoods = currentMoods.where((m) => m.id != moodId).toList();
      state = MoodState.loaded(moods: updatedMoods);
    } catch (e) {
      state = MoodState.error(e.toString());
    }
  }

  Future<void> getActivities() async {
    state = const MoodState.loading();
    try {
      final activities = await _service.getActivities();
      state = MoodState.loaded(activities: activities);
    } catch (e) {
      state = MoodState.error(e.toString());
    }
  }

  Future<void> getMoodStats() async {
    state = const MoodState.loading();
    try {
      final stats = await _service.getMoodStats();
      state = MoodState.loaded(stats: stats);
    } catch (e) {
      state = MoodState.error(e.toString());
    }
  }

  Future<void> createActivity(Activity activity) async {
    state = const MoodState.loading();
    try {
      await _service.createActivity(activity);
      await getActivities();
    } catch (e) {
      state = MoodState.error(e.toString());
    }
  }

  void watchMoods() {
    _service.watchMoods().listen(
      (moods) => state = MoodState.loaded(moods: moods),
      onError: (e) => state = MoodState.error(e.toString()),
    );
  }

  void watchActivities() {
    _service.watchActivities().listen(
      (activities) => state = MoodState.loaded(activities: activities),
      onError: (e) => state = MoodState.error(e.toString()),
    );
  }
} 