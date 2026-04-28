import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/core/utils/app_router.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_event.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_state.dart';
import 'package:sakupintar/presentation/widgets/common/app_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field harus diisi'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password tidak cocok'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      RegisterRequested(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.error != curr.error || prev.user != curr.user,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.expense,
            ),
          );
        } else if (state.user != null) {
          final user = state.user!;
          if (user.nickname == null ||
              user.school == null ||
              user.primaryGoal == null) {
            context.go(Routes.onboarding);
          } else {
            context.go(Routes.dashboard);
          }
        }
      },
      child: Scaffold(
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
              // Decorative background 1
              Positioned(
                top: -50,
                right: -50,
                child: Opacity(
                  opacity: 0.6,
                  child:
                      Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            duration: 4.seconds,
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.1, 1.1),
                          ),
                ),
              ),
              // Decorative background 2
              Positioned(
                bottom: -80,
                left: -40,
                child: Opacity(
                  opacity: 0.5,
                  child:
                      Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(60),
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat())
                          .rotate(duration: 12.seconds),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button & Title
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.textPrimary,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(width: 8),
                          Text(
                            'Buat Akun',
                            style: AppTypography.displayMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              letterSpacing: -0.5,
                            ),
                          ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Daftar sekarang untuk memulai perjalanan finansialmu bersama ARSA.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

                      const SizedBox(height: 40),

                      // Glassmorphism Card for Form
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.cardRadius,
                              ),
                              border: Border.all(
                                color: AppColors.surface.withOpacity(0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppTextField(
                                      label: 'Email Siswa',
                                      hint: 'nama@sekolah.id',
                                      icon: Icons.alternate_email_rounded,
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                    )
                                    .animate()
                                    .fadeIn(delay: 500.ms)
                                    .slideY(begin: 0.1),

                                const SizedBox(height: 20),

                                AppTextField(
                                      label: 'Password',
                                      hint: '••••••••',
                                      icon: Icons.lock_outline_rounded,
                                      isPassword: true,
                                      controller: _passwordController,
                                    )
                                    .animate()
                                    .fadeIn(delay: 600.ms)
                                    .slideY(begin: 0.1),

                                const SizedBox(height: 20),

                                AppTextField(
                                      label: 'Konfirmasi Password',
                                      hint: '••••••••',
                                      icon: Icons.lock_outline_rounded,
                                      isPassword: true,
                                      controller: _confirmPasswordController,
                                    )
                                    .animate()
                                    .fadeIn(delay: 700.ms)
                                    .slideY(begin: 0.1),

                                const SizedBox(height: 32),

                                // Register Button
                                _buildRegisterButton(context),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),

                      const SizedBox(height: 32),

                      // Login Link
                      _buildLoginLink(context).animate().fadeIn(delay: 900.ms),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: state.isLoading ? null : _onRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
            child: state.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Daftar Sekarang',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ).animate().scale(delay: 800.ms);
      },
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            'Masuk sekarang',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
