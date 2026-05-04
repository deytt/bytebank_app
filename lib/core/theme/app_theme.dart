import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF4C1D95);
  static const Color primaryLight = Color(0xFF6D28D9);
  static const Color background = Color(0xFF09090B);
  static const Color surface = Color(0xFF202024);
  static const Color textPrimary = Color(0xFFE1E1E6);
  static const Color textSecondary = Color(0xFFC4C4CC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color black = Color(0xFF000000);
  static const Color googleBlue = Color(0xFF4285F4);

  // Gradient pairs used across stories and carousel items
  static const Color gradientBlueDark = Color(0xFF1E3A5F);
  static const Color gradientBlue = Color(0xFF2563EB);
  static const Color gradientGreenDark = Color(0xFF064E3B);
  static const Color gradientGreen = Color(0xFF059669);
  static const Color gradientAmberDark = Color(0xFF78350F);
  static const Color gradientAmber = Color(0xFFD97706);

  // Balance card background gradient start
  static const Color balanceSurface = Color(0xFF0D3B5E);

  // Additional chart/pie colors
  static const Color chartBlue = Color(0xFF3B82F6);
  static const Color chartAmber = Color(0xFFF59E0B);

  static const Color neutralBorder = Color(0xFF27272A);
  static const Color transactionCardFill = Color(0xFF18181B);
  static const Color transactionAppBarEnd = Color(0xFF1C1C1F);

  static const double _cardRadius = 12;

  static LinearGradient get transactionScreenBackgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0C0C0E),
          background,
        ],
      );

  static LinearGradient get transactionAppBarGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          surface,
          transactionAppBarEnd,
        ],
      );

  static BoxDecoration get transactionListItemDecoration => BoxDecoration(
        color: transactionCardFill,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: neutralBorder),
      );

  static BoxDecoration get formSectionDecoration => BoxDecoration(
        color: transactionCardFill,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: neutralBorder),
      );

  static BoxDecoration get searchFieldShellDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: neutralBorder),
      );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,

      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryLight,
        surface: surface,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontSize: 36, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontSize: 16),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textPrimary, fontSize: 14),
        bodySmall: TextStyle(color: textSecondary, fontSize: 14),
        labelMedium: TextStyle(color: textSecondary, fontSize: 16),
      ),
    );
  }
}
