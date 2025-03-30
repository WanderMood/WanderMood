import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../application/auth_service.dart';

// Provider voor de huidige gebruiker (state)
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<User?>>((ref) {
  return AuthStateNotifier(ref.read(authServiceProvider));
});

// Provider voor de loading state tijdens authenticatie
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Provider voor eventuele authenticatie foutmeldingen
final authErrorProvider = StateProvider<String?>((ref) => null);

class AuthStateNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;
  
  AuthStateNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }
  
  Future<void> _init() async {
    state = AsyncValue.data(_authService.currentUser);
  }
  
  // Register nieuw account
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    state = const AsyncValue.loading();
    
    final result = await _authService.signUp(
      email: email,
      password: password,
      name: name,
    );
    
    if (result.success && result.user != null) {
      state = AsyncValue.data(result.user);
      onSuccess();
    } else {
      state = AsyncValue.error(result.message ?? 'Unknown error', StackTrace.current);
      onError(result.message ?? 'Unknown error');
    }
  }
  
  // Login bestaand account
  Future<void> signIn({
    required String email,
    required String password,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    state = const AsyncValue.loading();
    
    final result = await _authService.signIn(
      email: email,
      password: password,
    );
    
    if (result.success && result.user != null) {
      state = AsyncValue.data(result.user);
      onSuccess();
    } else {
      state = AsyncValue.error(result.message ?? 'Unknown error', StackTrace.current);
      onError(result.message ?? 'Unknown error');
    }
  }
  
  // Uitloggen
  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }
  
  // Wachtwoord vergeten / reset
  Future<void> resetPassword({
    required String email,
    required Function(String) onError,
    required Function(String) onSuccess,
  }) async {
    final ref = ProviderContainer();
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;
    
    final result = await _authService.resetPassword(email);
    
    ref.read(authLoadingProvider.notifier).state = false;
    
    if (result.success) {
      onSuccess(result.message ?? 'Email verstuurd voor wachtwoord reset');
    } else {
      ref.read(authErrorProvider.notifier).state = result.message;
      onError(result.message ?? 'Wachtwoord reset mislukt');
    }
  }
} 