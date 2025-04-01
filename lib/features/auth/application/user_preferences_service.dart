import 'package:async/async.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wandermood/features/auth/domain/models/user_preferences.dart';
import 'package:wandermood/core/config/supabase_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_preferences_service.g.dart';

@riverpod
class UserPreferencesService extends _$UserPreferencesService {
  late final SupabaseClient _supabase;

  @override
  FutureOr<UserPreferences?> build() async {
    _supabase = Supabase.instance.client;
    return null;
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    state = const AsyncLoading();
    try {
      final updatedPreferences = await _supabase
          .from('user_preferences')
          .upsert(preferences.toJson())
          .select()
          .single();
      
      state = AsyncData(UserPreferences.fromJson(updatedPreferences));
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> completeOnboarding() async {
    final currentPrefs = state.value;
    if (currentPrefs != null) {
      await updatePreferences(currentPrefs.copyWith(isOnboardingComplete: true));
    }
  }
} 