import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration with modern sports-inspired dark theme
class AppTheme {
  static const Color buttonViolet = Color(0xFF6C63FF); // Modern blue-violet for premium buttons
  // Colors - Premium 3D Metallic Theme
  static const Color primaryEmerald = Color(0xFF00E676); // Sporty light green (replaces deep teal)
  static const Color primaryBlue = Color(0xFF3498DB);
  static const Color neonBlue = Color(0xFF007AFF); // Neon blue for buttons
  static const Color neonRed = Color(0xFFFF3B30); // Neon red for buttons
  static const Color neonGreen = Color(0xFF27AE60);
  static const Color lightBackground = Color(0xFFE8EAED); // Premium metallic base
  static const Color cardBackground = Color(0xFFF1F3F6); // Lighter metallic silver
  static const Color surfaceColor = Color(0xFFCFD8DC); // Darker metallic surface
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color accentGold = Color(0xFFFFB300);

  // Gradients - Premium 3D Metallic
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryEmerald, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFFE8EAED), // Metallic silver
      Color(0xFFCFD8DC), // Darker metallic
      Color(0xFFB0BEC5), // Even darker metallic
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFFF8F9FA), // Light metallic
      Color(0xFFE8EAED), // Mid metallic
      Color(0xFFCFD8DC), // Darker metallic
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // Premium Metallic Button Gradients
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [
      Color(0xFFF1F3F6), // Light metallic top
      Color(0xFFE8EAED), // Mid metallic
      Color(0xFFCFD8DC), // Dark metallic bottom
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.4, 1.0],
  );

  // Premium Selected Button Gradient (Gold/Bronze accent)
  static const LinearGradient selectedButtonGradient = LinearGradient(
    colors: [
      Color(0xFFFFD54F), // Warm gold top
      Color(0xFFFFB300), // Rich gold
      Color(0xFFF57F17), // Deep amber bottom
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // Premium Inactive Button Gradient (Subtle metallic)
  static const LinearGradient inactiveButtonGradient = LinearGradient(
    colors: [
      Color(0xFFF8F9FA), // Very light metallic
      Color(0xFFE3E9ED), // Light metallic
      Color(0xFFD1DCE2), // Medium metallic
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  // Alternative Premium Selected (Blue-Steel accent)
  static const LinearGradient blueAccentGradient = LinearGradient(
    colors: [
      Color(0xFF90CAF9), // Light blue steel
      Color(0xFF42A5F5), // Medium blue steel
      Color(0xFF1976D2), // Deep blue steel
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // Alternative Premium Selected (Rose-Gold accent)
  static const LinearGradient roseAccentGradient = LinearGradient(
    colors: [
      Color(0xFFF8BBD9), // Light rose gold
      Color(0xFFF06292), // Medium rose gold
      Color(0xFFE91E63), // Deep rose gold
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // Premium 3D Metallic Shadows
  static List<BoxShadow> get metallicShadow => [
    BoxShadow(
      color: Colors.white.withOpacity(0.9),
      blurRadius: 8,
      spreadRadius: -2,
      offset: const Offset(-3, -3),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      spreadRadius: 1,
      offset: const Offset(4, 4),
    ),
    BoxShadow(
      color: Color(0xFFB0BEC5).withOpacity(0.5),
      blurRadius: 6,
      spreadRadius: 0,
      offset: const Offset(2, 2),
    ),
  ];

  // Enhanced Selected Button Shadow (Gold glow)
  static List<BoxShadow> get selectedButtonShadow => [
    BoxShadow(
      color: Colors.white.withOpacity(0.9),
      blurRadius: 6,
      spreadRadius: -1,
      offset: const Offset(-2, -2),
    ),
    BoxShadow(
      color: Color(0xFFFFB300).withOpacity(0.4),
      blurRadius: 12,
      spreadRadius: 2,
      offset: const Offset(0, 0),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 8,
      spreadRadius: 1,
      offset: const Offset(3, 3),
    ),
  ];

  // Subtle Inactive Button Shadow
  static List<BoxShadow> get inactiveButtonShadow => [
    BoxShadow(
      color: Colors.white.withOpacity(0.7),
      blurRadius: 4,
      spreadRadius: -1,
      offset: const Offset(-2, -2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 6,
      spreadRadius: 0,
      offset: const Offset(2, 2),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.white.withOpacity(0.8),
      blurRadius: 6,
      offset: const Offset(-2, -2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 10,
      offset: const Offset(3, 3),
    ),
    BoxShadow(
      color: Color(0xFF90A4AE).withOpacity(0.3),
      blurRadius: 4,
      offset: const Offset(1, 1),
    ),
  ];

  // Premium Button Decorations
  static BoxDecoration get metallicButtonDecoration => BoxDecoration(
    gradient: buttonGradient,
    borderRadius: buttonRadius,
    boxShadow: inactiveButtonShadow,
    border: Border.all(
      color: Color(0xFFB0BEC5).withOpacity(0.3),
      width: 1,
    ),
  );

  static BoxDecoration get selectedButtonDecoration => BoxDecoration(
    gradient: selectedButtonGradient,
    borderRadius: buttonRadius,
    boxShadow: selectedButtonShadow,
    border: Border.all(
      color: Color(0xFFFFB300).withOpacity(0.6),
      width: 2,
    ),
  );

  static BoxDecoration get inactiveButtonDecoration => BoxDecoration(
    gradient: inactiveButtonGradient,
    borderRadius: buttonRadius,
    boxShadow: inactiveButtonShadow,
    border: Border.all(
      color: Color(0xFFCFD8DC).withOpacity(0.4),
      width: 1,
    ),
  );

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
        color: primaryEmerald.withOpacity(0.5),
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
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBackground,
      cardColor: cardBackground,
      textTheme: TextTheme(
        displayLarge: headlineStyle,
        displayMedium: titleStyle,
        headlineLarge: scoreStyle,
        bodyLarge: bodyStyle,
        bodyMedium: captionStyle,
        labelLarge: buttonStyle,
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryEmerald,
        surface: cardBackground,
        background: lightBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
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
          backgroundColor: Colors.transparent,
          foregroundColor: textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: buttonStyle.copyWith(color: textPrimary),
        ).copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
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
          borderSide: const BorderSide(color: primaryEmerald, width: 2),
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
