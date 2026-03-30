import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../features/news/providers/bookmark_sync_provider.dart';

enum AuthStatus { loading, unauthenticated, authenticated, onboardingRequired }

class AuthState {
  final AuthStatus status;
  final Map<String, dynamic>? user;
  final String? errorMessage;
  final bool hasSeenBriefing;

  const AuthState({
    this.status = AuthStatus.loading,
    this.user,
    this.errorMessage,
    this.hasSeenBriefing = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    Map<String, dynamic>? user,
    String? errorMessage,
    bool clearError = false,
    bool? hasSeenBriefing,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasSeenBriefing: hasSeenBriefing ?? this.hasSeenBriefing,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _onboardingKey = 'has_completed_onboarding';
  static const _briefingKey = 'has_seen_daily_briefing';

  AuthNotifier(this._ref) : super(const AuthState()) {
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
      final hasSeenBriefing = await _storage.read(key: _briefingKey) == 'true';
      final storedInterests = user['interests'];
      final hasSavedInterests =
          storedInterests is List && storedInterests.isNotEmpty;
      final onboardingComplete =
          hasSavedInterests || hasOnboarded == 'true';

      if (onboardingComplete) {
        if (hasSavedInterests && hasOnboarded != 'true') {
          await _storage.write(key: _onboardingKey, value: 'true');
        }
        state = AuthState(status: AuthStatus.authenticated, user: user, hasSeenBriefing: hasSeenBriefing);
      } else {
        state = AuthState(status: AuthStatus.onboardingRequired, user: user, hasSeenBriefing: hasSeenBriefing);
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

  Future<void> loginWithGoogle({bool forceAccountPicker = false}) async {
    print('Starting Google Sign In Flow...');
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final didStartSession = await _authService.loginWithGoogle(
        forceAccountPicker: forceAccountPicker,
      );
      if (!didStartSession) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
      // Successful OAuth handoff is completed by the auth state listener.
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

  // ── Daily Briefing Tracking ────────────────────────────────────────

  Future<void> markBriefingAsSeen() async {
    await _storage.write(key: _briefingKey, value: 'true');
  }

  Future<bool> hasSeenBriefing() async {
    final seen = await _storage.read(key: _briefingKey);
    return seen == 'true';
  }

  // ── Logout ─────────────────────────────────────────────────────────

  Future<void> logout() async {
    // Update auth state first so navigation reacts immediately even if cleanup fails.
    state = const AuthState(status: AuthStatus.unauthenticated);

    try {
      await _ref.read(bookmarkSyncProvider.notifier).clear();
    } catch (_) {}

    try {
      await _authService.logout();
    } catch (_) {}

    try {
      await _storage.delete(key: _briefingKey);
    } catch (_) {}
  }

  // ── Profile Updates ────────────────────────────────────────────────

  Future<void> updateProfile({String? fullName, String? avatarUrl}) async {
    try {
      await _authService.updateProfile(fullName: fullName, avatarUrl: avatarUrl);
      
      // Refresh user data from backend to ensure local state is in sync
      final updatedUser = await _authService.getMe();
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
