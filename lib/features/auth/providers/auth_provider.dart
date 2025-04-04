import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Initialize user profile on signup/login
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = Supabase.instance.client;
  
  // Listen for auth state changes
  return client.auth.onAuthStateChange;
});

// Helper to initialize user profile
Future<void> _initializeUserProfile(SupabaseClient client, User user) async {
  try {
    // Check if profile exists
    final existing = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    
    // If profile doesn't exist, create it
    if (existing == null) {
      await client.from('profiles').insert({
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
        'achievements': [],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  } catch (e) {
    print('Error initializing user profile: $e');
    // Try to create profile again with minimal fields if full creation fails
    try {
      await client.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating minimal profile: $e');
    }
  }
} 