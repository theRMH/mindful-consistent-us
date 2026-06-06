import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _couponController =
      TextEditingController(text: 'FIT20');
  bool _couponApplied = false;

  static const double _originalPrice = 999;
  static const double _discount = 300;

  double get _totalPayable =>
      _couponApplied ? (_originalPrice - _discount) : _originalPrice;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  // ─── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionHeader(),
                  const SizedBox(height: 12),
                  _buildCourseCard(),
                  const SizedBox(height: 16),
                  _buildCouponSection(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Pay with UPI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildUpiOption(
                    icon: _buildUpiLogo(),
                    title: 'Google pay / Phonepe',
                    subtitle: 'Pay instantly via your UPI',
                  ),
                  const SizedBox(height: 8),
                  _buildUpiOption(
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF7F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Color(0xFF00A859),
                        size: 22,
                      ),
                    ),
                    title: 'More UPI Apps',
                    subtitle: null,
                  ),
                  const SizedBox(height: 24),
                  _buildTotalRow(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCheckoutBar(context),
    );
  }

  // ─── Green Header ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF00A859),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: statusBarHeight + 12,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (context.canPop()) context.pop();
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Color(0xFF00A859),
                    size: 26,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '1 Item',
                  style: TextStyle(
                    color: Color(0xFF00A859),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Your Cart',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Premium fitness programs, ready to unlock.\nPay instantly with UPI and start today.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ──────────────────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Programs in Cart',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              fontFamily: 'Inter',
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/explore'),
            child: Row(
              children: const [
                Text(
                  'Add More',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00A859),
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.add_circle_outline_rounded,
                    size: 15, color: Color(0xFF00A859)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Course Card ─────────────────────────────────────────────────────────
  Widget _buildCourseCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2F0E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/course_30_days.png',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: const Color(0xFFE8F5E9),
                  child: const Icon(Icons.self_improvement,
                      color: Color(0xFF00A859), size: 32),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '30 Days Yoga Course',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00A859),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A859),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '30 Days',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${_couponApplied ? (_originalPrice - _discount).toInt() : _originalPrice.toInt()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Coupon Section ──────────────────────────────────────────────────────
  Widget _buildCouponSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2F0E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF7F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.local_offer_outlined,
                color: Color(0xFF00A859),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apply Code ${_couponController.text}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Extra₹ ${_discount.toInt()} off on this order',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _couponApplied = !_couponApplied;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _couponApplied
                          ? '🎉 Coupon FIT20 applied! ₹300 off'
                          : 'Coupon removed',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF00A859),
                  ),
                );
              },
              child: Text(
                _couponApplied ? 'Remove' : 'Apply',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A859),
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── UPI Option Row ──────────────────────────────────────────────────────
  Widget _buildUpiOption({
    required Widget icon,
    required String title,
    required String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2F0E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF00A859),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Google Pay / PhonePe logo ────────────────────────────────────────────
  Widget _buildUpiLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF7F2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4285F4),
              ),
              child: const Center(
                child: Text('G',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF5F259F),
              ),
              child: const Center(
                child: Text('P',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Total Payable ────────────────────────────────────────────────────────
  Widget _buildTotalRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Payable',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
            ),
          ),
          Text(
            '₹${_totalPayable.toInt()}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sticky Checkout Footer ───────────────────────────────────────────────
  Widget _buildCheckoutBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pay Using UPI',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                '₹${_totalPayable.toInt()}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _handleCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A859),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Checkout Logic ───────────────────────────────────────────────────────

  void _handleCheckout() {
    final isLoggedIn = ref.read(authProvider).user != null;
    if (!isLoggedIn) {
      _showAuthSheet();
    } else {
      _processPayment();
    }
  }

  void _showAuthSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 28,
            right: 28,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Lock icon
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF00A859),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign in to Complete Purchase',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create an account or log in to securely\ncomplete your purchase.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              // Create Account button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push('/signup?redirect=cart');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A859),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Log In button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push('/login?redirect=cart');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0xFF00A859), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00A859),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processPayment() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            CircularProgressIndicator(color: Color(0xFF00A859)),
            SizedBox(height: 20),
            Text(
              'Processing Payment...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Please wait',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    ref.read(progressProvider.notifier).enrollCourse('30-days-yoga');

    if (mounted) {
      Navigator.pop(context); // close dialog
      context.go('/thank-you');
    }
  }
}
