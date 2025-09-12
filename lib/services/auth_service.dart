// lib/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final supabase.SupabaseClient _supabaseClient;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: dotenv.env['GOOGLE_SIGN_IN_CLIENT_ID'],
  );

  AuthService(this._supabaseClient);

  // Stream to listen for authentication state changes
  Stream<supabase.AuthState> get authStateChanges => _supabaseClient.auth.onAuthStateChange;

  // Get the current user session
  supabase.Session? get currentSession => _supabaseClient.auth.currentSession;

  // Get the current user
  supabase.User? get currentUser => _supabaseClient.auth.currentUser;

  Future<supabase.AuthResponse> signUp(String email, String password) async {
    try {
      final supabase.AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } on supabase.AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up: $e');
    }
  }

  Future<supabase.AuthResponse> signInWithPassword(String email, String password) async {
    try {
      final supabase.AuthResponse response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on supabase.AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in: $e');
    }
  }

  Future<supabase.AuthResponse?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        throw const supabase.AuthException('Google ID token or access token is null.');
      }

      final supabase.AuthResponse response = await _supabaseClient.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      return response;

    } on supabase.AuthException catch (e) {
      print('AuthException during Google sign-in: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('An unexpected error occurred during Google sign-in: $e');
      throw Exception('An unexpected error occurred during Google sign-in.');
    }
  }
  
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } on supabase.AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign out: $e');
    }
  }
}