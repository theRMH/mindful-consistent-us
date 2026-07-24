import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class UserProfile {
  final String id;
  final String phone;
  final String fullName;
  final String avatarUrl;

  UserProfile({
    required this.id,
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
  final String? verificationId;
  final int? resendToken;
  final String? autoFilledCode;

  AuthState({
    this.isAuthenticated = false,
    this.isGuest = false,
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.verificationId,
    this.resendToken,
    this.autoFilledCode,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isGuest,
    bool? isLoading,
    UserProfile? user,
    String? errorMessage,
    String? verificationId,
    int? resendToken,
    String? autoFilledCode,
    bool clearAutoFilledCode = false,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isGuest: isGuest ?? this.isGuest,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      autoFilledCode: clearAutoFilledCode
          ? null
          : (autoFilledCode ?? this.autoFilledCode),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(_buildInitialState()) {
    if (state.isAuthenticated) {
      _refreshToken();
      _refreshProfileFromApi();
    }
    FirebaseAuth.instance.idTokenChanges().listen((user) async {
      if (user != null) {
        final token = await user.getIdToken();
        ApiService().setToken(token);
      } else {
        ApiService().setToken(null);
      }
    });
  }

  static AuthState _buildInitialState() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return AuthState(
          isAuthenticated: true,
          user: UserProfile(
            id: user.uid,
            phone: user.phoneNumber ?? '',
            fullName: '',
            avatarUrl: '',
          ),
        );
      }
    } catch (_) {}
    return AuthState();
  }

  Future<void> _refreshToken() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token != null) ApiService().setToken(token);
    } catch (_) {}
  }

  Future<void> _refreshProfileFromApi() async {
    if (!state.isAuthenticated || state.user == null) return;
    try {
      final profile = await ApiService().getProfile();
      final fullName = (profile['fullName'] as String? ?? '').trim();
      final avatarUrl = (profile['avatarUrl'] as String? ?? '');
      state = state.copyWith(
        user: UserProfile(
          id: state.user!.id,
          phone: state.user!.phone,
          fullName: fullName.isNotEmpty ? fullName : state.user!.phone,
          avatarUrl: avatarUrl,
        ),
      );
    } catch (_) {}
  }

  void loginAsGuest() {
    state = AuthState(isGuest: true, isAuthenticated: false);
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearAutoFilledCode: true,
    );
    // verifyPhoneNumber's Future resolves before any callback fires.
    // Use a Completer so callers can await the actual outcome (codeSent /
    // verificationFailed / verificationCompleted) instead of just the kick-off.
    final completer = Completer<void>();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      forceResendingToken: state.resendToken,
      verificationCompleted: (PhoneAuthCredential credential) {
        // Android auto-read the SMS — store the code for OTP screen to auto-fill.
        // Never sign in automatically; the user must still tap Verify.
        state = state.copyWith(
          isLoading: false,
          autoFilledCode: credential.smsCode,
          verificationId: credential.verificationId ?? state.verificationId,
        );
        if (!completer.isCompleted) completer.complete();
      },
      verificationFailed: (FirebaseAuthException e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.message ?? 'Failed to send OTP',
        );
        if (!completer.isCompleted) completer.complete();
      },
      codeSent: (String verificationId, int? resendToken) {
        state = state.copyWith(
          isLoading: false,
          verificationId: verificationId,
          resendToken: resendToken,
        );
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        state = state.copyWith(verificationId: verificationId);
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  static const String notRegisteredError = 'not_registered';
  static const String alreadyRegisteredError = 'already_registered';

  Future<bool> verifyOtpAndLogin(String smsCode, {String? name}) async {
    if (state.verificationId == null) {
      state = state.copyWith(
        errorMessage: 'Session expired. Please resend OTP.',
      );
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );
      return await _signInWithCredential(credential, name: name);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Verification failed',
      );
      return false;
    }
  }

  Future<bool> _signInWithCredential(
    PhoneAuthCredential credential, {
    String? name,
  }) async {
    try {
      final userCred = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final token = await userCred.user?.getIdToken();
      if (token == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Authentication failed',
        );
        return false;
      }
      ApiService().setToken(token);

      // Login path: confirm the profile exists before touching the DB.
      // Signup path (name != null): create profile via syncProfile.
      Map<String, dynamic>? existingProfile;
      if (name == null) {
        // Login — profile must already exist.
        try {
          existingProfile = await ApiService().getProfile();
        } catch (_) {
          ApiService().setToken(null);
          await FirebaseAuth.instance.signOut();
          state = state.copyWith(
            isLoading: false,
            errorMessage: notRegisteredError,
          );
          return false;
        }
      } else {
        // Signup — create/update profile and detect if account already existed.
        bool alreadyExisted = false;
        try {
          alreadyExisted = await ApiService().syncProfile(fullName: name);
        } catch (_) {
          ApiService().setToken(null);
          await FirebaseAuth.instance.signOut();
          state = state.copyWith(
            isLoading: false,
            errorMessage:
                'Could not finish setting up your account. Please try again.',
          );
          return false;
        }
        if (alreadyExisted) {
          ApiService().setToken(null);
          await FirebaseAuth.instance.signOut();
          state = state.copyWith(
            isLoading: false,
            errorMessage: alreadyRegisteredError,
          );
          return false;
        }
      }

      // Login path: sync still needed to refresh phone/email on the profile.
      if (name == null) {
        try {
          await ApiService().syncProfile();
        } catch (_) {
          // Non-fatal on login — profile already confirmed to exist above.
        }
      }

      String resolvedName = name ?? '';
      String avatarUrl = '';
      try {
        final profile = existingProfile ?? await ApiService().getProfile();
        resolvedName = (profile['fullName'] as String? ?? resolvedName);
        avatarUrl = profile['avatarUrl'] as String? ?? '';
      } catch (_) {
        ApiService().setToken(null);
        await FirebaseAuth.instance.signOut();
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load your account. Please try again.',
        );
        return false;
      }

      state = AuthState(
        isAuthenticated: true,
        user: UserProfile(
          id: userCred.user!.uid,
          phone: userCred.user!.phoneNumber ?? '',
          fullName: resolvedName,
          avatarUrl: avatarUrl,
        ),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Sign in failed',
      );
      return false;
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    ApiService().setToken(null);
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
