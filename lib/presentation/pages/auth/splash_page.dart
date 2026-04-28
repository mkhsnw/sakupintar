import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/core/utils/app_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan gradasi lembut sesuai referensi gambar
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryContainer,
              AppColors.primaryContainer,
              AppColors.secondaryContainer,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Dekorasi elemen geometris transparan (mirip gambar)
            Positioned(
              top: 80,
              left: 60,
              child: Opacity(
                opacity: 0.4,
                child:
                    Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(60),
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat())
                        .rotate(duration: 10.seconds),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo SakuPintar & Icon Wallet Center (Glassmorphism)
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect di belakang karakter
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.05),
                            ),
                          ).animate().scale(
                            duration: 1.seconds,
                            curve: Curves.easeOut,
                          ),

                          // ARSA Character
                          Image.asset('assets/image/arsa.png', height: 200)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .slideY(
                                begin: 0,
                                end: -0.03,
                                duration: 2.seconds,
                                curve: Curves.easeInOut,
                              ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title & Description
                    Text(
                      'SakuPintar',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 48,
                        letterSpacing: -1.5,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),

                    const SizedBox(height: 12),

                    Text(
                      'Kelola Uang Sakumu dengan Cerdas Bersama Arsa',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.8),
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                    const Spacer(flex: 3),

                    // Glassmorphism Button "Get Started"
                    ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              width: double.infinity,
                              height: 65,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2962FF), // Primary Anda
                                    Color(0xFF64B5F6), // Variasi Biru Terang
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => context.go(Routes.login),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusFull,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Get Started',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .slideY(
                          begin: 0.5,
                          curve: Curves.easeOutBack,
                          delay: 500.ms,
                        )
                        .fadeIn(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
