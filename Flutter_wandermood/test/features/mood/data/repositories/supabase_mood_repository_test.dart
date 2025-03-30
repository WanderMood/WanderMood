import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wandermood/features/mood/data/repositories/supabase_mood_repository.dart';
import 'package:wandermood/features/mood/domain/models/mood.dart';
import 'package:wandermood/features/mood/domain/models/activity.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {
  @override
  SupabaseQueryBuilder from(String table) => MockSupabaseQueryBuilder();
}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {
  @override
  PostgrestFilterBuilder select([String columns = '*']) => MockPostgrestFilterBuilder();

  @override
  PostgrestFilterBuilder insert(Map<String, dynamic> json, {bool defaultToNull = true}) => MockPostgrestFilterBuilder();

  @override
  PostgrestFilterBuilder update(Map<String, dynamic> json) => MockPostgrestFilterBuilder();

  @override
  PostgrestFilterBuilder delete() => MockPostgrestFilterBuilder();

  @override
  SupabaseStreamBuilder stream({required List<String> primaryKey}) => MockSupabaseStreamBuilder();
}

class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {
  @override
  PostgrestFilterBuilder eq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder order(String column, {bool ascending = true}) => this;

  @override
  PostgrestFilterBuilder limit(int limit) => this;

  @override
  PostgrestFilterBuilder gte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder lte(String column, dynamic value) => this;
}

class MockSupabaseStreamBuilder extends Mock implements SupabaseStreamBuilder {}

