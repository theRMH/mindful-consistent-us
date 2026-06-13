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

  static AuthState _buildInitialState() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
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

  // Sends OTP. Caller navigates to /otp screen on success.
  Future<bool> login(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    // MOCK LOGIN FOR DEVELOPMENT - Bypasses Supabase since user plans to use Firebase
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false);
    return true;
  }

  static const String notRegisteredError = 'not_registered';

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
        state = AuthState(
          isAuthenticated: true,
          user: UserProfile(
            id: 'mock-user-123',
            email: '',
            phone: phone,
            fullName: '',
            avatarUrl: '',
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

      state = AuthState(
        isAuthenticated: true,
        user: UserProfile(
          id: session.user.id,
          email: session.user.email ?? '',
          phone: session.user.phone ?? '',
          fullName: '',
          avatarUrl: '',
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

  // Signup and login share the same Supabase OTP flow
  Future<bool> register(String phone) async {
    return login(phone);
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
