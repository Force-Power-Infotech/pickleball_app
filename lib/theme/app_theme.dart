import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration with modern sports-inspired dark theme
class AppTheme {
  // Colors
  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color neonGreen = Color(0xFF30D158);
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color cardBackground = Color(0xFF1C1C1E);
  static const Color surfaceColor = Color(0xFF2C2C2E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color accentGold = Color(0xFFFFD60A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryRed, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [darkBackground, Color(0xFF1A1A1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardBackground, surfaceColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get neonShadow => [
    BoxShadow(
      color: primaryRed.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: primaryBlue.withOpacity(0.3),
      blurRadius: 15,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];

  // Border Radius
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(20));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(15));

  // Text Styles
  static TextStyle get headlineStyle => GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: 1.2,
  );

  static TextStyle get titleStyle => GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: 1.0,
  );

  static TextStyle get scoreStyle => GoogleFonts.orbitron(
    fontSize: 72,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: 2.0,
    shadows: [
      Shadow(
        color: primaryRed.withOpacity(0.5),
        blurRadius: 10,
      ),
    ],
  );

  static TextStyle get bodyStyle => GoogleFonts.barlow(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get captionStyle => GoogleFonts.barlow(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle get buttonStyle => GoogleFonts.orbitron(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: 0.8,
  );

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: darkBackground,
      cardColor: cardBackground,
      textTheme: TextTheme(
        displayLarge: headlineStyle,
        displayMedium: titleStyle,
        headlineLarge: scoreStyle,
        bodyLarge: bodyStyle,
        bodyMedium: captionStyle,
        labelLarge: buttonStyle,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        secondary: primaryBlue,
        surface: cardBackground,
        background: darkBackground,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
        tertiary: neonGreen,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: titleStyle,
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: textPrimary,
          elevation: 8,
          shadowColor: primaryRed.withOpacity(0.5),
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: buttonStyle,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 8,
        shape: const RoundedRectangleBorder(borderRadius: cardRadius),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: BorderSide(color: textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: buttonRadius,
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        labelStyle: bodyStyle,
        hintStyle: captionStyle,
      ),
    );
  }

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration splashAnimation = Duration(milliseconds: 2000);

  // Animation Curves
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bouncyCurve = Curves.bounceOut;
  static const Curve fastCurve = Curves.easeOutQuart;
}
