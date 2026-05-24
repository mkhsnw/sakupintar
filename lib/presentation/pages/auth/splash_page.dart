import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/core/utils/app_router.dart';
import 'package:sakupintar/presentation/bloc/theme/theme_bloc.dart';
import 'package:sakupintar/presentation/bloc/theme/theme_event.dart';
import 'package:sakupintar/presentation/bloc/theme/theme_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Widget _buildThemeSelector(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isPink = themeState.themeType == ThemeType.pink;

        return Column(
          children: [
            Text(
              'PILIH TEMA',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(
                  color: AppColors.cardBorder.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Blue Theme Option
                  _buildThemeOption(
                    context: context,
                    label: 'Biru',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2979FF), Color(0xFF64B5F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    isSelected: !isPink,
                    onTap: () {
                      context.read<ThemeBloc>().add(const ChangeTheme(ThemeType.blue));
                    },
                  ),
                  const SizedBox(width: 4),
                  // Pink Theme Option
                  _buildThemeOption(
                    context: context,
                    label: 'Pink',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF69B4), Color(0xFFFF99CC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    isSelected: isPink,
                    onTap: () {
                      context.read<ThemeBloc>().add(const ChangeTheme(ThemeType.pink));
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required Gradient gradient,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (gradient as LinearGradient).colors.first.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan gradasi lembut sesuai referensi gambar
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
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
                    Spacer(flex: 2),

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

                    SizedBox(height: 40),

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

                    SizedBox(height: 12),

                    Text(
                      'Kelola Uang Sakumu dengan Cerdas Bersama Arsa',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.8),
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                    Spacer(flex: 2),

                    // Theme Selector
                    _buildThemeSelector(context)
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.2),

                    SizedBox(height: 24),

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
                                gradient: AppColors.primaryGradient,
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
                                  'Mulai Sekarang',
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