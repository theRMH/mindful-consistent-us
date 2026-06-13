import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF12623F);
  static const Color emeraldGreen = Color(0xFF007A4D);
  static const Color darkTeal = Color(0xFF0E3C31);
  static const Color lightSage = Color(0xFF7FC88E);
  static const Color accentGreen = Color(0xFF10B981);
  
  static const Color backgroundCream = Color(0xFFFFF8E7);
  static const Color accentGold = Color(0xFFFFD166);
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color coolGray = Color(0xFF94A3B8);
  static const Color lightGray = Color(0xFFF1F3F5);

  // Figma Specific Colors
  static const Color figmaGreen = Color(0xFF019948);
  static const Color figmaMutedGreen = Color(0xFF4B7A56);
  static const Color figmaLightBorder = Color(0xFFC8D6CE);
  static const Color figmaBgGray = Color(0xFFF5F7F9);
  static const Color figmaCharcoal = Color(0xFF231F20);
  static const Color figmaMutedGray = Color(0xFF5B5B5B);

  // Additional tokens for workout cards / general UI
  static const Color brown = Color(0xFF8B5A00);
  static const Color lightBrown = Color(0xFFFFF3DC);
  static const Color darkSlateGray = Color(0xFF374151);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: emeraldGreen,
        error: Colors.redAccent,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkSlate,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: darkTeal,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkTeal,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: darkTeal,
        ),        
        bodySmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.normal,
          color: darkSlate,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: darkSlate,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkSlate,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryGreen,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundCream,
        elevation: 0,
        iconTheme: IconThemeData(color: darkTeal),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkTeal,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: coolGray,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

class AppRadii {
  static const double none = 0.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
  static const double xxxl = 28.0;
  static const double pill = 100.0;
}

class AppFontSizes {
  static const double h1 = 28.0;
  static const double h2 = 24.0;
  static const double h3 = 20.0;
  static const double bodyLarge = 15.0;
  static const double bodyMedium = 12.0;
  static const double bodySmall = 10.0;
  static const double caption = 6.5;
}

class AppFontWeights {
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight regular = FontWeight.w400;
}


