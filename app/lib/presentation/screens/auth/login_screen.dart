import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/background_leaves.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? redirect;
  const LoginScreen({super.key, this.redirect});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }
    await ref.read(authProvider.notifier).sendOtp(phone);
    if (!mounted) return;
    final error = ref.read(authProvider).errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final redirectParam = widget.redirect != null
        ? '&redirect=${Uri.encodeComponent(widget.redirect!)}'
        : '';
    context.push(
      '/otp?phone=${Uri.encodeComponent(phone)}&mode=login$redirectParam',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/unregistered');
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            const BackgroundLeaves(),
            SafeArea(
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            top: AppSpacing.xxxl + AppSpacing.xl,
                            bottom: AppSpacing.xxl,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(AppSpacing.xxxl),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x0F000000),
                                blurRadius: AppSpacing.lg,
                                offset: Offset(0, AppSpacing.xs),
                              ),
                            ],
                          ),
                          child: const Center(child: BrandLogo(size: 80)),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Form card
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xl,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadii.xxl),
                              border: Border.all(
                                color: AppTheme.figmaLightBorder,
                                width: 1.0,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0F000000),
                                  blurRadius: AppSpacing.md,
                                  offset: Offset(0, AppSpacing.xxs),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header row
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Welcome Back',
                                              style: GoogleFonts.inter(
                                                color: AppTheme.figmaGreen,
                                                fontSize: AppFontSizes.h2,
                                                fontWeight: AppFontWeights.bold,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.xs,
                                            ),
                                            Text(
                                              'Log in with your mobile number',
                                              style: GoogleFonts.inter(
                                                color: AppTheme.figmaMutedGray,
                                                fontSize:
                                                    AppFontSizes.bodySmall +
                                                    1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.figmaMutedGreen,
                                            width: 0.2,
                                          ),
                                          color: const Color(0xFFFDFEFF),
                                        ),
                                        child: const Icon(
                                          Icons.person_rounded,
                                          color: AppTheme.figmaGreen,
                                          size: 26,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.xxl),

                                // Phone field
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mobile Number',
                                        style: GoogleFonts.inter(
                                          color: AppTheme.figmaCharcoal,
                                          fontSize: AppFontSizes.bodyLarge,
                                          fontWeight: AppFontWeights.semiBold,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Container(
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: AppTheme.figmaBgGray,
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.xxl,
                                          ),
                                          border: Border.all(
                                            color: AppTheme.figmaLightBorder,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: AppSpacing.md,
                                                  ),
                                              child: Text(
                                                '+91',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      AppFontWeights.semiBold,
                                                  color: AppTheme.figmaGreen,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 1,
                                              height: 24,
                                              color: AppTheme.figmaLightBorder,
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller: _phoneController,
                                                keyboardType:
                                                    TextInputType.phone,
                                                maxLength: 10,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color: AppTheme.figmaCharcoal,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText:
                                                      '10-digit mobile number',
                                                  hintStyle: GoogleFonts.inter(
                                                    color:
                                                        AppTheme.figmaMutedGray,
                                                    fontSize: 12,
                                                  ),
                                                  border: InputBorder.none,
                                                  counterText: '',
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal:
                                                            AppSpacing.md,
                                                        vertical: AppSpacing.md,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.lg),

                                // Send OTP button
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: authState.isLoading
                                          ? null
                                          : _handleSendOtp,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.figmaGreen,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.pill,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: authState.isLoading
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Send OTP',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        AppFontWeights.semiBold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: AppSpacing.sm,
                                                ),
                                                const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: AppSpacing.xl,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.lg),

                                // Security notice
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.gpp_good_outlined,
                                      color: AppTheme.figmaGreen,
                                      size: 16,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'We never share your data with anyone',
                                      style: GoogleFonts.inter(
                                        color: AppTheme.figmaCharcoal,
                                        fontSize: AppFontSizes.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Sign-up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an Account ?  ",
                              style: GoogleFonts.inter(
                                color: AppTheme.figmaCharcoal,
                                fontSize: AppFontSizes.bodyLarge,
                                fontWeight: AppFontWeights.semiBold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                final redirectParam = widget.redirect != null
                                    ? '?redirect=${Uri.encodeComponent(widget.redirect!)}'
                                    : '';
                                context.go('/signup$redirectParam');
                              },
                              child: Text(
                                'Create one',
                                style: GoogleFonts.inter(
                                  color: AppTheme.figmaMutedGreen,
                                  fontWeight: AppFontWeights.semiBold,
                                  fontSize: AppFontSizes.bodyLarge,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        GestureDetector(
                          onTap: () => context.go('/unregistered'),
                          child: Text(
                            'Continue without login',
                            style: GoogleFonts.inter(
                              color: AppTheme.figmaMutedGray,
                              fontWeight: AppFontWeights.semiBold,
                              fontSize: AppFontSizes.bodyLarge,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.figmaMutedGray,
                            ),
                          ),
                        ),

                        const Spacer(),
                      ],
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
}
