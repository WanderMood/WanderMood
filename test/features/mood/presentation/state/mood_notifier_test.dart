import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wandermood/features/mood/application/mood_service.dart';
import 'package:wandermood/features/mood/domain/models/mood.dart';
import 'package:wandermood/features/mood/presentation/state/mood_notifier.dart';
import 'package:wandermood/features/mood/presentation/state/mood_state.dart';

class MockMoodService extends Mock implements MoodService {}

void main() {
  late MockMoodService mockService;
  late MoodNotifier notifier;

  setUp(() {
    mockService = MockMoodService();
    notifier = MoodNotifier(mockService);
  });

  test('initial state should be MoodState.initial', () {
    expect(notifier.state, const MoodState.initial());
  });

  group('getMoods', () {
    final mockMoods = [
      Mood(
        id: '1',
        userId: 'user1',
        mood: 'Happy',
        note: 'Great day!',
        createdAt: DateTime.now(),
      ),
      Mood(
        id: '2',
        userId: 'user1',
        mood: 'Sad',
        note: 'Not so great',
        createdAt: DateTime.now(),
      ),
    ];

    test('emits loading and loaded states when successful', () async {
      when(() => mockService.getMoods(startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
          .thenAnswer((_) async => mockMoods);

      await notifier.getMoods();

      verifyInOrder([
        () => notifier.state = const MoodState.loading(),
        () => notifier.state = MoodState.loaded(moods: mockMoods),
      ]);
    });

    test('emits loading and error states when unsuccessful', () async {
      when(() => mockService.getMoods(startDate: any(named: 'startDate'), endDate: any(named: 'endDate')))
          .thenThrow(Exception('Failed to get moods'));

      await notifier.getMoods();

      verifyInOrder([
        () => notifier.state = const MoodState.loading(),
        () => notifier.state = const MoodState.error('Exception: Failed to get moods'),
      ]);
    });
  });

  group('getMoodStats', () {
    final mockStats = {'Happy': 5, 'Sad': 3};

    test('emits loading and loaded states when successful', () async {
      when(() => mockService.getMoodStats()).thenAnswer((_) async => mockStats);

      await notifier.getMoodStats();

      verifyInOrder([
        () => notifier.state = const MoodState.loading(),
        () => notifier.state = MoodState.loaded(stats: mockStats),
      ]);
    });

    test('emits loading and error states when unsuccessful', () async {
      when(() => mockService.getMoodStats()).thenThrow(Exception('Failed to get stats'));

      await notifier.getMoodStats();

      verifyInOrder([
        () => notifier.state = const MoodState.loading(),
        () => notifier.state = const MoodState.error('Exception: Failed to get stats'),
      ]);
    });
  });

  group('watchMoods', () {
    final mockMoods = [
      Mood(
        id: '1',
        userId: 'user1',
        mood: 'Happy',
        note: 'Great day!',
        createdAt: DateTime.now(),
      ),
    ];

    test('updates state when new moods are received', () {
      when(() => mockService.watchMoods()).thenAnswer(
        (_) => Stream.value(mockMoods),
      );

      notifier.watchMoods();

      verify(() => notifier.state = MoodState.loaded(moods: mockMoods)).called(1);
    });

    test('emits error state when stream has error', () {
      when(() => mockService.watchMoods()).thenAnswer(
        (_) => Stream.error(Exception('Stream error')),
      );

      notifier.watchMoods();

      verify(() => notifier.state = const MoodState.error('Exception: Stream error')).called(1);
    });
  });
} 