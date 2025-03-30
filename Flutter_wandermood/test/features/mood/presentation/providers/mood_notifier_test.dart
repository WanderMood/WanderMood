import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:wandermood/features/mood/application/mood_service.dart';
import 'package:wandermood/features/mood/domain/models/mood.dart';
import 'package:wandermood/features/mood/domain/models/activity.dart';
import 'package:wandermood/features/mood/presentation/providers/mood_notifier.dart';
import 'package:wandermood/features/mood/presentation/providers/mood_state.dart';

class MockMoodService extends Mock implements MoodService {}

void main() {
  late MoodNotifier notifier;
  late MockMoodService mockService;

  setUp(() {
    mockService = MockMoodService();
    notifier = MoodNotifier(mockService);
  });

  test('initial state is MoodState.initial', () {
    expect(notifier.state, const MoodState.initial());
  });

  group('getMoods', () {
    test('should load moods successfully', () async {
      final mockMoods = [
        Mood(
          id: '1',
          userId: 'user1',
          label: 'Happy',
          emoji: '😊',
          createdAt: DateTime.now(),
        ),
        Mood(
          id: '2',
          userId: 'user1',
          label: 'Relaxed',
          emoji: '😌',
          createdAt: DateTime.now(),
        ),
      ];

      when(() => mockService.getMoods(startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
          .thenAnswer((_) async => mockMoods);

      await notifier.getMoods();

      expect(notifier.state, MoodState.loaded(moods: mockMoods));
    });

    test('should handle error when loading moods', () async {
      when(() => mockService.getMoods(startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
          .thenThrow(Exception('Failed to load moods'));

      await notifier.getMoods();

      expect(
        notifier.state,
        isA<_Error>().having(
          (state) => state.message,
          'error message',
          'Exception: Failed to load moods',
        ),
      );
    });
  });

  group('createMood', () {
    test('should create mood successfully', () async {
      final newMood = Mood(
        id: '3',
        userId: 'user1',
        label: 'Happy',
        emoji: '😊',
        createdAt: DateTime.now(),
      );

      when(() => mockService.saveMood(newMood)).thenAnswer((_) async => newMood);
      when(() => mockService.getMoods(startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
          .thenAnswer((_) async => [newMood]);

      await notifier.createMood(newMood);

      expect(notifier.state, MoodState.loaded(moods: [newMood]));
    });

    test('should handle error when creating mood', () async {
      final newMood = Mood(
        id: '3',
        userId: 'user1',
        label: 'Happy',
        emoji: '😊',
        createdAt: DateTime.now(),
      );

      when(() => mockService.saveMood(newMood)).thenThrow(Exception('Failed to save mood'));

      await notifier.createMood(newMood);

      expect(
        notifier.state,
        isA<_Error>().having(
          (state) => state.message,
          'error message',
          'Exception: Failed to save mood',
        ),
      );
    });
  });

  group('getMoodStats', () {
    final mockStats = {'average_energy': 5.0};

    test('successfully loads mood stats', () async {
      when(() => mockService.getMoodStats(startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
          .thenAnswer((_) async => mockStats);

      await notifier.getMoodStats();

      expect(notifier.state, MoodState.initial(stats: mockStats));
    });

    test('handles error when loading stats', () async {
      when(() => mockService.getMoodStats(startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
          .thenThrow(Exception('Failed to load stats'));

      await notifier.getMoodStats();

      expect(
        notifier.state,
        isA<_Error>().having(
          (state) => state.message,
          'error message',
          'Exception: Failed to load stats',
        ),
      );
    });
  });

  group('watchMoods', () {
    final mockMoods = [
      Mood(
        id: '1',
        userId: 'user1',
        label: 'Happy',
        emoji: '😊',
        createdAt: DateTime.now(),
      ),
    ];

    test('successfully watches moods', () {
      when(() => mockService.watchMoods()).thenAnswer(
        (_) => Stream.value(mockMoods),
      );

      notifier.watchMoods();

      verify(() => mockService.watchMoods()).called(1);
      expect(notifier.state, MoodState.loaded(moods: mockMoods));
    });

    test('handles error in mood stream', () {
      when(() => mockService.watchMoods()).thenAnswer(
        (_) => Stream.error('Stream error'),
      );

      notifier.watchMoods();

      verify(() => mockService.watchMoods()).called(1);
      expect(
        notifier.state,
        isA<_Error>().having(
          (state) => state.message,
          'error message',
          'Stream error',
        ),
      );
    });
  });
} 