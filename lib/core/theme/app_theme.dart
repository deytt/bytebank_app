import 'package:flutter/material.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color actionForeground;
  final Color white;
  final Color success;
  final Color error;
  final Color black;
  final Color googleBlue;
  final Color gradientBlueDark;
  final Color gradientBlue;
  final Color gradientGreenDark;
  final Color gradientGreen;
  final Color gradientAmberDark;
  final Color gradientAmber;
  final Color gradientSkyDark;
  final Color gradientSky;
  final Color gradientOrangeDark;
  final Color gradientOrange;
  final Color balanceSurface;
  final Color chartBlue;
  final Color chartAmber;
  final Color neutralBorder;
  final Color transactionCardFill;
  final Color transactionAppBarEnd;
  final Color transactionGradientTop;

  const AppThemeTokens({
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.actionForeground,
    required this.white,
    required this.success,
    required this.error,
    required this.black,
    required this.googleBlue,
    required this.gradientBlueDark,
    required this.gradientBlue,
    required this.gradientGreenDark,
    required this.gradientGreen,
    required this.gradientAmberDark,
    required this.gradientAmber,
    required this.gradientSkyDark,
    required this.gradientSky,
    required this.gradientOrangeDark,
    required this.gradientOrange,
    required this.balanceSurface,
    required this.chartBlue,
    required this.chartAmber,
    required this.neutralBorder,
    required this.transactionCardFill,
    required this.transactionAppBarEnd,
    required this.transactionGradientTop,
  });

  factory AppThemeTokens.dark() {
    return const AppThemeTokens(
      primary: Color(0xFF4C1D95),
      primaryLight: Color(0xFF6D28D9),
      background: Color(0xFF09090B),
      surface: Color(0xFF202024),
      textPrimary: Color(0xFFE1E1E6),
      textSecondary: Color(0xFFC4C4CC),
      actionForeground: Color(0xFFFFFFFF),
      white: Color(0xFFFFFFFF),
      success: Color(0xFF22C55E),
      error: Color(0xFFEF4444),
      black: Color(0xFF000000),
      googleBlue: Color(0xFF4285F4),
      gradientBlueDark: Color(0xFF1E3A5F),
      gradientBlue: Color(0xFF2563EB),
      gradientGreenDark: Color(0xFF064E3B),
      gradientGreen: Color(0xFF059669),
      gradientAmberDark: Color(0xFF78350F),
      gradientAmber: Color(0xFFD97706),
      gradientSkyDark: Color(0xFF0C4A6E),
      gradientSky: Color(0xFF0284C7),
      gradientOrangeDark: Color(0xFF7C2D12),
      gradientOrange: Color(0xFFEA580C),
      balanceSurface: Color(0xFF0D3B5E),
      chartBlue: Color(0xFF3B82F6),
      chartAmber: Color(0xFFF59E0B),
      neutralBorder: Color(0xFF27272A),
      transactionCardFill: Color(0xFF18181B),
      transactionAppBarEnd: Color(0xFF1C1C1F),
      transactionGradientTop: Color(0xFF0C0C0E),
    );
  }

  factory AppThemeTokens.light() {
    return const AppThemeTokens(
      primary: Color(0xFF4C1D95),
      primaryLight: Color(0xFF6D28D9),
      background: Color(0xFFF4F4F5),
      surface: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF18181B),
      textSecondary: Color(0xFF71717A),
      actionForeground: Color(0xFF4C1D95),
      white: Color(0xFFFFFFFF),
      success: Color(0xFF22C55E),
      error: Color(0xFFEF4444),
      black: Color(0xFF000000),
      googleBlue: Color(0xFF4285F4),
      gradientBlueDark: Color(0xFF1E3A5F),
      gradientBlue: Color(0xFF2563EB),
      gradientGreenDark: Color(0xFF064E3B),
      gradientGreen: Color(0xFF059669),
      gradientAmberDark: Color(0xFF78350F),
      gradientAmber: Color(0xFFD97706),
      gradientSkyDark: Color(0xFF0C4A6E),
      gradientSky: Color(0xFF0284C7),
      gradientOrangeDark: Color(0xFF7C2D12),
      gradientOrange: Color(0xFFEA580C),
      balanceSurface: Color(0xFFBFDBFE),
      chartBlue: Color(0xFF3B82F6),
      chartAmber: Color(0xFFF59E0B),
      neutralBorder: Color(0xFFE4E4E7),
      transactionCardFill: Color(0xFFF4F4F5),
      transactionAppBarEnd: Color(0xFFE4E4E7),
      transactionGradientTop: Color(0xFFF8FAFC),
    );
  }

  static const double _cardRadius = 12;

  LinearGradient get transactionScreenBackgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [transactionGradientTop, background],
      );

  LinearGradient get transactionAppBarGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [surface, transactionAppBarEnd],
      );

  BoxDecoration get transactionListItemDecoration => BoxDecoration(
        color: transactionCardFill,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: neutralBorder),
      );

  BoxDecoration get formSectionDecoration => BoxDecoration(
        color: transactionCardFill,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: neutralBorder),
      );

  BoxDecoration get searchFieldShellDecoration => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: neutralBorder),
      );

  @override
  AppThemeTokens copyWith({
    Color? primary,
    Color? primaryLight,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? actionForeground,
    Color? white,
    Color? success,
    Color? error,
    Color? black,
    Color? googleBlue,
    Color? gradientBlueDark,
    Color? gradientBlue,
    Color? gradientGreenDark,
    Color? gradientGreen,
    Color? gradientAmberDark,
    Color? gradientAmber,
    Color? gradientSkyDark,
    Color? gradientSky,
    Color? gradientOrangeDark,
    Color? gradientOrange,
    Color? balanceSurface,
    Color? chartBlue,
    Color? chartAmber,
    Color? neutralBorder,
    Color? transactionCardFill,
    Color? transactionAppBarEnd,
    Color? transactionGradientTop,
  }) {
    return AppThemeTokens(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      actionForeground: actionForeground ?? this.actionForeground,
      white: white ?? this.white,
      success: success ?? this.success,
      error: error ?? this.error,
      black: black ?? this.black,
      googleBlue: googleBlue ?? this.googleBlue,
      gradientBlueDark: gradientBlueDark ?? this.gradientBlueDark,
      gradientBlue: gradientBlue ?? this.gradientBlue,
      gradientGreenDark: gradientGreenDark ?? this.gradientGreenDark,
      gradientGreen: gradientGreen ?? this.gradientGreen,
      gradientAmberDark: gradientAmberDark ?? this.gradientAmberDark,
      gradientAmber: gradientAmber ?? this.gradientAmber,
      gradientSkyDark: gradientSkyDark ?? this.gradientSkyDark,
      gradientSky: gradientSky ?? this.gradientSky,
      gradientOrangeDark: gradientOrangeDark ?? this.gradientOrangeDark,
      gradientOrange: gradientOrange ?? this.gradientOrange,
      balanceSurface: balanceSurface ?? this.balanceSurface,
      chartBlue: chartBlue ?? this.chartBlue,
      chartAmber: chartAmber ?? this.chartAmber,
      neutralBorder: neutralBorder ?? this.neutralBorder,
      transactionCardFill: transactionCardFill ?? this.transactionCardFill,
      transactionAppBarEnd: transactionAppBarEnd ?? this.transactionAppBarEnd,
      transactionGradientTop: transactionGradientTop ?? this.transactionGradientTop,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return AppThemeTokens(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      actionForeground: Color.lerp(actionForeground, other.actionForeground, t)!,
      white: Color.lerp(white, other.white, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      black: Color.lerp(black, other.black, t)!,
      googleBlue: Color.lerp(googleBlue, other.googleBlue, t)!,
      gradientBlueDark: Color.lerp(gradientBlueDark, other.gradientBlueDark, t)!,
      gradientBlue: Color.lerp(gradientBlue, other.gradientBlue, t)!,
      gradientGreenDark: Color.lerp(gradientGreenDark, other.gradientGreenDark, t)!,
      gradientGreen: Color.lerp(gradientGreen, other.gradientGreen, t)!,
      gradientAmberDark: Color.lerp(gradientAmberDark, other.gradientAmberDark, t)!,
      gradientAmber: Color.lerp(gradientAmber, other.gradientAmber, t)!,
      gradientSkyDark: Color.lerp(gradientSkyDark, other.gradientSkyDark, t)!,
      gradientSky: Color.lerp(gradientSky, other.gradientSky, t)!,
      gradientOrangeDark: Color.lerp(gradientOrangeDark, other.gradientOrangeDark, t)!,
      gradientOrange: Color.lerp(gradientOrange, other.gradientOrange, t)!,
      balanceSurface: Color.lerp(balanceSurface, other.balanceSurface, t)!,
      chartBlue: Color.lerp(chartBlue, other.chartBlue, t)!,
      chartAmber: Color.lerp(chartAmber, other.chartAmber, t)!,
      neutralBorder: Color.lerp(neutralBorder, other.neutralBorder, t)!,
      transactionCardFill: Color.lerp(transactionCardFill, other.transactionCardFill, t)!,
      transactionAppBarEnd: Color.lerp(transactionAppBarEnd, other.transactionAppBarEnd, t)!,
      transactionGradientTop: Color.lerp(transactionGradientTop, other.transactionGradientTop, t)!,
    );
  }
}

class AppTheme {
  static AppThemeTokens of(BuildContext context) {
    return Theme.of(context).extension<AppThemeTokens>()!;
  }

  static ThemeData _themeData(Brightness brightness, AppThemeTokens tokens) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: tokens.primary,
            secondary: tokens.primaryLight,
            surface: tokens.surface,
            onSurface: tokens.textPrimary,
          )
        : ColorScheme.light(
            primary: tokens.primary,
            secondary: tokens.primaryLight,
            surface: tokens.surface,
            onSurface: tokens.textPrimary,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: tokens.primary,
      scaffoldBackgroundColor: tokens.background,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: tokens.textPrimary),
        titleTextStyle: TextStyle(color: tokens.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: tokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surface,
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
          borderSide: BorderSide(color: tokens.primary, width: 2),
        ),
        labelStyle: TextStyle(color: tokens.textSecondary),
        hintStyle: TextStyle(color: tokens.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: tokens.textPrimary, fontSize: 36, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: tokens.textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: tokens.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: tokens.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: tokens.textPrimary, fontSize: 16),
        bodyLarge: TextStyle(color: tokens.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: tokens.textPrimary, fontSize: 14),
        bodySmall: TextStyle(color: tokens.textSecondary, fontSize: 14),
        labelMedium: TextStyle(color: tokens.textSecondary, fontSize: 16),
      ),
      extensions: [tokens],
    );
  }

  static ThemeData get darkTheme => _themeData(Brightness.dark, AppThemeTokens.dark());

  static ThemeData get lightTheme => _themeData(Brightness.light, AppThemeTokens.light());
}
