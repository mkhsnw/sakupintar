// lib/core/theme/app_dimensions.dart

abstract class AppDimensions {
  // ─── Spacing (8px grid system) ──────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // ─── Page Padding ────────────────────────────────────────────────────────
  static const double pageHorizontal = 20.0;
  static const double pageVertical = 24.0;

  // ─── Border Radius ───────────────────────────────────────────────────────
  static const double radiusXs = 6.0;
  static const double radiusSm = 10.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 28.0;
  static const double radiusFull = 100.0; // pill / chip

  // ─── Card ────────────────────────────────────────────────────────────────
  static const double cardPadding = 16.0;
  static const double cardRadius = 16.0;
  static const double cardElevation = 0.0; // gunakan border, bukan shadow

  // ─── Icon Size ───────────────────────────────────────────────────────────
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // ─── Button ──────────────────────────────────────────────────────────────
  static const double buttonHeight = 52.0;
  static const double buttonHeightSm = 40.0;
  static const double buttonRadius = 14.0;

  // ─── Bottom Nav ──────────────────────────────────────────────────────────
  static const double bottomNavHeight = 72.0;

  // ─── ARSA Widget ─────────────────────────────────────────────────────────
  static const double arsaAvatarSize = 56.0;
  static const double arsaBubbleMaxWidth = 0.78; // 78% lebar layar
  static const double arsaCardRadius = 20.0;

  // ─── Chart ───────────────────────────────────────────────────────────────
  static const double chartHeight = 200.0;
  static const double donutRadius = 70.0;
  static const double donutHoleRadius = 50.0;
}
