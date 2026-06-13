import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/api_service.dart';

class UserProfile {
  final String id;
  final String email;
  final String phone;
  final String fullName;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.avatarUrl,
  });
}

class AuthState {
  final bool isAuthenticated;
  final bool isGuest;
  final bool isLoading;
  final UserProfile? user;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.isGuest = false,
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isGuest,
    bool? isLoading,
    UserProfile? user,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isGuest: isGuest ?? this.isGuest,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(_buildInitialState()) {
    // If app opened with an existing session, load the profile in background
    if (state.isAuthenticated) {
      _refreshProfileFromApi();
    }
    // Keep ApiService token in sync with Supabase session refreshes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (data.event == AuthChangeEvent.tokenRefreshed && session != null) {
        ApiService().setToken(session.accessToken);
      } else if (data.event == AuthChangeEvent.signedOut) {
        ApiService().setToken(null);
      }
    });
  }

  Future<void> _refreshProfileFromApi() async {
    if (!state.isAuthenticated || state.user == null) return;
    try {
      final profile = await ApiService().getProfile();
      String fullName = (profile['fullName'] as String? ?? '').trim();
      final avatarUrl = (profile['avatarUrl'] as String? ?? '').trim();
      if (fullName.isEmpty) fullName = state.user!.email.split('@').first;
      state = state.copyWith(
        user: UserProfile(
          id: state.user!.id,
          email: state.user!.email,
          phone: state.user!.phone,
          fullName: fullName,
          avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : state.user!.avatarUrl,
        ),
      );
    } catch (_) {}
  }

  static AuthState _buildInitialState() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        ApiService().setToken(session.accessToken);
        return AuthState(
          isAuthenticated: true,
          user: UserProfile(
            id: session.user.id,
            email: session.user.email ?? '',
            phone: session.user.phone ?? '',
            fullName: '',
            avatarUrl: '',
          ),
        );
      }
    } catch (_) {}
    return AuthState();
  }

  void loginAsGuest() {
    state = AuthState(isGuest: true, isAuthenticated: false);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final session = response.session;
      if (session == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'Login failed. Please try again.');
        return false;
      }
      ApiService().setToken(session.accessToken);
      String fullName = '';
      String avatarUrl = '';
      try {
        final profile = await ApiService().getProfile();
        fullName = (profile['fullName'] as String? ?? '').trim();
        avatarUrl = profile['avatarUrl'] ?? '';
      } catch (_) {}
      if (fullName.isEmpty) fullName = email.split('@').first;
      state = AuthState(
        isAuthenticated: true,
        user: UserProfile(
          id: session.user.id,
          email: session.user.email ?? email,
          phone: session.user.phone ?? '',
          fullName: fullName,
          avatarUrl: avatarUrl,
        ),
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Login failed. Check your credentials.');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      final session = response.session;
      if (session == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Please check your email to confirm your account.',
        );
        return false;
      }
      ApiService().setToken(session.accessToken);
      final displayName = name.isNotEmpty ? name : email.split('@').first;
      try {
        await ApiService().syncProfile(fullName: displayName);
      } catch (_) {}
      state = AuthState(
        isAuthenticated: true,
        user: UserProfile(
          id: session.user.id,
          email: email,
          phone: '',
          fullName: displayName,
          avatarUrl: '',
        ),
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Registration failed. Please try again.');
      return false;
    }
  }

  static const String notRegisteredError = 'not_registered';

  // Kept for future Firebase OTP integration
  Future<bool> verifyOtpAndLogin(String phone, String otp, {bool isLoginAttempt = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Mock OTP bypass for development — accepts 123456 without real SMS
      if (otp == '123456') {
        ApiService().setToken('mock-user-123');
        try { await ApiService().syncProfile(); } catch (_) {}
        if (isLoginAttempt) {
          try {
            await ApiService().getProfile();
          } catch (_) {
            ApiService().setToken(null);
            state = state.copyWith(isLoading: false, errorMessage: notRegisteredError);
            return false;
          }
        }
        String fullName = '';
        String avatarUrl = '';
        try {
          final profile = await ApiService().getProfile();
          fullName = profile['fullName'] ?? '';
          avatarUrl = profile['avatarUrl'] ?? '';
        } catch (_) {}
        state = AuthState(
          isAuthenticated: true,
          user: UserProfile(
            id: 'mock-user-123',
            email: '',
            phone: phone,
            fullName: fullName,
            avatarUrl: avatarUrl,
          ),
        );
        return true;
      }

      final response = await Supabase.instance.client.auth.verifyOTP(
        phone: '+91$phone',
        token: otp,
        type: OtpType.sms,
      );
      final session = response.session;
      if (session == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'Verification failed. Try again.');
        return false;
      }

      ApiService().setToken(session.accessToken);

      if (isLoginAttempt) {
        try {
          await ApiService().getProfile();
        } catch (_) {
          ApiService().setToken(null);
          await Supabase.instance.client.auth.signOut();
          state = state.copyWith(isLoading: false, errorMessage: notRegisteredError);
          return false;
        }
      }

      // Ensure a profile row exists in the DB
      try {
        await ApiService().syncProfile();
      } catch (_) {}

      String fullName = '';
      String avatarUrl = '';
      try {
        final profile = await ApiService().getProfile();
        fullName = profile['fullName'] ?? '';
        avatarUrl = profile['avatarUrl'] ?? '';
      } catch (_) {}

      state = AuthState(
        isAuthenticated: true,
        user: UserProfile(
          id: session.user.id,
          email: session.user.email ?? '',
          phone: session.user.phone ?? '',
          fullName: fullName,
          avatarUrl: avatarUrl,
        ),
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Verification failed. Check OTP and retry.');
      return false;
    }
  }

  void logout() {
    Supabase.instance.client.auth.signOut();
    ApiService().setToken(null);
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
