import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabaseClient;

  AuthService(this._supabaseClient);

  // Stream to listen for authentication state changes
  Stream<AuthState> get authStateChanges => _supabaseClient.auth.onAuthStateChange;

  // Get the current user session
  Session? get currentSession => _supabaseClient.auth.currentSession;

  // Get the current user
  User? get currentUser => _supabaseClient.auth.currentUser;

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up: $e');
    }
  }

  Future<AuthResponse> signInWithPassword(String email, String password) async {
    try {
      final AuthResponse response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign out: $e');
    }
  }
}