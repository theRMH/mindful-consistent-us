import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/background_leaves.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final String? initialPhone;
  final String? redirect;

  const SignupScreen({super.key, this.initialPhone, this.redirect});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
      _phoneController.text = widget.initialPhone!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your mobile number')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).register(phone);
    if (success && mounted) {
      final redirectParam = widget.redirect != null ? '&redirect=${Uri.encodeComponent(widget.redirect!)}' : '';
      context.go('/otp?phone=${Uri.encodeComponent(phone)}$redirectParam');
    } else if (mounted) {
      final errorMsg =
          ref.read(authProvider).errorMessage ?? 'Registration failed';
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
      onPopInvokedWithResult: (didPop, result) => context.go('/unregistered'),
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
                // ── 1. Header with logo ──────────────────────────────
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
                  child: const Center(
                    child: BrandLogo(size: 80),
                  ),
                ),

                const Spacer(),

                // ── 2. Form card ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xl,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.xxl),
                      border: Border.all(
                          color: AppTheme.figmaLightBorder, width: 1.0),
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
                              horizontal: AppSpacing.md),
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
                                      'Register Now!',
                                      style: GoogleFonts.inter(
                                        color: AppTheme.figmaGreen,
                                        fontSize: AppFontSizes.h2,
                                        fontWeight: AppFontWeights.bold,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Register to start your wellness journey',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color: AppTheme.figmaMutedGray,
                                        fontSize:
                                            AppFontSizes.bodySmall + 1.0,
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
                                  Icons.person_add_rounded,
                                  color: AppTheme.figmaGreen,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Mobile Number field
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      AppRadii.xxl),
                                  border: Border.all(
                                      color: AppTheme.figmaLightBorder,
                                      width: 1.0),
                                ),
                                child: Row(
                                  children: [
                                    // Country code
                                    SizedBox(
                                      width: 80,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '+91',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight:
                                                  AppFontWeights.semiBold,
                                              color: AppTheme.figmaGreen,
                                            ),
                                          ),
                                          const SizedBox(
                                              width: AppSpacing.xxs),
                                          const Icon(
                                            Icons
                                                .keyboard_arrow_down_rounded,
                                            color: AppTheme.figmaGreen,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Divider
                                    Container(
                                      width: 1,
                                      color: AppTheme.figmaLightBorder,
                                    ),
                                    // Phone input
                                    Expanded(
                                      child: TextField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: AppTheme.figmaCharcoal,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              'Enter your mobile number',
                                          hintStyle: GoogleFonts.inter(
                                            color: AppTheme.figmaMutedGray,
                                            fontSize: 11,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
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

                        // Register button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.figmaGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.pill),
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
                                        'Register',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight:
                                              AppFontWeights.semiBold,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: AppSpacing.xl,
                                        color: Colors.white,
                                      ),
                                    ],
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
                              'We never share your number with anyone',
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

                // ── 3. Login link ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an Account ?  ',
                      style: GoogleFonts.inter(
                        color: AppTheme.figmaCharcoal,
                        fontSize: AppFontSizes.bodyLarge,
                        fontWeight: AppFontWeights.semiBold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final redirectParam = widget.redirect != null ? '?redirect=${Uri.encodeComponent(widget.redirect!)}' : '';
                        context.go('/login$redirectParam');
                      },
                      child: Text(
                        'Log in',
                        style: GoogleFonts.inter(
                          color: AppTheme.figmaMutedGreen,
                          fontWeight: AppFontWeights.semiBold,
                          fontSize: AppFontSizes.bodyLarge,
                        ),
                      ),
                    ),
                  ],
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
