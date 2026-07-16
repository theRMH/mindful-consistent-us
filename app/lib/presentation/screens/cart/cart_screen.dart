import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../../core/config/theme.dart';

class CartScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CartScreen({super.key, required this.courseId});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  bool _couponApplied = false;
  double? _couponDiscount;
  String? _couponError;
  bool _isValidatingCoupon = false;
  bool _isProcessing = false;
  final int _quantity = 1;
  late Razorpay _razorpay;

  Map<String, dynamic>? _courseData;
  bool _loadingCourse = true;

  double get _originalPrice {
    final raw = _courseData?['priceInr'];
    if (raw == null) return 999.0;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString()) ?? 999.0;
  }

  double get _unitPrice =>
      _couponApplied && _couponDiscount != null
          ? (_originalPrice - _couponDiscount!).clamp(0, double.infinity)
          : _originalPrice;
  double get _totalPayable => _unitPrice * _quantity;

  @override
  void initState() {
    super.initState();
    _loadCourse();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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
    _razorpay.clear();
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
                      'Payment option',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: AppFontWeights.semiBold,
                        color: AppTheme.figmaCharcoal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.figmaGreen, width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Color(0x02000000), blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF072654),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'R',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Razorpay',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: AppFontWeights.semiBold,
                                    color: AppTheme.figmaCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Cards, UPI, Net Banking & more',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: AppFontWeights.regular,
                                    color: AppTheme.coolGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppTheme.figmaGreen, size: 24),
                        ],
                      ),
                    ),
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
      child: Text(
        'Programs in Cart',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.figmaGreen,
        ),
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
  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      setState(() => _couponError = 'Enter a coupon code');
      return;
    }
    setState(() { _isValidatingCoupon = true; _couponError = null; });
    final result = await ApiService().validateCoupon(code);
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _couponApplied = true;
        _couponDiscount = (result['discountAmount'] as num).toDouble();
        _isValidatingCoupon = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon applied! ₹${_couponDiscount!.toInt()} off'),
          backgroundColor: AppTheme.figmaGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      setState(() { _couponError = 'Invalid or expired coupon'; _isValidatingCoupon = false; });
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponApplied = false;
      _couponDiscount = null;
      _couponError = null;
      _couponController.clear();
    });
  }

  Widget _buildCouponSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FBF8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  child: _couponApplied
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Code ${_couponController.text.toUpperCase()} applied!',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: AppFontWeights.semiBold,
                                color: AppTheme.figmaGreen,
                              ),
                            ),
                            Text(
                              '₹${_couponDiscount!.toInt()} off on this order',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.coolGray,
                              ),
                            ),
                          ],
                        )
                      : TextField(
                          controller: _couponController,
                          textCapitalization: TextCapitalization.characters,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.figmaCharcoal,
                            fontWeight: AppFontWeights.semiBold,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter coupon code',
                            hintStyle: GoogleFonts.inter(
                              color: AppTheme.coolGray,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                _isValidatingCoupon
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.figmaGreen),
                      )
                    : GestureDetector(
                        onTap: _couponApplied ? _removeCoupon : _applyCoupon,
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
            if (_couponError != null) ...[
              const SizedBox(height: 6),
              Text(
                _couponError!,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
              ),
            ],
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
            Text(
              '₹${_totalPayable.toInt()}',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.figmaCharcoal,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handleCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.figmaGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
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
      _processPayment();
    }
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
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final options = {
        'key': AppConfig.razorpayKeyId,
        'amount': (_totalPayable * 100).round(), // paise
        'currency': 'INR',
        'name': 'ConsistentUs',
        'description': _courseData?['title'] as String? ?? 'Course',
        'prefill': {
          'contact': ref.read(authProvider).user?.phone ?? '',
        },
        'theme': {'color': '#019948'},
      };
      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await ApiService().enrollInCourse(
        widget.courseId,
        razorpayOrderId: response.orderId,
        razorpayPaymentId: response.paymentId,
        razorpaySignature: response.signature,
        couponCode: _couponApplied ? _couponController.text.trim() : null,
      );
    } catch (_) {}
    if (mounted) {
      setState(() => _isProcessing = false);
      context.go('/thank-you', extra: {
        'courseId': widget.courseId,
        'courseTitle': _courseData?['title'] as String?,
        'amountPaid': _totalPayable.toInt(),
        'whatsappLink': _courseData?['whatsappLink'] as String?,
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Payment cancelled'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) setState(() => _isProcessing = false);
  }
}
