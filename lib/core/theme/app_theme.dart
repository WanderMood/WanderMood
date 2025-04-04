import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF5C6BC0);
  static const Color secondary = Color(0xFF81C784);
  static const Color accent = Color(0xFFFFB74D);
  static const Color background = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF333333);
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF4CAF50);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;

  // Mood Colors
  static const Color happy = Color(0xFFFFD700);
  static const Color relaxed = Color(0xFF98FB98);
  static const Color energetic = Color(0xFFFF4500);
  static const Color melancholic = Color(0xFF4682B4);

  // Typography
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: text,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: text,
    ),
    bodyLarge: GoogleFonts.roboto(
      fontSize: 16.0,
      color: text,
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14.0,
      color: text,
    ),
  );

  // Button Styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingLG,
      vertical: spacingMD,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );

  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: secondary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: spacingLG,
      vertical: spacingMD,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );

  // Input Decoration
  static InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: error),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: spacingMD,
      vertical: spacingMD,
    ),
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF12B347),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }

  static ThemeData darkTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      background: const Color(0xFF121212),
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
    ),
    textTheme: textTheme,
    useMaterial3: true,
  );

  static BoxDecoration get backgroundGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFDF5), // Warm cream yellow
          Color(0xFFFFF3E0), // Slightly darker warm yellow
        ],
      ),
    );
  }
} 