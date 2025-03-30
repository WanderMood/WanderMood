import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wandermood/features/auth/application/auth_service.dart';

// Provider voor de huidige gebruiker (state)
final authStateProvider = StateNotifierProvider<AuthStateNotifier, User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});

// Provider voor de loading state tijdens authenticatie
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Provider voor eventuele authenticatie foutmeldingen
final authErrorProvider = StateProvider<String?>((ref) => null);

class AuthStateNotifier extends StateNotifier<User?> {
  final AuthService _authService;
  
  AuthStateNotifier(this._authService) : super(_authService.currentUser) {
    // Luisteren naar auth state changes voor real-time updates
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn) {
        state = event.session?.user;
      } else if (event.event == AuthChangeEvent.signedOut) {
        state = null;
      }
    });
  }
  
  // Register nieuw account
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    final ref = ProviderContainer();
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;
    
    final result = await _authService.signUp(
      email: email,
      password: password,
      name: name,
    );
    
    ref.read(authLoadingProvider.notifier).state = false;
    
    if (result.success) {
      state = result.user;
      onSuccess();
    } else {
      ref.read(authErrorProvider.notifier).state = result.message;
      onError(result.message ?? 'Registratie mislukt');
    }
  }
  
  // Login bestaand account
  Future<void> signIn({
    required String email,
    required String password,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    final ref = ProviderContainer();
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;
    
    final result = await _authService.signIn(
      email: email,
      password: password,
    );
    
    ref.read(authLoadingProvider.notifier).state = false;
    
    if (result.success) {
      state = result.user;
      onSuccess();
    } else {
      ref.read(authErrorProvider.notifier).state = result.message;
      onError(result.message ?? 'Inloggen mislukt');
    }
  }
  
  // Uitloggen
  Future<void> signOut() async {
    await _authService.signOut();
    state = null;
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