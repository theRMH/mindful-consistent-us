import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ThankYouScreen extends StatefulWidget {
  const ThankYouScreen({super.key});

  @override
  State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFDF8),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Animated checkmark circle ──────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00A859),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00A859).withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Title ──────────────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const Text(
                    'Payment Successful!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                FadeTransition(
                  opacity: _fadeAnim,
                  child: const Text(
                    'You\'re all set! Your 30 Days Yoga Course\nhas been added to your active programs.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Inter',
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Order summary card ─────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2F0E8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _orderRow('Course', '30 Days Yoga Course'),
                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        _orderRow('Amount Paid', '₹999'),
                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        _orderRow('Payment Method', 'UPI'),
                        const Divider(height: 20, color: Color(0xFFF1F5F9)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontFamily: 'Inter',
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '✓ Confirmed',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00A859),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Go to Programs button ──────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A859),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Start Your Journey →',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => context.go('/explore'),
                  child: const Text(
                    'View My Programs',
                    style: TextStyle(
                      color: Color(0xFF00A859),
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
