import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/courses_provider.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/api_service.dart';

class CartScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CartScreen({super.key, required this.courseId});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _couponController = TextEditingController(
    text: 'FIT20',
  );
  bool _couponApplied = false;
  bool _checkingMetrics = false;
  int _selectedUpiIndex = 0;
  final int _quantity = 1;

  Map<String, dynamic>? _courseData;
  bool _loadingCourse = true;

  double get _originalPrice =>
      (_courseData?['priceInr'] as num?)?.toDouble() ?? 999.0;
  static const double _discount = 300;

  double get _unitPrice =>
      _couponApplied ? (_originalPrice - _discount) : _originalPrice;
  double get _totalPayable => _unitPrice * _quantity;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    try {
      final data = await ApiService().getCourseDetails(widget.courseId);
      if (mounted) setState(() { _courseData = data; _loadingCourse = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCourse = false);
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildSectionHeader(),
                  const SizedBox(height: 12),
                  _buildCourseCard(),
                  const SizedBox(height: 16),
                  _buildCouponSection(),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Pay with UPI',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: AppFontWeights.semiBold,
                        color: AppTheme.figmaCharcoal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildUpiOption(
                    index: 0,
                    icon: Image.asset(
                      'assets/icon_payment_logos.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildUpiLogo(),
                    ),
                    title: 'Google pay / Phonepe',
                    subtitle: 'Pay instantly via your UPI',
                  ),
                  const SizedBox(height: 10),
                  _buildUpiOption(
                    index: 1,
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2F0E8)),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: AppTheme.figmaCharcoal,
                        size: 20,
                      ),
                    ),
                    title: 'More UPI Apps',
                    subtitle: '',
                  ),
                  const SizedBox(height: 28),
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

  // ─── Header ────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.figmaGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      padding: EdgeInsets.only(
        top: statusBarHeight + 16,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppTheme.figmaGreen,
                    size: 28,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_quantity Item',
                  style: GoogleFonts.inter(
                    color: AppTheme.primaryGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Your Cart',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Premium fitness programs, ready to unlock.\nPay instantly with UPI and start today.',
            style: GoogleFonts.inter(
              color: Colors.white.withAlpha(204),
              fontSize: 13,
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
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.figmaGreen,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/programs?tab=explore'),
            child: Row(
              children: [
                Text(
                  'Add More',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.figmaGreen,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.add_circle_rounded,
                  size: 16,
                  color: AppTheme.figmaGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Course Card ─────────────────────────────────────────────────────────
  Widget _buildCourseCard() {
    if (_loadingCourse) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(child: CircularProgressIndicator(color: AppTheme.figmaGreen, strokeWidth: 2)),
      );
    }

    final title = (_courseData?['title'] as String?) ?? '30 Days Yoga Course';
    final thumbnailUrl = _courseData?['thumbnailUrl'] as String?;
    final totalDays = (_courseData?['totalDays'] as int?) ?? 30;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2F0E8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                  ? Image.network(
                      thumbnailUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, st) => _buildCoursePlaceholder(),
                    )
                  : Image.asset(
                      'assets/course_30_days.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, st) => _buildCoursePlaceholder(),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: AppFontWeights.semiBold,
                      color: AppTheme.figmaGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.figmaGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$totalDays Days',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${_unitPrice.toInt()}',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: AppFontWeights.semiBold,
                      color: AppTheme.figmaCharcoal,
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

  Widget _buildCoursePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFE8F5E9),
      child: const Icon(Icons.self_improvement, color: AppTheme.figmaGreen, size: 36),
    );
  }

  // ─── Coupon Section ──────────────────────────────────────────────────────
  Widget _buildCouponSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FBF8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/icon_coupon.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F0E4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_offer_outlined,
                  color: AppTheme.figmaGreen,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apply Code ${_couponController.text}',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: AppFontWeights.semiBold,
                      color: AppTheme.figmaCharcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Extra ₹${_discount.toInt()} off on this order',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: AppFontWeights.regular,
                      color: AppTheme.coolGray,
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
                    backgroundColor: AppTheme.figmaGreen,
                  ),
                );
              },
              child: Text(
                _couponApplied ? 'Remove' : 'Apply',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: AppFontWeights.semiBold,
                  color: AppTheme.figmaGreen,
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
    required int index,
    required Widget icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedUpiIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedUpiIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.figmaGreen : const Color(0xFFE2F0E8),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x02000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: AppFontWeights.semiBold,
                        color: AppTheme.figmaCharcoal,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: AppFontWeights.regular,
                          color: AppTheme.coolGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.figmaGreen,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Google Pay / PhonePe logo ────────────────────────────────────────────
  Widget _buildUpiLogo() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF7F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4285F4),
              ),
              child: Center(
                child: Text(
                  'G',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF5F259F),
              ),
              child: Center(
                child: Text(
                  'P',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Payable',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: AppFontWeights.semiBold,
              color: AppTheme.figmaCharcoal,
            ),
          ),
          Text(
            '₹${_totalPayable.toInt()}',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: AppFontWeights.semiBold,
              color: AppTheme.figmaCharcoal,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sticky Checkout Footer ───────────────────────────────────────────────
  Widget _buildCheckoutBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE5EFE6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, -4),
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
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: AppFontWeights.semiBold,
                    color: AppTheme.figmaCharcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${_totalPayable.toInt()}',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.figmaCharcoal,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _checkingMetrics ? null : _handleCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.figmaGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _checkingMetrics
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Checkout',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: AppFontWeights.semiBold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Checkout Logic ───────────────────────────────────────────────────────
  void _handleCheckout() {
    final isLoggedIn = ref.read(authProvider).user != null;
    if (!isLoggedIn) {
      _showAuthSheet();
    } else {
      _checkMetricsThenPay();
    }
  }

  Future<void> _checkMetricsThenPay() async {
    setState(() => _checkingMetrics = true);
    try {
      final records = await ApiService().getBodyMetrics();
      if (!mounted) return;
      if (records.isEmpty) {
        final cartPath = Uri.encodeComponent('/cart?courseId=${widget.courseId}');
        context.push('/body-metrics?skip=false&courseId=${widget.courseId}&redirect=$cartPath');
        return;
      }
    } catch (_) {
      // If the check fails, proceed anyway so payment is not blocked
    } finally {
      if (mounted) setState(() => _checkingMetrics = false);
    }
    _processPayment();
  }

  void _showAuthSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
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
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Lock icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppTheme.primaryGreen,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sign in to Complete Purchase',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkTeal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account or log in to securely\ncomplete your purchase.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.coolGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              // Create Account button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final cartPath = Uri.encodeComponent('/cart?courseId=${widget.courseId}');
                    context.push('/signup?redirect=$cartPath');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Create Account',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Log In button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final cartPath = Uri.encodeComponent('/cart?courseId=${widget.courseId}');
                    context.push('/login?redirect=$cartPath');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppTheme.primaryGreen,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Log In',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
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
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const CircularProgressIndicator(color: AppTheme.primaryGreen),
              const SizedBox(height: 24),
              Text(
                'Processing Payment...',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.darkTeal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please wait, locking in details',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.coolGray,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    ref.read(coursesProvider.notifier).enroll(widget.courseId);

    if (mounted) {
      Navigator.pop(context); // close dialog
      context.go('/thank-you');
    }
  }
}
