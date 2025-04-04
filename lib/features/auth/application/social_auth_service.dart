import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final socialAuthServiceProvider = Provider((ref) => SocialAuthService());

class SocialAuthService {
  final _supabase = Supabase.instance.client;
  final _googleSignIn = GoogleSignIn();

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) return null;

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken!,
        accessToken: accessToken,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse?> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) return null;

      final accessToken = result.accessToken?.toJson()['token'] as String?;
      if (accessToken == null) return null;

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.facebook,
        idToken: accessToken,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.identityToken == null) return null;

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
} 