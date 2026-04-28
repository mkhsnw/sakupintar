import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_event.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_state.dart';
import 'package:sakupintar/presentation/widgets/common/app_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();

  // "Menabung" | "Mengatur Jajan" | "Investasi"
  String? _selectedGoal;

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama panggilan harus diisi')),
      );
      return;
    }
    if (_selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih salah satu target utama')),
      );
      return;
    }
    context.read<AuthBloc>().add(
      CompleteOnboardingRequested(
        nickname: _nameController.text.trim(),
        school: _schoolController.text.trim(),
        primaryGoal: _selectedGoal!,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData suffixIcon,
    required TextEditingController controller,
    bool isSearchIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.neutralDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        TextFormField(
          controller: controller,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textDisabled,
            ),
            filled: true,
            fillColor: AppColors.primaryContainer,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 24,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: isSearchIcon
                  ? CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        suffixIcon,
                        color: AppColors.surface,
                        size: 20,
                      ),
                    )
                  : Icon(suffixIcon, color: AppColors.neutral, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalOption({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    bool isLarge = false,
  }) {
    final bool isSelected = _selectedGoal == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isLarge ? double.infinity : null,
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          gradient: isSelected && isLarge ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: isSelected
              ? null
              : Border.all(color: AppColors.cardBorder, width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: isLarge
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : iconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? AppColors.surface : iconColor,
                          size: 24,
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.surface
                                : AppColors.cardBorder,
                            width: 2,
                          ),
                          color: isSelected
                              ? AppColors.surface
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: AppTypography.titleLarge.copyWith(
                      color: isSelected
                          ? AppColors.surface
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? AppColors.surface : iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.labelLarge.copyWith(
                            color: isSelected
                                ? AppColors.surface
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading,
      listener: (context, state) {
        if (!state.isLoading) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          } else {
            context.go('/dashboard');
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Set Up Profile',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(
                right: AppDimensions.pageHorizontal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                'Step 2/3',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ARSA Chat Bubble
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Transform.scale(
                        scale: 1.2,
                        child: Lottie.asset(
                          'assets/animations/arsa_robot.json',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/image/arsa.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.smart_toy,
                                  color: AppColors.surface,
                                  size: 32,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(AppDimensions.radiusLg),
                            bottomLeft: Radius.circular(AppDimensions.radiusLg),
                            bottomRight: Radius.circular(
                              AppDimensions.radiusLg,
                            ),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: 'Halo! Aku '),
                              TextSpan(
                                text: 'Arsa',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    '. Bantu aku kenal kamu lebih dekat supaya SakuPintar bisa bantu capai mimpimu!',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.xl),

                // Inputs
                _buildTextField(
                  label: 'Nama Panggilan',
                  hint: 'Panggil kamu siapa nih?',
                  suffixIcon: Icons.person,
                  controller: _nameController,
                ),
                const SizedBox(height: AppDimensions.lg),

                _buildTextField(
                  label: 'Asal Sekolah',
                  hint: 'Cari sekolahmu di sini...',
                  suffixIcon: Icons.search,
                  controller: _schoolController,
                  isSearchIcon: true,
                ),
                const SizedBox(height: AppDimensions.xl),

                // Target Utama
                Text(
                  'Target Utama',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.neutralDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pilih satu yang paling penting buatmu',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                // Options
                _buildGoalOption(
                  title: 'Menabung',
                  value: 'Menabung',
                  icon: Icons.savings,
                  iconBgColor: AppColors.primaryContainer,
                  iconColor: AppColors.primary,
                  isLarge: true,
                ),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  children: [
                    Expanded(
                      child: _buildGoalOption(
                        title: 'Mengatur Jajan',
                        value: 'Mengatur Jajan',
                        icon: Icons.account_balance_wallet,
                        iconBgColor: const Color(0xFFE0FAF6), // light teal
                        iconColor: const Color(0xFF00BFA5),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: _buildGoalOption(
                        title: 'Investasi',
                        value: 'Investasi',
                        icon: Icons.trending_up,
                        iconBgColor: const Color(0xFFFFF3E0), // light orange
                        iconColor: const Color(0xFFFFAB40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.xxl),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AppButton(
                      text: 'Selesai & Mulai',
                      isLoading: state.isLoading,
                      onPressed: _submit,
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
