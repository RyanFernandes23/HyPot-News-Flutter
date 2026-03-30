import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider((ref) => AuthService());

/// Handles all authentication flows: email/password, Google OAuth, token management.
class AuthService {
  final ApiService _api = ApiService();
  final SupabaseClient _supabase = Supabase.instance.client;

  // ── Email / Password ───────────────────────────────────────────────

  /// Register a new user. Returns success message or throws.
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post('/auth/signup', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  /// Sign in with email/password. Stores tokens on success.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      await _api.saveTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
      );
      return data;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  // ── Google OAuth via Supabase ──────────────────────────────────────

  /// Opens native Google Sign-in flow. On success, signs in to Supabase
  /// using the ID Token.
  Future<bool> loginWithGoogle({bool forceAccountPicker = false}) async {
    try {
      final webClientId = dotenv.env['GOOGLE_CLIENT_ID_WEB'];
      
      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      if (forceAccountPicker) {
        try {
          await googleSignIn.signOut();
        } catch (_) {}
      }

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign In Cancelled by user');
        return false;
      }

      print('Google User Found: ${googleUser.email}');
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        print('Error: No ID Token found for Google account');
        throw 'No ID Token found.';
      }

      print('Signing into Supabase with ID Token...');
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      print('Supabase Sign In Success. Syncing session...');
      // Save tokens locally for the backend
      await syncSupabaseSession();
      
      return true;
    } catch (e) {
      throw 'Google sign-in failed: $e';
    }
  }

  /// Called after Supabase OAuth completes to sync session tokens.
  Future<void> syncSupabaseSession() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _api.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
      );
    }
  }

  // ── Session Management ─────────────────────────────────────────────

  /// Attempt to restore a previous session. Returns true if valid tokens exist.
  Future<bool> tryAutoLogin() async {
    final hasTokens = await _api.hasTokens();
    if (!hasTokens) return false;

    try {
      // Verify the token is still valid by calling /auth/me
      await getMe();
      return true;
    } catch (_) {
      // Token invalid — try refresh
      final refreshToken = await _api.getRefreshToken();
      if (refreshToken == null) return false;

      try {
        final response = await _api.dio.post('/auth/refresh', data: {
          'refresh_token': refreshToken,
        });

        if (response.statusCode == 200) {
          await _api.saveTokens(
            accessToken: response.data['access_token'],
            refreshToken: response.data['refresh_token'],
          );
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  /// Get current user profile.
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _api.dio.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  /// Sign out: clears server session and local tokens.
  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } catch (_) {
      // Logout from server may fail if token expired — that's fine
    }
    await _api.clearTokens();
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
  }

  /// Update user profile (name/avatar).
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final response = await _api.dio.put('/auth/profile', data: {
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      });
      return response.data;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  /// Sync FCM token to backend for push notifications.
  Future<void> updateFcmToken(String token) async {
    try {
      await _api.dio.put('/auth/fcm-token', data: {'fcm_token': token});
    } on DioException catch (e) {
      print('Failed to sync FCM token: ${e.response?.statusCode} - ${e.message}');
      // Don't throw here, as this is a background sync and we don't want to break the app.
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────

  String _extractError(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['detail']?.toString() ?? 'An error occurred';
    }
    return e.message ?? 'Network error';
  }
}
