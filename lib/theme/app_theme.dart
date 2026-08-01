import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color tokens lifted directly from
/// for_claude/stitch_safezone_family_safety_app/safezone/DESIGN.md, so the
/// app matches the "Refined Minimalism" mockups pixel-for-pixel in hue.
class SafeZoneColors {
  SafeZoneColors._();

  static const surface = Color(0xFFFBF9F9);
  static const surfaceDim = Color(0xFFDBDAD9);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF5F3F3);
  static const surfaceContainer = Color(0xFFEFEDED);
  static const surfaceContainerHigh = Color(0xFFE9E8E7);
  static const surfaceContainerHighest = Color(0xFFE3E2E2);

  static const onSurface = Color(0xFF1B1C1C);
  static const onSurfaceVariant = Color(0xFF504536);
  static const outline = Color(0xFF827563);
  static const outlineVariant = Color(0xFFD4C4B0);

  static const primary = Color(0xFF7F5700);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFE5A93D);
  static const onPrimaryContainer = Color(0xFF5E4000);

  static const secondary = Color(0xFF5F5E5E);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFE2DFDE);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const success = Color(0xFF2E7D32);
  static const cardBorder = Color(0xFFEEEEEE);
  static const neutralAccent = Color(0xFFBDBDBD);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SafeZoneColors.primaryContainer,
        brightness: Brightness.light,
        primary: SafeZoneColors.primary,
        onPrimary: SafeZoneColors.onPrimary,
        primaryContainer: SafeZoneColors.primaryContainer,
        onPrimaryContainer: SafeZoneColors.onPrimaryContainer,
        secondary: SafeZoneColors.secondary,
        onSecondary: SafeZoneColors.onSecondary,
        secondaryContainer: SafeZoneColors.secondaryContainer,
        surface: SafeZoneColors.surface,
        onSurface: SafeZoneColors.onSurface,
        error: SafeZoneColors.error,
        onError: SafeZoneColors.onError,
        errorContainer: SafeZoneColors.errorContainer,
        onErrorContainer: SafeZoneColors.onErrorContainer,
        outline: SafeZoneColors.outline,
        outlineVariant: SafeZoneColors.outlineVariant,
      ),
      scaffoldBackgroundColor: SafeZoneColors.surface,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: SafeZoneColors.onSurface,
        displayColor: SafeZoneColors.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: SafeZoneColors.surface.withValues(alpha: 0.8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: SafeZoneColors.onSurface,
      ),
      cardTheme: const CardThemeData(
        color: SafeZoneColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: SafeZoneColors.cardBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SafeZoneColors.primaryContainer,
          foregroundColor: SafeZoneColors.onPrimaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
