import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_event.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  String _selectedGoal = '';

  final List<Map<String, dynamic>> _goals = [
    {
      'id': 'Menabung',
      'title': 'Menabung',
      'icon': Icons.savings,
      'color': AppColors.primary,
      'desc': 'Fokus menyimpan uang',
    },
    {
      'id': 'Mengatur Jajan',
      'title': 'Mengatur Jajan',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFF00BFA5),
      'desc': 'Kontrol pengeluaran harian',
    },
    {
      'id': 'Investasi',
      'title': 'Investasi',
      'icon': Icons.trending_up,
      'color': const Color(0xFFFFAB40),
      'desc': 'Persiapan masa depan',
    },
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      _nameController.text = user.nickname ?? '';
      _schoolController.text = user.school ?? '';
      _selectedGoal = user.primaryGoal ?? 'Menabung';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedGoal.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pilih salah satu tujuan keuanganmu!'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      context.read<AuthBloc>().add(
        UpdateProfileRequested(
          nickname: _nameController.text,
          school: _schoolController.text,
          primaryGoal: _selectedGoal,
        ),
      );
    }
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
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.sm),
        TextFormField(
          controller: controller,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.neutral,
            ),
            suffixIcon: Icon(
              suffixIcon,
              color: isSearchIcon ? AppColors.neutral : AppColors.primary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.md,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label tidak boleh kosong';
            }
            if (value.trim().length < 3) {
              return '$label minimal 3 karakter';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGoalOption(Map<String, dynamic> goal, bool isLarge) {
    final isSelected = _selectedGoal == goal['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = goal['id'];
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: isLarge ? double.infinity : null,
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryContainer
                        : goal['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                  ),
                  child: Icon(
                    goal['icon'],
                    color: isSelected ? AppColors.primary : goal['color'],
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
                          ? AppColors.primary
                          : AppColors.neutralContainer,
                      width: 2,
                    ),
                    color: isSelected
                        ? AppColors.primary
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.surface,
                        )
                      : null,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              goal['title'],
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              goal['desc'],
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!state.isLoading && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (!state.isLoading && state.error == null && state.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profil berhasil diperbarui!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Edit Profil',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      label: 'Nama Panggilan',
                      hint: 'Misal: Budi',
                      suffixIcon: Icons.person,
                      controller: _nameController,
                    ),
                    SizedBox(height: AppDimensions.lg),
                    _buildTextField(
                      label: 'Asal Sekolah',
                      hint: 'Misal: SMA Negeri 1',
                      controller: _schoolController,
                      isSearchIcon: true,
                      suffixIcon: Icons.school,
                    ),
                    SizedBox(height: AppDimensions.xl),
                    Text(
                      'Tujuan Utama',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Pilih satu yang paling penting buatmu',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.md),
                    _buildGoalOption(
                      _goals[0],
                      true,
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
                    SizedBox(height: AppDimensions.md),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGoalOption(
                            _goals[1],
                            false,
                          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                        ),
                        SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: _buildGoalOption(
                            _goals[2],
                            false,
                          ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.xxl),
                    
                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _saveProfile,
                        child: state.isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.surface,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Simpan Perubahan',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
