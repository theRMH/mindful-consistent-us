import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/theme.dart';
import '../../../core/services/api_service.dart';

final _helpContentProvider = FutureProvider.autoDispose<String>((ref) {
  return ApiService().getHelpContent();
});

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(_helpContentProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_rounded, color: AppTheme.figmaGreen),
        ),
        title: Text(
          'Help & Support',
          style: GoogleFonts.inter(
            fontWeight: AppFontWeights.bold,
            color: AppTheme.figmaGreen,
            fontSize: AppFontSizes.h3,
          ),
        ),
        centerTitle: false,
      ),
      body: contentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.figmaGreen),
        ),
        error: (e, _) => _buildEmpty(
          icon: Icons.wifi_off_rounded,
          message: 'Could not load help content.\nCheck your connection and try again.',
          showRetry: true,
          onRetry: () => ref.invalidate(_helpContentProvider),
        ),
        data: (html) {
          if (html.trim().isEmpty) {
            return _buildEmpty(
              icon: Icons.help_outline_rounded,
              message: 'Help content coming soon.\nContact us at support@consistentus.com',
            );
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
            child: Html(
              data: html,
              style: {
                'body': Style(
                  fontFamily: 'Inter',
                  fontSize: FontSize(15),
                  color: AppTheme.figmaCharcoal,
                  lineHeight: const LineHeight(1.6),
                ),
                'h1': Style(
                  fontSize: FontSize(22),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.figmaGreen,
                ),
                'h2': Style(
                  fontSize: FontSize(18),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.figmaGreen,
                ),
                'h3': Style(
                  fontSize: FontSize(16),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.figmaCharcoal,
                ),
                'a': Style(color: AppTheme.figmaGreen),
                'strong': Style(fontWeight: FontWeight.bold),
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty({
    required IconData icon,
    required String message,
    bool showRetry = false,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.figmaGreen.withAlpha(18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.figmaGreen, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: AppFontSizes.bodyLarge,
                color: AppTheme.coolGray,
                height: 1.5,
              ),
            ),
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    color: AppTheme.figmaGreen,
                    fontWeight: AppFontWeights.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
