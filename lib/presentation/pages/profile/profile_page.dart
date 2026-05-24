import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/core/utils/app_router.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_event.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_state.dart';
import 'package:sakupintar/presentation/bloc/theme/theme_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() => _isUploadingPhoto = true);

      if (mounted) {
        context.read<AuthBloc>().add(UpdateProfilePhoto(file: File(image.path)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
        );
      }
    }
  }

  void _showPhotoPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                ),
                SizedBox(height: AppDimensions.lg),
                Text(
                  'Ubah Foto Profil',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppDimensions.lg),
                Row(
                  children: [
                    Expanded(
                      child: _buildPhotoOptionCard(
                        icon: Icons.camera_alt_rounded,
                        label: 'Kamera',
                        color: AppColors.primary,
                        bgColor: AppColors.primaryContainer,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickAndUploadPhoto(ImageSource.camera);
                        },
                      ),
                    ),
                    SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: _buildPhotoOptionCard(
                        icon: Icons.photo_library_rounded,
                        label: 'Galeri',
                        color: AppColors.secondary,
                        bgColor: AppColors.secondaryContainer,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pickAndUploadPhoto(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOptionCard({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.xl,
          horizontal: AppDimensions.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: AppDimensions.iconLg),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              label,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.isLoading != curr.isLoading ||
          prev.user?.photoUrl != curr.user?.photoUrl ||
          prev.error != curr.error,
      listener: (context, state) {
        if (_isUploadingPhoto && !state.isLoading) {
          setState(() => _isUploadingPhoto = false);
          if (state.error == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Foto profil berhasil diperbarui!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal mengubah foto: ${state.error}'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pageHorizontal,
              vertical: AppDimensions.pageVertical,
            ),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final user = state.user;
                final nickname = user?.nickname ?? 'Siswa';
                final email = user?.email ?? '';
                final school = user?.school ?? '-';
                final primaryGoal = user?.primaryGoal ?? '-';
                final userType = user?.userType ?? 'Belum Ditentukan';
                final photoUrl = user?.photoUrl;

                return Column(
                  children: [
                    _buildAppBar(context)
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.08),
                    const SizedBox(height: AppDimensions.xl),
                    _buildProfileHeader(nickname, email, photoUrl)
                        .animate(delay: 80.ms)
                        .fadeIn()
                        .slideY(begin: 0.08),
                    const SizedBox(height: AppDimensions.xl),
                    _buildInfoSection(school, primaryGoal, userType)
                        .animate(delay: 160.ms)
                        .fadeIn()
                        .slideY(begin: 0.08),
                    const SizedBox(height: AppDimensions.xl),
                    _buildThemeSettings(context)
                        .animate(delay: 200.ms)
                        .fadeIn()
                        .slideY(begin: 0.08),
                    const SizedBox(height: AppDimensions.xl),
                    _buildLogoutButton(context)
                        .animate(delay: 240.ms)
                        .fadeIn()
                        .slideY(begin: 0.08),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: AppDimensions.iconMd,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Text(
          'Profil Saya',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(String nickname, String email, String? photoUrl) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: _isUploadingPhoto
                  ? CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.primaryContainer,
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.primaryContainer,
                      backgroundImage:
                          photoUrl != null && photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                      child: photoUrl == null || photoUrl.isEmpty
                          ? Text(
                              nickname.isNotEmpty
                                  ? nickname[0].toUpperCase()
                                  : 'S',
                              style: AppTypography.displayLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
            ),
            GestureDetector(
              onTap: _showPhotoPickerSheet,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.surface,
                  size: AppDimensions.iconSm,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        Text(
          nickname,
          style: AppTypography.headlineLarge.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimensions.xs),
        Text(
          email,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String school, String primaryGoal, String userType) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Informasi Profil',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.push(Routes.editProfile),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.lg),
          _buildInfoRow(
            icon: Icons.school_rounded,
            label: 'Asal Sekolah',
            value: school,
            color: AppColors.primary,
            bgColor: AppColors.primaryContainer,
          ),
          SizedBox(height: AppDimensions.md),
          Divider(color: AppColors.cardBorder, height: 1),
          SizedBox(height: AppDimensions.md),
          _buildInfoRow(
            icon: Icons.flag_rounded,
            label: 'Target Utama',
            value: primaryGoal,
            color: AppColors.tertiary,
            bgColor: AppColors.tertiaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.sm),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Icon(icon, color: color, size: AppDimensions.iconSm),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Tema',
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'Pilih warna tema yang paling kamu suka',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return Row(
                children: [
                  Expanded(
                    child: _buildThemeOptionCard(
                      context: context,
                      title: 'Biru',
                      color: const Color(0xFF2979FF),
                      isSelected: state.themeType == ThemeType.blue,
                      themeType: ThemeType.blue,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: _buildThemeOptionCard(
                      context: context,
                      title: 'Pink',
                      color: const Color(0xFFFF4081),
                      isSelected: state.themeType == ThemeType.pink,
                      themeType: ThemeType.pink,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptionCard({
    required BuildContext context,
    required String title,
    required Color color,
    required bool isSelected,
    required ThemeType themeType,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<ThemeBloc>().add(ChangeTheme(themeType));
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isSelected ? color : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: AppColors.surface, size: 20)
                  : null,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: isSelected ? color : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _showLogoutConfirmation(context),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.md,
          horizontal: AppDimensions.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.expense.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: AppColors.expense.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.expense,
              size: AppDimensions.iconSm,
            ),
            SizedBox(width: AppDimensions.sm),
            Text(
              'Keluar dari Akun',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.expense,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.expense.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppColors.expense,
                  size: 40,
                ),
              ),
              SizedBox(height: AppDimensions.md),
              Text(
                'Keluar dari SakuPintar?',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppDimensions.sm),
              Text(
                'Kamu yakin ingin keluar dari akunmu?',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppDimensions.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.md,
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.of(context).pop(); // Close profile page
                        context.read<AuthBloc>().add(const LogoutRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.expense,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.md,
                        ),
                      ),
                      child: Text(
                        'Keluar',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}