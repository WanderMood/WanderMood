import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static const String demoEmail = 'demo@wandermood.com';
  static const String demoPassword = 'demo123';

  final SupabaseClient _client = Supabase.instance.client;

  Future<void> ensureDemoAccount() async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: demoEmail,
        password: demoPassword,
      );
      
      if (response.user == null) {
        await _client.auth.signUp(
          email: demoEmail,
          password: demoPassword,
        );
      }
    } catch (e) {
      // Ignore errors as the account might already exist
    }
  }

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
} 