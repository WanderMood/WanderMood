import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wandermood/features/profile/domain/models/profile_model.dart';
import 'package:wandermood/features/auth/providers/auth_provider.dart';
import 'dart:io';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, Profile?>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends AsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() async {
    // Watch auth state changes
    final authState = ref.watch(authStateChangesProvider);
    return authState.when(
      data: (_) => _fetchProfile(),
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Future<Profile?> _fetchProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    if (user == null) return null;

    try {
      // First try to fetch the profile
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        return Profile.fromSupabase(response);
      }

      // If no profile exists, create one with default values
      final defaultProfile = {
        'id': user.id,
        'email': user.email,
        'username': 'user_${user.id.substring(0, 8)}',
        'full_name': user.userMetadata?['name'] ?? 'New User',
        'bio': 'Hello! I\'m new to WanderMood 👋',
        'mood_streak': 0,
        'followers_count': 0,
        'following_count': 0,
        'is_public': true,
        'notification_preferences': {
          'push': true,
          'email': true
        },
        'theme_preference': 'system',
        'language_preference': 'en',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String()
      };

      final result = await supabase
          .from('profiles')
          .upsert(defaultProfile)
          .select()
          .single();

      return Profile.fromSupabase(result);
    } catch (e) {
      print('Error in profile provider: $e');
      return null;
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? imageUrl,
    DateTime? dateOfBirth,
    String? bio,
    String? username,
    String? favoriteMood,
    bool? isPublic,
    Map<String, bool>? notificationPreferences,
    String? themePreference,
    String? languagePreference,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    if (user == null) throw Exception('User not authenticated');

    state = const AsyncValue.loading();
    
    try {
      final currentProfile = await _fetchProfile();
      if (currentProfile == null) throw Exception('Profile not found');

      final updatedProfile = currentProfile.copyWith(
        fullName: fullName ?? currentProfile.fullName,
        imageUrl: imageUrl ?? currentProfile.imageUrl,
        dateOfBirth: dateOfBirth ?? currentProfile.dateOfBirth,
        bio: bio ?? currentProfile.bio,
        username: username ?? currentProfile.username,
        favoriteMood: favoriteMood ?? currentProfile.favoriteMood,
        isPublic: isPublic ?? currentProfile.isPublic,
        notificationPreferences: notificationPreferences ?? currentProfile.notificationPreferences,
        themePreference: themePreference ?? currentProfile.themePreference,
        languagePreference: languagePreference ?? currentProfile.languagePreference,
        updatedAt: DateTime.now(),
      );

      await supabase
          .from('profiles')
          .update(updatedProfile.toSupabase())
          .eq('id', user.id);

      state = AsyncValue.data(updatedProfile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<String?> uploadProfileImage(String filePath) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    if (user == null) throw Exception('User not authenticated');

    try {
      final file = File(filePath);
      final fileName = 'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await supabase.storage
          .from('profile_images')
          .upload(fileName, file);

      final imageUrl = supabase.storage
          .from('profile_images')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
} 