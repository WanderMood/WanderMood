import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPreferences {
  final String? mood;
  final List<String> interests;
  final String? location;

  const UserPreferences({
    this.mood,
    this.interests = const [],
    this.location,
  });

  UserPreferences copyWith({
    String? mood,
    List<String>? interests,
    String? location,
  }) {
    return UserPreferences(
      mood: mood ?? this.mood,
      interests: interests ?? this.interests,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'interests': interests,
      'location': location,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      mood: json['mood'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? [],
      location: json['location'] as String?,
    );
  }

  bool get isComplete => mood != null && interests.isNotEmpty && location != null;
}

class PreferencesNotifier extends StateNotifier<UserPreferences> {
  final SupabaseClient _supabase;

  PreferencesNotifier(this._supabase) : super(const UserPreferences());

  Future<void> loadPreferences() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('user_preferences')
          .select()
          .eq('user_id', user.id)
          .single();

      if (response != null) {
        state = UserPreferences.fromJson(response);
      }
    } catch (e) {
      // Handle error or create new preferences
      print('Error loading preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_preferences').upsert({
        'user_id': user.id,
        ...state.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  void setMood(String mood) {
    state = state.copyWith(mood: mood);
    _savePreferences();
  }

  void setInterests(List<String> interests) {
    state = state.copyWith(interests: interests);
    _savePreferences();
  }

  void setLocation(String location) {
    state = state.copyWith(location: location);
    _savePreferences();
  }

  void clearPreferences() {
    state = const UserPreferences();
    _savePreferences();
  }
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, UserPreferences>((ref) {
  final supabase = Supabase.instance.client;
  return PreferencesNotifier(supabase);
}); 