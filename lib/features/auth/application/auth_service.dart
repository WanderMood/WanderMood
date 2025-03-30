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

  // Huidige gebruiker ophalen
  User? get currentUser => _supabase.auth.currentUser;
  
  // Controleren of een gebruiker is ingelogd
  bool get isUserLoggedIn => _supabase.auth.currentUser != null;

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
        return AuthResult.success(response.user!);
      } else {
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
      debugPrint('Attempting to sign in with email: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        debugPrint('Sign in successful');
        return AuthResult.success(response.user!);
      } else {
        return AuthResult.error('Inloggen mislukt, probeer het opnieuw');
      }
    } on AuthException catch (e) {
      debugPrint('AuthException during sign in: $e');
      return _handleAuthException(e);
    } catch (e) {
      debugPrint('Exception during sign in: $e');
      return AuthResult.error('Er is een onverwachte fout opgetreden: $e');
    }
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