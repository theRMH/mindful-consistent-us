import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  AuthNotifier() : super(AuthState());

  void loginAsGuest() {
    state = AuthState(isGuest: true, isAuthenticated: false);
  }

  Future<bool> login(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (phone.length < 10) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid phone number. Must be at least 10 digits.',
      );
      return false;
    }

    state = AuthState(
      isAuthenticated: true,
      user: UserProfile(
        id: 'mock-user-123',
        email: 'user@consistentus.com',
        phone: phone,
        fullName: 'KalanithiAK',
        avatarUrl: '',
      ),
    );
    return true;
  }

  Future<bool> register(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (phone.length < 10) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid phone number. Must be at least 10 digits.',
      );
      return false;
    }

    state = AuthState(
      isAuthenticated: true,
      user: UserProfile(
        id: 'mock-user-123',
        email: 'user@consistentus.com',
        phone: phone,
        fullName: 'KalanithiAK',
        avatarUrl: '',
      ),
    );
    return true;
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
