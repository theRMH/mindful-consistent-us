import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/background_leaves.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String phone;

  const OTPScreen({
    super.key,
    required this.phone,
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
    // Combine 6 digits
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits of the OTP')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOtpAndLogin(widget.phone, otp);
    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      final errorMsg = ref.read(authProvider).errorMessage ?? 'Verification failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/signup?phone=${widget.phone}');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFDF8),
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
                      padding: const EdgeInsets.only(top: 20, bottom: 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(36),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: BrandLogo(size: 110),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Card container for verification fields
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFF1F3F5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Verify Mobile',
                              style: TextStyle(
                                color: Color(0xFF00A859),
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Enter verification code sent to +91 ${widget.phone}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // OTP 6 fields row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return SizedBox(
                                  width: 42,
                                  height: 48,
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
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0E3C31),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        counterText: "",
                                        contentPadding: EdgeInsets.zero,
                                        filled: true,
                                        fillColor: const Color(0xFFF9FAFB),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFF00A859), width: 2),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          if (index < 5) {
                                            _focusNodes[index + 1].requestFocus();
                                          } else {
                                            _focusNodes[index].unfocus();
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 32),

                            // Verify button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: authState.isLoading ? null : _handleVerify,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A859),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                                child: authState.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            'Verify & Proceed',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward, size: 18),
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
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 13,
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _startTimer();
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('OTP resent to mobile number!')),
                                        );
                                      },
                                      child: const Text(
                                        'Resend Code',
                                        style: TextStyle(
                                          color: Color(0xFF00A859),
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
      ),
    );
  }
}
