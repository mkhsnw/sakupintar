// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

abstract class AppColors {
  // ─── Brand Palette ──────────────────────────────────────────────────────
  /// Primary: Biru elektrik — CTA utama, AppBar, tombol primer
  static const Color primary = Color(0xFF2962FF);
  static const Color primaryLight = Color(0xFF768FFF);
  static const Color primaryDark = Color(0xFF0039CB);
  static const Color primaryContainer = Color(0xFFE8EDFF);

  /// Secondary: Teal — income, konfirmasi, progress positif
  static const Color secondary = Color(0xFF00BFA5);
  static const Color secondaryLight = Color(0xFF5DF2D6);
  static const Color secondaryDark = Color(0xFF008E76);
  static const Color secondaryContainer = Color(0xFFE0FAF6);

  /// Tertiary: Amber — warning, saving, goal highlight
  static const Color tertiary = Color(0xFFFFAB40);
  static const Color tertiaryLight = Color(0xFFFFDD71);
  static const Color tertiaryDark = Color(0xFFC77C02);
  static const Color tertiaryContainer = Color(0xFFFFF3E0);

  // ─── Neutral / Surface ──────────────────────────────────────────────────
  /// Neutral utama — untuk teks sekunder, ikon disabled, subtitle
  static const Color neutral = Color(0xFF73739E);
  static const Color neutralLight = Color(0xFFA3A3C2);
  static const Color neutralDark = Color(0xFF44446F);
  static const Color neutralContainer = Color(0xFFF0F0F8);

  // ─── Semantic ───────────────────────────────────────────────────────────
  static const Color income = secondary;
  static const Color expense = Color(0xFFFF5252);
  static const Color saving = tertiary;
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = secondary;

  // ─── Background & Surface ───────────────────────────────────────────────
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F8);
  static const Color cardBorder = Color(0xFFE8E8F0);

  // ─── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A3E);
  static const Color textSecondary = Color(0xFF73739E);
  static const Color textDisabled = Color(0xFFB0B0CC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Category Colors (untuk chart & ikon kategori) ──────────────────────
  static const List<Color> categoryPalette = [
    Color(0xFFFF5252), // Jajan
    Color(0xFF2962FF), // Transportasi
    Color(0xFFFFAB40), // Alat Tulis
    Color(0xFF7C4DFF), // Hiburan & Kuota
    Color(0xFF00BFA5), // Tabungan
    Color(0xFF73739E), // Lainnya
  ];

  // ─── ARSA / AI Accent ───────────────────────────────────────────────────
  /// Warna khusus untuk elemen ARSA agar terasa "AI" dan berbeda
  static const Color arsaPrimary = Color(0xFF651FFF);
  static const Color arsaSecondary = Color(0xFFE040FB);
  static const LinearGradient arsaGradient = LinearGradient(
    colors: [Color(0xFF651FFF), Color(0xFF2962FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2962FF), Color(0xFF768FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF5DF2D6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFFF8A80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
