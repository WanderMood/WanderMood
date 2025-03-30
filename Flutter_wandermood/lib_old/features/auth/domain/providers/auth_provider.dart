import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<User?>>((ref) {
  return AuthStateNotifier(ref.watch(authServiceProvider));
});

class AuthStateNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AsyncValue.loading()) {
    _authService.authStateChanges.listen((event) {
      state = AsyncValue.data(event.session?.user);
    });
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signIn(email, password);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signUp(email, password);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
} 