void main() {
  late MockSupabaseClient mockClient;
  late SupabaseMoodRepository repository;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    repository = SupabaseMoodRepository(mockClient);

    when(() => mockClient.from(any())).thenReturn(mockQueryBuilder);
    when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
    when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);
    when(() => mockQueryBuilder.update(any())).thenReturn(mockFilterBuilder);
    when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
  });

  group('getMoods', () {
    final now = DateTime.now();
    final mockMoodData = [
      {
        'id': '1',
        'user_id': 'user1',
        'label': 'Happy',
        'emoji': '😊',
        'created_at': now.toIso8601String(),
        'note': 'Great day!',
        'energy_level': 8.0,
        'activities': ['1', '2'],
        'is_shared': false
      },
      {
        'id': '2',
        'user_id': 'user1',
        'label': 'Sad',
        'emoji': '😢',
        'created_at': now.toIso8601String(),
        'note': 'Not so great',
        'energy_level': 3.0,
        'activities': [],
        'is_shared': true
      }
    ];

    test('returns list of moods', () async {
      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => mockMoodData);

      final result = await repository.getMoods('user1');

      expect(result.length, 2);
      expect(result[0].id, '1');
      expect(result[0].label, 'Happy');
      expect(result[0].emoji, '😊');
      expect(result[0].energyLevel, 8.0);
      expect(result[0].activities, ['1', '2']);
      expect(result[0].isShared, false);
      
      expect(result[1].id, '2');
      expect(result[1].label, 'Sad');
      expect(result[1].note, 'Not so great');
      expect(result[1].energyLevel, 3.0);
      expect(result[1].isShared, true);
    });

    test('returns empty list when no moods exist', () async {
      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => []);

      final result = await repository.getMoods('user1');

      expect(result, isEmpty);
    });

    test('handles invalid mood data gracefully', () async {
      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => [
        {'id': '1', 'invalid_field': 'value'} // Invalid mood data
      ]);

      expect(() => repository.getMoods('user1'), throwsA(isA<Exception>()));
    });

    test('filters moods by date range', () async {
      final startDate = DateTime.now().subtract(const Duration(days: 7));
      final endDate = DateTime.now();

      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => mockMoodData);

      await repository.getMoods('user1', startDate: startDate, endDate: endDate);

      verify(() => mockFilterBuilder.gte('created_at', startDate.toIso8601String())).called(1);
      verify(() => mockFilterBuilder.lte('created_at', endDate.toIso8601String())).called(1);
    });
  });

  group('saveMood', () {
    final now = DateTime.now();
    
    test('saves new mood successfully', () async {
      final mood = Mood(
        id: '1',
        userId: 'user1',
        label: 'Happy',
        emoji: '😊',
        createdAt: now,
        note: 'Great day!',
        energyLevel: 8.0,
        activities: ['1', '2'],
        isShared: false
      );

      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => [
        {
          'id': '1',
          'user_id': 'user1',
          'label': 'Happy',
          'emoji': '😊',
          'created_at': now.toIso8601String(),
          'note': 'Great day!',
          'energy_level': 8.0,
          'activities': ['1', '2'],
          'is_shared': false
        }
      ]);

      final result = await repository.saveMood(mood);

      expect(result.id, '1');
      expect(result.label, 'Happy');
      expect(result.emoji, '😊');
      expect(result.energyLevel, 8.0);
      expect(result.activities, ['1', '2']);
      expect(result.isShared, false);
    });

    test('updates existing mood successfully', () async {
      final mood = Mood(
        id: '1',
        userId: 'user1',
        label: 'Very Happy',
        emoji: '😊',
        createdAt: now,
        note: 'Updated note',
        energyLevel: 9.0,
        activities: ['1', '2', '3'],
        isShared: true
      );

      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => [
        {
          'id': '1',
          'user_id': 'user1',
          'label': 'Very Happy',
          'emoji': '😊',
          'created_at': now.toIso8601String(),
          'note': 'Updated note',
          'energy_level': 9.0,
          'activities': ['1', '2', '3'],
          'is_shared': true
        }
      ]);

      final result = await repository.saveMood(mood);

      expect(result.label, 'Very Happy');
      expect(result.note, 'Updated note');
      expect(result.energyLevel, 9.0);
      expect(result.activities, ['1', '2', '3']);
      expect(result.isShared, true);
    });

    test('handles save failure gracefully', () async {
      final mood = Mood(
        id: '1',
        userId: 'user1',
        label: 'Happy',
        emoji: '😊',
        createdAt: now,
        note: 'Great day!',
        energyLevel: 8.0,
        activities: ['1', '2'],
        isShared: false
      );

      when(() => mockFilterBuilder.execute()).thenThrow(Exception('Failed to save mood'));

      expect(() => repository.saveMood(mood), throwsA(isA<Exception>()));
    });
  });

  group('deleteMood', () {
    test('deletes mood successfully', () async {
      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => []);

      await repository.deleteMood('1');

      verify(() => mockQueryBuilder.delete()).called(1);
      verify(() => mockFilterBuilder.eq('id', '1')).called(1);
    });

    test('handles delete failure gracefully', () async {
      when(() => mockFilterBuilder.execute()).thenThrow(Exception('Failed to delete mood'));

      expect(() => repository.deleteMood('1'), throwsA(isA<Exception>()));
    });

    test('handles non-existent mood deletion', () async {
      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => []);

      await repository.deleteMood('non-existent-id');

      verify(() => mockQueryBuilder.delete()).called(1);
      verify(() => mockFilterBuilder.eq('id', 'non-existent-id')).called(1);
    });
  });

  group('getActivities', () {
    final mockActivitiesData = [
      {
        'id': '1',
        'name': 'Running',
        'emoji': '🏃‍♂️',
        'category': 'Exercise',
        'description': 'Morning run',
        'is_custom': true,
        'last_used': DateTime.now().toIso8601String()
      },
      {
        'id': '2',
        'name': 'Reading',
        'emoji': '📚',
        'category': 'Leisure',
        'description': 'Reading a book',
        'is_custom': false,
        'last_used': null
      }
    ];

    test('returns list of activities', () async {
      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => mockActivitiesData);

      final result = await repository.getActivities('user1');

      expect(result.length, 2);
      expect(result[0].id, '1');
      expect(result[0].name, 'Running');
      expect(result[0].emoji, '🏃‍♂️');
      expect(result[0].category, 'Exercise');
      expect(result[0].description, 'Morning run');
      expect(result[0].isCustom, true);
      
      expect(result[1].id, '2');
      expect(result[1].name, 'Reading');
      expect(result[1].category, 'Leisure');
      expect(result[1].isCustom, false);
      expect(result[1].lastUsed, null);
    });

    test('returns empty list when no activities exist', () async {
      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => []);

      final result = await repository.getActivities('user1');

      expect(result, isEmpty);
    });

    test('handles invalid activity data gracefully', () async {
      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => [
        {'id': '1', 'invalid_field': 'value'} // Invalid activity data
      ]);

      expect(() => repository.getActivities('user1'), throwsA(isA<Exception>()));
    });
  });

  group('createActivity', () {
    test('creates activity successfully', () async {
      final activity = Activity(
        id: '1',
        name: 'Running',
        emoji: '🏃‍♂️',
      );

      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => [activity.toJson()]);

      final result = await repository.createActivity(activity);

      expect(result.id, '1');
      expect(result.name, 'Running');
      expect(result.emoji, '🏃‍♂️');
    });
  });

  group('updateActivity', () {
    test('updates activity successfully', () async {
      final activity = Activity(
        id: '1',
        name: 'Running',
        emoji: '🏃‍♂️',
      );

      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => [activity.toJson()]);

      await repository.updateActivity(activity);

      verify(() => mockQueryBuilder.update(any())).called(1);
      verify(() => mockFilterBuilder.eq('id', '1')).called(1);
    });
  });

  group('deleteActivity', () {
    test('deletes activity successfully', () async {
      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => []);

      await repository.deleteActivity('1');

      verify(() => mockQueryBuilder.delete()).called(1);
      verify(() => mockFilterBuilder.eq('id', '1')).called(1);
    });
  });

  group('getMoodStats', () {
    test('returns mood statistics', () async {
      final mockStats = {
        'total_moods': 10,
        'average_energy': 3.5,
        'most_common_mood': 'Happy',
        'mood_distribution': {
          'Happy': 5,
          'Sad': 3,
          'Neutral': 2
        }
      };

      when(() => mockClient.rpc('get_mood_stats', params: any(named: 'params')))
          .thenAnswer((_) async => mockStats);

      final result = await repository.getMoodStats('user1');

      expect(result['total_moods'], 10);
      expect(result['average_energy'], 3.5);
      expect(result['most_common_mood'], 'Happy');
      expect(result['mood_distribution'], {
        'Happy': 5,
        'Sad': 3,
        'Neutral': 2
      });
    });

    test('handles empty stats gracefully', () async {
      when(() => mockClient.rpc('get_mood_stats', params: any(named: 'params')))
          .thenAnswer((_) async => {
            'total_moods': 0,
            'average_energy': 0.0,
            'most_common_mood': null,
            'mood_distribution': {}
          });

      final result = await repository.getMoodStats('user1');

      expect(result['total_moods'], 0);
      expect(result['average_energy'], 0.0);
      expect(result['most_common_mood'], null);
      expect(result['mood_distribution'], isEmpty);
    });

    test('handles stats calculation failure', () async {
      when(() => mockClient.rpc('get_mood_stats', params: any(named: 'params')))
          .thenThrow(Exception('Failed to calculate stats'));

      expect(() => repository.getMoodStats('user1'), throwsA(isA<Exception>()));
    });
  });

  group('watchMoods', () {
    final now = DateTime.now();
    final mockMoodData = [
      {
        'id': '1',
        'user_id': 'user1',
        'label': 'Happy',
        'emoji': '😊',
        'created_at': now.toIso8601String(),
        'note': 'Great day!',
        'energy_level': 8.0,
        'activities': ['1', '2'],
        'is_shared': false
      }
    ];

    test('returns stream of moods', () async {
      when(() => mockQueryBuilder.stream(primaryKey: any(named: 'primaryKey')))
          .thenAnswer((_) => MockSupabaseStreamBuilder());
      
      when(() => mockFilterBuilder.execute()).thenAnswer((_) async => mockMoodData);

      final stream = repository.watchMoods('user1');
      expect(stream, isA<Stream<List<Mood>>>());

      final result = await stream.first;
      expect(result[0].id, '1');
      expect(result[0].label, 'Happy');
      expect(result[0].emoji, '😊');
      expect(result[0].energyLevel, 8.0);
      expect(result[0].activities, ['1', '2']);
      expect(result[0].isShared, false);
    });

    test('handles stream errors gracefully', () async {
      when(() => mockQueryBuilder.stream(primaryKey: any(named: 'primaryKey')))
          .thenAnswer((_) => MockSupabaseStreamBuilder());
      
      when(() => mockFilterBuilder.execute())
          .thenThrow(Exception('Stream error'));

      final stream = repository.watchMoods('user1');
      expect(() async => await stream.first, throwsA(isA<Exception>()));
    });

    test('handles empty stream data', () async {
      when(() => mockQueryBuilder.stream(primaryKey: any(named: 'primaryKey')))
          .thenAnswer((_) => MockSupabaseStreamBuilder());
      
      when(() => mockFilterBuilder.execute())
          .thenAnswer((_) async => []);

      final stream = repository.watchMoods('user1');
      final result = await stream.first;
      expect(result, isEmpty);
    });
  });
} 