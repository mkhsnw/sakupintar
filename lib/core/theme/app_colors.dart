import 'package:flutter/material.dart';

abstract class AppColors {
  // ─── Blue Theme Palette (Lebih Colorful) ────────────────────────────────
  static const Color _bluePrimary = Color(0xFF2979FF);
  static const Color _bluePrimaryLight = Color(0xFF75A7FF);
  static const Color _bluePrimaryDark = Color(0xFF004BA0);
  static const Color _bluePrimaryContainer = Color(0xFFE3EDFF);

  static const Color _blueSecondary = Color(0xFF00BFA5);
  static const Color _blueSecondaryLight = Color(0xFF5DF2D6);
  static const Color _blueSecondaryDark = Color(0xFF008E76);
  static const Color _blueSecondaryContainer = Color(0xFFE0FAF6);

  static const Color _blueTertiary = Color(0xFFFFAB40);
  static const Color _blueTertiaryLight = Color(0xFFFFDD71);
  static const Color _blueTertiaryDark = Color(0xFFC77C02);
  static const Color _blueTertiaryContainer = Color(0xFFFFF3E0);

  static const Color _blueBackground = Color(0xFFF0F4FF); // Tint biru muda
  static const Color _blueSurface = Color(0xFFFFFFFF);
  static const Color _blueSurfaceVariant = Color(0xFFE6EFFF);
  static const Color _blueCardBorder = Color(0xFFD2E3FC);

  // ─── Pink Theme Palette (Lebih Pinky / Hot Pink) ─────────────────────────
  static const Color _pinkPrimary = Color(0xFFFF69B4); // Hot Pink (benar-benar pink)
  static const Color _pinkPrimaryLight = Color(0xFFFF99CC);
  static const Color _pinkPrimaryDark = Color(0xFFC2185B);
  static const Color _pinkPrimaryContainer = Color(0xFFFFE4F2);

  static const Color _pinkSecondary = Color(0xFF00E5FF); // Cyan cerah
  static const Color _pinkSecondaryLight = Color(0xFF84FFFF);
  static const Color _pinkSecondaryDark = Color(0xFF00B0FF);
  static const Color _pinkSecondaryContainer = Color(0xFFE0F7FA);

  static const Color _pinkTertiary = Color(0xFFFFC400); // Amber Cerah
  static const Color _pinkTertiaryLight = Color(0xFFFFDF5D);
  static const Color _pinkTertiaryDark = Color(0xFFC79400);
  static const Color _pinkTertiaryContainer = Color(0xFFFFF8E1);

  static const Color _pinkBackground = Color(0xFFFFF0F5); // Lavender Blush (pink sangat muda)
  static const Color _pinkSurface = Color(0xFFFFFFFF);
  static const Color _pinkSurfaceVariant = Color(0xFFFFE4EE);
  static const Color _pinkCardBorder = Color(0xFFFFD1E3);

  // ─── Brand Palette (Dynamic Variables) ──────────────────────────────────
  static Color primary = _bluePrimary;
  static Color primaryLight = _bluePrimaryLight;
  static Color primaryDark = _bluePrimaryDark;
  static Color primaryContainer = _bluePrimaryContainer;

  static Color secondary = _blueSecondary;
  static Color secondaryLight = _blueSecondaryLight;
  static Color secondaryDark = _blueSecondaryDark;
  static Color secondaryContainer = _blueSecondaryContainer;

  static Color tertiary = _blueTertiary;
  static Color tertiaryLight = _blueTertiaryLight;
  static Color tertiaryDark = _blueTertiaryDark;
  static Color tertiaryContainer = _blueTertiaryContainer;

  // ─── Background & Surface (Dynamic Variables) ───────────────────────────
  static Color background = _blueBackground;
  static Color surface = _blueSurface;
  static Color surfaceVariant = _blueSurfaceVariant;
  static Color cardBorder = _blueCardBorder;

  // ─── Neutral / Surface (Static Const) ───────────────────────────────────
  static const Color neutral = Color(0xFF73739E);
  static const Color neutralLight = Color(0xFFA3A3C2);
  static const Color neutralDark = Color(0xFF44446F);
  static const Color neutralContainer = Color(0xFFF0F0F8);

  // ─── Semantic (Dynamic Getters) ─────────────────────────────────────────
  static Color get income => secondary;
  static Color get success => secondary;
  static Color get saving => tertiary;

  static const Color expense = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFD32F2F);

  // ─── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A3E);
  static const Color textSecondary = Color(0xFF73739E);
  static const Color textDisabled = Color(0xFFB0B0CC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Category Colors (untuk chart & ikon kategori) ──────────────────────
  static List<Color> get categoryPalette => [
    const Color(0xFFFF5252), // Jajan
    primary, // Transportasi
    tertiary, // Alat Tulis
    const Color(0xFF7C4DFF), // Hiburan & Kuota
    secondary, // Tabungan
    neutral, // Lainnya
  ];

  // ─── ARSA / AI Accent ───────────────────────────────────────────────────
  static const Color arsaPrimary = Color(0xFF651FFF);
  static const Color arsaSecondary = Color(0xFFE040FB);
  static const LinearGradient arsaGradient = LinearGradient(
    colors: [Color(0xFF651FFF), Color(0xFF2962FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Gradients (Dynamic Variables) ──────────────────────────────────────
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [_bluePrimary, _bluePrimaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient incomeGradient = const LinearGradient(
    colors: [_blueSecondary, _blueSecondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFFF8A80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Theme Switcher Logic ───────────────────────────────────────────────
  static void setTheme(bool isPink) {
    if (isPink) {
      primary = _pinkPrimary;
      primaryLight = _pinkPrimaryLight;
      primaryDark = _pinkPrimaryDark;
      primaryContainer = _pinkPrimaryContainer;

      secondary = _pinkSecondary;
      secondaryLight = _pinkSecondaryLight;
      secondaryDark = _pinkSecondaryDark;
      secondaryContainer = _pinkSecondaryContainer;

      tertiary = _pinkTertiary;
      tertiaryLight = _pinkTertiaryLight;
      tertiaryDark = _pinkTertiaryDark;
      tertiaryContainer = _pinkTertiaryContainer;

      background = _pinkBackground;
      surface = _pinkSurface;
      surfaceVariant = _pinkSurfaceVariant;
      cardBorder = _pinkCardBorder;

      primaryGradient = const LinearGradient(
        colors: [_pinkPrimary, _pinkPrimaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

      incomeGradient = const LinearGradient(
        colors: [_pinkSecondary, _pinkSecondaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      primary = _bluePrimary;
      primaryLight = _bluePrimaryLight;
      primaryDark = _bluePrimaryDark;
      primaryContainer = _bluePrimaryContainer;

      secondary = _blueSecondary;
      secondaryLight = _blueSecondaryLight;
      secondaryDark = _blueSecondaryDark;
      secondaryContainer = _blueSecondaryContainer;

      tertiary = _blueTertiary;
      tertiaryLight = _blueTertiaryLight;
      tertiaryDark = _blueTertiaryDark;
      tertiaryContainer = _blueTertiaryContainer;

      background = _blueBackground;
      surface = _blueSurface;
      surfaceVariant = _blueSurfaceVariant;
      cardBorder = _blueCardBorder;

      primaryGradient = const LinearGradient(
        colors: [_bluePrimary, _bluePrimaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

      incomeGradient = const LinearGradient(
        colors: [_blueSecondary, _blueSecondaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }
}
