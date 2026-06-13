import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/theme.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  const BrandLogo({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'ConsistentUs',
          style: GoogleFonts.merriweather(
            fontSize: size * 0.18,
            fontWeight: AppFontWeights.bold,
            color: AppTheme.figmaGreen, // Vibrant figmaGreen branding color
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
