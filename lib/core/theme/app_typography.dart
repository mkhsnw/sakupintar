// lib/core/theme/app_typography.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTypography {
  // ─── Font Family ────────────────────────────────────────────────────────
  /// Fallback ke google_fonts jika font lokal belum di-download.
  static TextStyle _base({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  // ─── Display ────────────────────────────────────────────────────────────
  static TextStyle get displayLarge => _base(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => _base(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  );

  // ─── Headline ───────────────────────────────────────────────────────────
  static TextStyle get headlineLarge =>
      _base(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3);

  static TextStyle get headlineMedium =>
      _base(fontSize: 18, fontWeight: FontWeight.w600, height: 1.35);

  static TextStyle get headlineSmall =>
      _base(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);

  // ─── Title ──────────────────────────────────────────────────────────────
  static TextStyle get titleLarge =>
      _base(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get titleMedium =>
      _base(fontSize: 14, fontWeight: FontWeight.w500, height: 1.45);

  // ─── Body ───────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge =>
      _base(fontSize: 15, fontWeight: FontWeight.w400, height: 1.6);

  static TextStyle get bodyMedium => _base(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => _base(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ─── Label ──────────────────────────────────────────────────────────────
  static TextStyle get labelLarge =>
      _base(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.1);

  static TextStyle get labelMedium => _base(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelSmall => _base(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  // ─── Special / Currency ─────────────────────────────────────────────────
  /// Untuk tampilan nominal uang — extra bold agar menonjol
  static TextStyle get currencyLarge => _base(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get currencyMedium =>
      _base(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3);

  static TextStyle get currencySmall =>
      _base(fontSize: 16, fontWeight: FontWeight.w700);

  /// Untuk chat/bubble ARSA — sedikit lebih ringan dan readable
  static TextStyle get arsaMessage => _base(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.65,
    color: AppColors.textPrimary,
  );

  // ─── ThemeData TextTheme ─────────────────────────────────────────────────
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
