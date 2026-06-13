import 'package:flutter/material.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(email, password);
    if (success && mounted) {
      if (widget.redirect != null) {
        context.go(widget.redirect!);
      } else {
        context.go('/home');
      }
    } else if (mounted) {
      final errorMsg =
          ref.read(authProvider).errorMessage ?? 'Authentication failed';
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

                const SizedBox(height: AppSpacing.xxl),

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
                                      'Welcome Back',
                                      style: GoogleFonts.inter(
                                        color: AppTheme.figmaGreen,
                                        fontSize: AppFontSizes.h2,
                                        fontWeight: AppFontWeights.bold,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Log in to continue your wellness journey',
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
                                  Icons.person_rounded,
                                  color: AppTheme.figmaGreen,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Email field
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email Address',
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
                                child: TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppTheme.figmaCharcoal,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your email address',
                                    hintStyle: GoogleFonts.inter(
                                      color: AppTheme.figmaMutedGray,
                                      fontSize: 11,
                                    ),
                                    border: InputBorder.none,
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: AppTheme.figmaGreen,
                                      size: 20,
                                    ),
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

                        const SizedBox(height: AppSpacing.lg),

                        // Password field
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password',
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
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppTheme.figmaCharcoal,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    hintStyle: GoogleFonts.inter(
                                      color: AppTheme.figmaMutedGray,
                                      fontSize: 11,
                                    ),
                                    border: InputBorder.none,
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: AppTheme.figmaGreen,
                                      size: 20,
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () => setState(() =>
                                          _obscurePassword =
                                              !_obscurePassword),
                                      child: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AppTheme.figmaMutedGray,
                                        size: 20,
                                      ),
                                    ),
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

                        const SizedBox(height: AppSpacing.lg),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : _handleLogin,
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
                                        'Log in',
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

                // ── 3. Sign-up link ──────────────────────────────────
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
                        final redirectParam = widget.redirect != null ? '?redirect=${Uri.encodeComponent(widget.redirect!)}' : '';
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

                // ── 4. Continue without login ────────────────────────
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
