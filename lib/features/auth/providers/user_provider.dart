import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Current user provider
final userProvider = StreamProvider<User?>((ref) {
  final client = Supabase.instance.client;
  return client.auth.onAuthStateChange.map((data) => data.session?.user);
});

// User data provider (including metadata)
final userDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(userProvider).valueOrNull;
  if (user == null) return null;
  
  final client = Supabase.instance.client;
  try {
    // Get user profile data from Supabase
    final response = await client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    
    return {
      'id': user.id,
      'email': user.email,
      'name': response['full_name'] ?? user.userMetadata?['name'] ?? 'User',
      'avatarUrl': response['avatar_url'],
      'metadata': user.userMetadata ?? {},
    };
  } catch (e) {
    // If no profile exists yet, return basic user data
    return {
      'id': user.id,
      'email': user.email,
      'name': user.userMetadata?['name'] ?? 'User',
      'metadata': user.userMetadata ?? {},
    };
  }
});

// Initialize user profile on signup/login
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = Supabase.instance.client;
  
  // Listen for auth state changes
  return client.auth.onAuthStateChange.map((event) {
    // When a user signs up or signs in, create/update their profile
    if (event.event == AuthChangeEvent.signedIn) {
      _initializeUserProfile(client, event.session!.user);
    }
    return event;
  });
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