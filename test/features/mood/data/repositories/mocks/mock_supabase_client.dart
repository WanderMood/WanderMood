import 'dart:async';
import 'package:mocktail/mocktail.dart';
import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {
  @override
  SupabaseQueryBuilder from(String table) {
    return MockSupabaseQueryBuilder();
  }

  @override
  PostgrestFilterBuilder<T> rpc<T>(String function, {Map<String, dynamic>? params}) {
    return MockPostgrestFilterBuilder<T>();
  }
}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {
  @override
  PostgrestFilterBuilder<T> select<T>([String columns = '*']) {
    return MockPostgrestFilterBuilder<T>();
  }

  @override
  PostgrestFilterBuilder<T> delete<T>() {
    return MockPostgrestFilterBuilder<T>();
  }

  @override
  PostgrestFilterBuilder<T> upsert<T>(dynamic value, {bool defaultToNull = true}) {
    return MockPostgrestFilterBuilder<T>();
  }

  @override
  RealtimeChannel stream(List<String> primaryKey) {
    return MockRealtimeChannel();
  }
}

class MockPostgrestFilterBuilder<T> extends Mock implements PostgrestFilterBuilder<T> {
  @override
  PostgrestFilterBuilder<T> eq(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<T> gte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<T> lte(String column, dynamic value) => this;

  @override
  PostgrestFilterBuilder<T> order(String column, {bool ascending = true, bool nullsFirst = false}) => this;

  @override
  Future<List<T>> execute() async {
    return super.noSuchMethod(
      Invocation.method(#execute, []),
      returnValue: Future.value([]),
    ) as Future<List<T>>;
  }

  @override
  Future<T?> maybeSingle() async {
    return super.noSuchMethod(
      Invocation.method(#maybeSingle, []),
      returnValue: Future.value(null),
    ) as Future<T?>;
  }
}

class MockRealtimeChannel extends Mock implements RealtimeChannel {
  @override
  Stream<List<Map<String, dynamic>>> on(String event) {
    return Stream.value([]);
  }
}

class MockPostgrestTransformBuilder<T> extends Mock implements PostgrestTransformBuilder<T> {
  final T _data;

  MockPostgrestTransformBuilder(this._data);

  @override
  Future<T> execute() async => _data;

  @override
  Future<U> then<U>(FutureOr<U> Function(T value) onValue, {Function? onError}) async {
    final result = await execute();
    return onValue(result);
  }
}

class MockSupabaseStreamFilterBuilder extends Mock implements SupabaseStreamFilterBuilder {
  @override
  Stream<List<Map<String, dynamic>>> get stream => Stream.value([
    {
      'id': '1',
      'user_id': 'user1',
      'label': 'Happy',
      'emoji': '😊',
      'created_at': DateTime.now().toIso8601String(),
    },
  ]);
} 