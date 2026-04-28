// lib/core/constants/app_animations.dart

abstract class AppAnimations {
  // ─── ARSA Robot ─────────────────────────────────────────────────────────
  /// Robot ARSA idle — diputar loop di halaman analitik & insight card
  static const String arsaIdle = 'assets/animations/arsa_idle.json';

  /// ARSA sedang "berpikir" — tampil saat request ke AI sedang berjalan
  static const String arsaThinking = 'assets/animations/arsa_thinking.json';

  /// ARSA melambaikan tangan — greeting saat pertama buka analitik
  static const String arsaWave = 'assets/animations/arsa_wave.json';

  // ─── Feedback & Status ──────────────────────────────────────────────────
  /// Centang sukses setelah transaksi berhasil disimpan
  static const String success = 'assets/animations/success_check.json';

  /// Loading spinner bertema keuangan (koin berputar, dll)
  static const String loading = 'assets/animations/loading_coin.json';

  /// Animasi konfeti untuk goal tercapai
  static const String confetti = 'assets/animations/confetti.json';

  // ─── Empty State ────────────────────────────────────────────────────────
  /// Ilustrasi belum ada transaksi (dompet kosong)
  static const String emptyWallet = 'assets/animations/empty_wallet.json';

  /// Ilustrasi belum ada target keuangan
  static const String emptyGoal = 'assets/animations/empty_goal.json';

  // ─── Onboarding ─────────────────────────────────────────────────────────
  static const String onboardingFinance =
      'assets/animations/onboarding_finance.json';

  // ─── Panduan pengunduhan Lottie ─────────────────────────────────────────
  // Rekomendasi sumber: https://lottiefiles.com
  // Kata kunci pencarian yang direkomendasikan:
  //   - "robot wave flat"         → arsa_wave
  //   - "robot thinking"          → arsa_thinking
  //   - "success check green"     → success_check
  //   - "coin loading"            → loading_coin
  //   - "confetti celebration"    → confetti
  //   - "empty wallet"            → empty_wallet
  // Pastikan ukuran file < 100KB per animasi untuk performa optimal.
}
