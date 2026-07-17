import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/analytics_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/background_leaves.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String phone;
  final String mode; // 'login' or 'register'
  final String? redirect;
  final String? name;

  const OTPScreen({
    super.key,
    required this.phone,
    this.mode = 'register',
    this.redirect,
    this.name,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // If verificationCompleted already fired before this screen was built, fill now.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final code = ref.read(authProvider).autoFilledCode;
      if (code != null) _autoFill(code);
    });
  }

  void _autoFill(String code) {
    for (int i = 0; i < 6 && i < code.length; i++) {
      _controllers[i].text = code[i];
    }
    if (code.length >= 6) _focusNodes.last.unfocus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _handleVerify() async {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits of the OTP')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOtpAndLogin(
      otp,
      isLoginAttempt: widget.mode == 'login',
      name: widget.name,
    );
    if (success && mounted) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) AnalyticsService().setUser(uid);
      if (widget.mode == 'register') {
        AnalyticsService().logSignUp();
      } else {
        AnalyticsService().logLogin();
      }
      if (widget.redirect != null && widget.redirect!.isNotEmpty) {
        context.go(widget.redirect!);
      } else {
        context.go('/home');
      }
    } else if (mounted) {
      final errorMsg = ref.read(authProvider).errorMessage ?? 'Verification failed';
      if (errorMsg == AuthNotifier.notRegisteredError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No account found. Please register first.')),
        );
        final redirectParam = widget.redirect != null ? '&redirect=${Uri.encodeComponent(widget.redirect!)}' : '';
        context.go('/signup?phone=${Uri.encodeComponent(widget.phone)}$redirectParam');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!mounted) return;
      // Auto-fill OTP boxes when Android reads the SMS code.
      if (next.autoFilledCode != null && next.autoFilledCode != previous?.autoFilledCode) {
        _autoFill(next.autoFilledCode!);
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
        backgroundColor: AppTheme.backgroundCream,
        body: Stack(
          children: [
            const BackgroundLeaves(),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header Curved White Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 30, bottom: 40),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: BrandLogo(size: 120),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Card container for verification fields
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        padding: const EdgeInsets.all(28.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: const Color(0xFFF1F3F5)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verify Mobile',
                              style: GoogleFonts.inter(
                                color: AppTheme.darkTeal,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Enter verification code sent to +91 ${widget.phone}',
                              style: GoogleFonts.inter(
                                color: AppTheme.coolGray,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 36),

                            // OTP 6 fields row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return SizedBox(
                                  width: 42,
                                  height: 50,
                                  child: CallbackShortcuts(
                                    bindings: {
                                      const SingleActivator(LogicalKeyboardKey.backspace): () {
                                        if (_controllers[index].text.isEmpty && index > 0) {
                                          _focusNodes[index - 1].requestFocus();
                                          _controllers[index - 1].clear();
                                        }
                                      }
                                    },
                                    child: TextField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.darkTeal,
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        counterText: "",
                                        contentPadding: EdgeInsets.zero,
                                        filled: true,
                                        fillColor: AppTheme.lightGray,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: AppTheme.emeraldGreen, width: 2),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          if (index < 5) {
                                            _focusNodes[index + 1].requestFocus();
                                          } else {
                                            _focusNodes[index].unfocus();
                                          }
                                        } else if (index > 0) {
                                          _focusNodes[index - 1].requestFocus();
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 36),

                            // Verify button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: authState.isLoading ? null : _handleVerify,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(27),
                                  ),
                                ),
                                child: authState.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Verify & Proceed',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward, size: 18),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Timer and Resend Code Row
                            Center(
                              child: _secondsRemaining > 0
                                  ? Text(
                                      'Resend code in ${_secondsRemaining}s',
                                      style: GoogleFonts.inter(
                                        color: AppTheme.coolGray,
                                        fontSize: 13,
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        final messenger = ScaffoldMessenger.of(context);
                                        await ref.read(authProvider.notifier).sendOtp(widget.phone);
                                        if (!mounted) return;
                                        final error = ref.read(authProvider).errorMessage;
                                        if (error != null) {
                                          messenger.showSnackBar(SnackBar(content: Text(error)));
                                          return;
                                        }
                                        setState(() => _startTimer());
                                        messenger.showSnackBar(const SnackBar(content: Text('OTP resent')));
                                      },
                                      child: Text(
                                        'Resend Code',
                                        style: GoogleFonts.inter(
                                          color: AppTheme.primaryGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }
}
