import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthResult {
  final bool success;
  final String? message;
  final User? user;

  AuthResult({
    required this.success,
    this.message,
    this.user,
  });

  factory AuthResult.success(User user) {
    return AuthResult(
      success: true,
      user: user,
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult(
      success: false,
      message: message,
    );
  }
}

class AuthService {
  final _supabase = Supabase.instance.client;

  static const demoEmail = 'demo@wandermood.app';
  static const demoPassword = 'demo123';

  // Huidige gebruiker ophalen
  User? get currentUser => _supabase.auth.currentUser;
  
  // Controleren of een gebruiker is ingelogd
  bool get isUserLoggedIn => _supabase.auth.currentUser != null;

  // Demo account aanmaken als het nog niet bestaat
  Future<void> ensureDemoAccount() async {
    try {
      debugPrint('Checking if demo account exists...');
      // Probeer eerst in te loggen met demo account
      final signInResult = await signIn(
        email: demoEmail,
        password: demoPassword,
      );

      // Als inloggen mislukt, maak het account aan
      if (!signInResult.success) {
        debugPrint('Demo account does not exist, creating...');
        await signUp(
          email: demoEmail,
          password: demoPassword,
          name: 'Demo User',
        );
        debugPrint('Demo account created successfully');
      } else {
        debugPrint('Demo account already exists');
      }

      // Log uit zodat de gebruiker zelf kan inloggen
      await signOut();
      debugPrint('Signed out after demo account check');
    } catch (e) {
      debugPrint('Error ensuring demo account: $e');
    }
  }

  // Registreren met email en wachtwoord
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );
      
      if (response.user != null) {
        // Als we hier zijn, is registratie succesvol
        return AuthResult.success(response.user!);
      } else {
        // Dit hoort niet te gebeuren bij een succesvolle registratie
        return AuthResult.error('Registratie mislukt, probeer het opnieuw');
      }
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.error('Er is een onverwachte fout opgetreden: $e');
    }
  }

  // Inloggen met email en wachtwoord
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      for (int i = 0; i < 3; i++) {
        try {
          debugPrint('Attempting to sign in with email: $email (attempt ${i + 1})');
          await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          ).timeout(const Duration(seconds: 10));
          debugPrint('Sign in successful');
          return AuthResult.success(currentUser!);
        } on TimeoutException {
          debugPrint('Sign in attempt ${i + 1} timed out');
          if (i == 2) rethrow;
          await Future.delayed(const Duration(seconds: 2));
        } on AuthException catch (e) {
          debugPrint('AuthException during sign in: $e');
          if (e.message.contains('Failed host lookup')) {
            if (i == 2) rethrow;
            await Future.delayed(const Duration(seconds: 2));
          } else {
            rethrow;
          }
        }
      }
    } on Exception catch (e) {
      debugPrint('Exception during sign in: $e');
      rethrow;
    }
    return AuthResult.error('Inloggen mislukt, probeer het opnieuw');
  }

  // Uitloggen
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Wachtwoord vergeten / reset
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.wandermood://reset-callback/',
      );
      
      return AuthResult(
        success: true,
        message: 'Wachtwoord reset link is verzonden naar $email',
      );
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.error('Er is een onverwachte fout opgetreden: $e');
    }
  }

  // Helper methode om auth exceptions te verwerken
  AuthResult _handleAuthException(AuthException e) {
    // Vertaal de foutmeldingen naar gebruikersvriendelijke berichten in het Nederlands
    switch (e.message) {
      case 'Invalid login credentials':
        return AuthResult.error('Ongeldige inloggegevens');
      case 'Email not confirmed':
        return AuthResult.error('Email is nog niet bevestigd');
      case 'User already registered':
        return AuthResult.error('Dit email adres is al geregistreerd');
      case 'Password should be at least 6 characters':
        return AuthResult.error('Wachtwoord moet minimaal 6 tekens bevatten');
      default:
        return AuthResult.error(e.message);
    }
  }
} 