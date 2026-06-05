import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        const SizedBox(height: 12),
        Text(
          'ConsistentUs',
          style: GoogleFonts.merriweather(
            fontSize: size * 0.18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF12623F), // Dark green branding color
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
