import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';

enum AuthStatus { loading, unauthenticated, authenticated, onboardingRequired }

class AuthState {
  final AuthStatus status;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.loading,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    Map<String, dynamic>? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _onboardingKey = 'has_completed_onboarding';

  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    // Listen for Supabase auth state changes (handles OAuth callbacks)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      print('Auth State Changed: ${data.event}');
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        // Sync Supabase session tokens to our secure storage
        await _authService.syncSupabaseSession();
        await _checkAuthStatus();
      }
    });

    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    final isLoggedIn = await _authService.tryAutoLogin();
    if (!isLoggedIn) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final user = await _authService.getMe();
      final hasOnboarded = await _storage.read(key: _onboardingKey);

      if (hasOnboarded == 'true') {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = AuthState(status: AuthStatus.onboardingRequired, user: user);
      }
    } catch (e) {
      print('Check Auth Status Failed: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Backend connection failed. Please check if your computer is on the same Wi-Fi and the IP in .env is correct.\nError: $e',
      );
    }
  }

  // ── Login ──────────────────────────────────────────────────────────

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authService.login(email: email, password: password);
      await _checkAuthStatus();
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Signup ─────────────────────────────────────────────────────────

  Future<void> signup({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authService.signup(email: email, password: password);
      // After signup, user needs to confirm email — show message
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Account created! Check your email to confirm, then log in.',
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Google Sign In ─────────────────────────────────────────────────

  Future<void> loginWithGoogle() async {
    print('Starting Google Sign In Flow...');
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await _authService.loginWithGoogle();
      // Auth state listener will handle the rest
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Onboarding ─────────────────────────────────────────────────────

  Future<void> completeOnboarding() async {
    await _storage.write(key: _onboardingKey, value: 'true');
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  // ── Logout ─────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authService.logout();
    await _storage.delete(key: _onboardingKey);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
