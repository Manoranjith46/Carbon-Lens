import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'carbon_colors.dart';
import 'carbon_status.dart';

/// Builds the CarbonLens adaptive theme based on carbon status and brightness.
class CarbonTheme {
  CarbonTheme._();

  /// Creates a light theme for the given carbon status.
  static ThemeData light(CarbonStatus status) {
    final primary = _primaryForStatus(status, Brightness.light);
    final onPrimary = _onPrimaryForStatus(status, Brightness.light);
    final primaryContainer =
        _primaryContainerForStatus(status, Brightness.light);
    final onPrimaryContainer =
        _onPrimaryContainerForStatus(status, Brightness.light);

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: CarbonColors.tealPrimary,
      onSecondary: CarbonColors.onTealLight,
      secondaryContainer: CarbonColors.tealContainer,
      onSecondaryContainer: CarbonColors.tealContainerText,
      tertiary: CarbonColors.warningLight,
      onTertiary: CarbonColors.onWarningLight,
      tertiaryContainer: CarbonColors.warningContainerLight,
      onTertiaryContainer: CarbonColors.warningTextLight,
      error: CarbonColors.redPrimary,
      onError: CarbonColors.onRedLight,
      errorContainer: CarbonColors.redContainer,
      onErrorContainer: CarbonColors.redContainerText,
      surface: CarbonColors.surfaceLight,
      onSurface: CarbonColors.textPrimaryLight,
      surfaceContainerHighest: CarbonColors.surfaceSubtleLight,
      outline: CarbonColors.borderLight,
      outlineVariant: CarbonColors.dividerLight,
      shadow: Colors.black.withValues(alpha: 0.08),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: CarbonColors.backgroundLight,
      textTheme: _textTheme(CarbonColors.textPrimaryLight),
      appBarTheme: AppBarTheme(
        backgroundColor: CarbonColors.backgroundLight,
        foregroundColor: CarbonColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CarbonColors.textPrimaryLight,
        ),
      ),
      cardTheme: CardThemeData(
        color: CarbonColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: CarbonColors.borderLight, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CarbonColors.textPrimaryLight,
          side: BorderSide(color: CarbonColors.borderLight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CarbonColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CarbonColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CarbonColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: CarbonColors.textMutedLight,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: CarbonColors.surfaceLight,
        indicatorColor: primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        elevation: 0,
        height: 72,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CarbonColors.surfaceLight,
        selectedItemColor: primary,
        unselectedItemColor: CarbonColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: CarbonColors.surfaceElevatedLight,
        selectedColor: primaryContainer,
        labelStyle: GoogleFonts.inter(fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide(color: CarbonColors.borderLight),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dividerTheme: DividerThemeData(
        color: CarbonColors.dividerLight,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CarbonColors.textPrimaryLight,
        contentTextStyle: GoogleFonts.inter(
          color: CarbonColors.surfaceLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Creates a dark theme for the given carbon status.
  static ThemeData dark(CarbonStatus status) {
    final primary = _primaryForStatus(status, Brightness.dark);
    final onPrimary = _onPrimaryForStatus(status, Brightness.dark);
    final primaryContainer =
        _primaryContainerForStatus(status, Brightness.dark);
    final onPrimaryContainer =
        _onPrimaryContainerForStatus(status, Brightness.dark);

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: CarbonColors.tealPrimaryDark,
      onSecondary: CarbonColors.onTealDark,
      secondaryContainer: CarbonColors.tealContainerDark,
      onSecondaryContainer: CarbonColors.tealContainerTextDark,
      tertiary: CarbonColors.warningDark,
      onTertiary: CarbonColors.onWarningDark,
      tertiaryContainer: CarbonColors.warningContainerDark,
      onTertiaryContainer: CarbonColors.warningTextDark,
      error: CarbonColors.redPrimaryDark,
      onError: CarbonColors.onRedDark,
      errorContainer: CarbonColors.redContainerDark,
      onErrorContainer: CarbonColors.redContainerTextDark,
      surface: CarbonColors.surfaceDark,
      onSurface: CarbonColors.textPrimaryDark,
      surfaceContainerHighest: CarbonColors.surfaceSubtleDark,
      outline: CarbonColors.borderDark,
      outlineVariant: CarbonColors.dividerDark,
      shadow: Colors.black.withValues(alpha: 0.3),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: CarbonColors.backgroundDark,
      textTheme: _textTheme(CarbonColors.textPrimaryDark),
      appBarTheme: AppBarTheme(
        backgroundColor: CarbonColors.backgroundDark,
        foregroundColor: CarbonColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CarbonColors.textPrimaryDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: CarbonColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: CarbonColors.borderDark, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CarbonColors.textPrimaryDark,
          side: BorderSide(color: CarbonColors.borderDark),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CarbonColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CarbonColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: CarbonColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: CarbonColors.textMutedDark,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: CarbonColors.surfaceDark,
        indicatorColor: primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        elevation: 0,
        height: 72,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CarbonColors.surfaceDark,
        selectedItemColor: primary,
        unselectedItemColor: CarbonColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: CarbonColors.surfaceElevatedDark,
        selectedColor: primaryContainer,
        labelStyle: GoogleFonts.inter(fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide(color: CarbonColors.borderDark),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dividerTheme: DividerThemeData(
        color: CarbonColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CarbonColors.surfaceElevatedDark,
        contentTextStyle: GoogleFonts.inter(
          color: CarbonColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Primary colour selection ───────────────────────────

  static Color _primaryForStatus(CarbonStatus status, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    switch (status) {
      case CarbonStatus.neutral:
        return isLight ? CarbonColors.tealPrimary : CarbonColors.tealPrimaryDark;
      case CarbonStatus.safe:
      case CarbonStatus.nearLimit:
        return isLight
            ? CarbonColors.greenPrimary
            : CarbonColors.greenPrimaryDark;
      case CarbonStatus.overLimit:
        return isLight ? CarbonColors.redPrimary : CarbonColors.redPrimaryDark;
    }
  }

  static Color _onPrimaryForStatus(
      CarbonStatus status, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    switch (status) {
      case CarbonStatus.neutral:
        return isLight ? CarbonColors.onTealLight : CarbonColors.onTealDark;
      case CarbonStatus.safe:
      case CarbonStatus.nearLimit:
        return isLight ? CarbonColors.onGreenLight : CarbonColors.onGreenDark;
      case CarbonStatus.overLimit:
        return isLight ? CarbonColors.onRedLight : CarbonColors.onRedDark;
    }
  }

  static Color _primaryContainerForStatus(
      CarbonStatus status, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    switch (status) {
      case CarbonStatus.neutral:
        return isLight
            ? CarbonColors.tealContainer
            : CarbonColors.tealContainerDark;
      case CarbonStatus.safe:
      case CarbonStatus.nearLimit:
        return isLight
            ? CarbonColors.greenContainer
            : CarbonColors.greenContainerDark;
      case CarbonStatus.overLimit:
        return isLight
            ? CarbonColors.redContainer
            : CarbonColors.redContainerDark;
    }
  }

  static Color _onPrimaryContainerForStatus(
      CarbonStatus status, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    switch (status) {
      case CarbonStatus.neutral:
        return isLight
            ? CarbonColors.tealContainerText
            : CarbonColors.tealContainerTextDark;
      case CarbonStatus.safe:
      case CarbonStatus.nearLimit:
        return isLight
            ? CarbonColors.greenContainerText
            : CarbonColors.greenContainerTextDark;
      case CarbonStatus.overLimit:
        return isLight
            ? CarbonColors.redContainerText
            : CarbonColors.redContainerTextDark;
    }
  }

  // ─── Typography ────────────────────────────────────────

  static TextTheme _textTheme(Color baseColor) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.5,
      ),
    );
  }
}
