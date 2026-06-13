import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/theme.dart';

void showLoginPrompt(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.xl),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Icon(Icons.lock_outline_rounded,
              color: AppTheme.figmaGreen, size: 48),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Create a free account to continue',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppFontSizes.h3,
              fontWeight: AppFontWeights.bold,
              color: AppTheme.figmaCharcoal,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sign up for free and unlock all videos,\nprograms, and tracking features.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: AppFontSizes.bodyMedium,
              color: AppTheme.coolGray,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final redirect = Uri.encodeComponent(GoRouterState.of(context).uri.toString());
                Navigator.pop(ctx);
                context.go('/signup?redirect=$redirect');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.figmaGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                ),
                elevation: 0,
              ),
              child: Text(
                'Sign Up for Free',
                style: GoogleFonts.inter(
                  fontSize: AppFontSizes.bodyLarge,
                  fontWeight: AppFontWeights.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () {
              final redirect = Uri.encodeComponent(GoRouterState.of(context).uri.toString());
              Navigator.pop(ctx);
              context.go('/login?redirect=$redirect');
            },
            child: Text(
              'Already have an account? Login',
              style: GoogleFonts.inter(
                fontSize: AppFontSizes.bodyMedium,
                color: AppTheme.coolGray,
                fontWeight: AppFontWeights.semiBold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    ),
  );
}
