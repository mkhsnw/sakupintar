import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppDimensions.pageHorizontal,
            right: AppDimensions.pageHorizontal,
            top: AppDimensions.pageVertical,
            bottom: 120, // Extra space for FAB and BottomNav
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppDimensions.lg),
              _buildArsaInsights(),
              const SizedBox(height: AppDimensions.xl),
              _buildMonthSelector(),
              const SizedBox(height: AppDimensions.md),
              _buildBalanceCards(),
              const SizedBox(height: AppDimensions.xl),
              _buildMonthlySpending(),
              const SizedBox(height: AppDimensions.xl),
              _buildFinancialLiteration(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingAddButton(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final nickname = state.user?.nickname ?? 'Siswa';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    nickname.isNotEmpty ? nickname[0].toUpperCase() : 'S',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HELLO, ${nickname.toUpperCase()}',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'SakuPintar',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications_rounded,
                color: AppColors.primary,
              ),
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArsaInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ARSA Insights',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'AI POWERED',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildInsightCard(
                title: 'Saving Tip',
                icon: Icons.lightbulb_outline_rounded,
                content:
                    '"Kamu menghemat 15% untuk jajan minggu ini. Sisihkan Rp 20.000 untuk target Liburanmu!"',
                buttonText: 'Simpan Sekarang',
                isPrimary: true,
              ),
              const SizedBox(width: AppDimensions.md),
              _buildInsightCard(
                title: 'Warning',
                icon: Icons.warning_amber_rounded,
                content:
                    '"Pengeluaran kategori Hiburan hampir melewati batas alokasi bulan ini."',
                buttonText: 'Lihat Detail',
                isPrimary: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required String title,
    required IconData icon,
    required String content,
    required String buttonText,
    required bool isPrimary,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: isPrimary ? AppColors.primaryGradient : null,
        color: isPrimary ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: isPrimary ? null : Border.all(color: AppColors.cardBorder),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.tertiaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isPrimary ? AppColors.surface : AppColors.tertiary,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  color: isPrimary ? AppColors.surface : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            content,
            style: AppTypography.bodyMedium.copyWith(
              color: isPrimary
                  ? Colors.white.withOpacity(0.9)
                  : AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isPrimary
                  ? Colors.white.withOpacity(0.2)
                  : AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text(
              buttonText,
              style: AppTypography.labelMedium.copyWith(
                color: isPrimary ? AppColors.surface : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Oktober 2025', // Nanti dinamis
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.neutral,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCards() {
    return Column(
      children: [
        // Total Balance
        Container(
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
                'SISA BUDGET',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('450.000', style: AppTypography.currencyLarge),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_upward_rounded,
                          size: 12,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '12.5%',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    'Dibanding bulan lalu',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text('PEMASUKAN', style: AppTypography.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Rp 1.000.000',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.expense.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.trending_down_rounded,
                        color: AppColors.expense,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text('PENGELUARAN', style: AppTypography.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Rp 550.000',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlySpending() {
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
                'Pengeluaran Bulanan',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(Icons.more_horiz_rounded, color: AppColors.neutral),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),
          // Doughnut Chart Placeholder
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: CircularProgressIndicator(
                    value: 0.7,
                    strokeWidth: 24,
                    color: AppColors.primary,
                    backgroundColor: AppColors.primaryContainer,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Rp 550k',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text('TERPAKAI', style: AppTypography.labelSmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(AppColors.primary, 'Jajan'),
              _buildLegendItem(AppColors.expense, 'Hiburan'),
              _buildLegendItem(AppColors.tertiary, 'Transport'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTypography.labelMedium),
      ],
    );
  }

  Widget _buildFinancialLiteration() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edukasi Keuangan',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  'Kamu sudah 70% menyelesaikan "Tips Mengatur Uang Saku"',
                  style: AppTypography.bodySmall.copyWith(height: 1.5),
                ),
                const SizedBox(height: AppDimensions.md),
                Row(
                  children: [
                    Text(
                      'LANJUTKAN MODUL',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 64,
                width: 64,
                child: CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: 8,
                  color: AppColors.secondary,
                  backgroundColor: AppColors.secondaryContainer,
                ),
              ),
              Text(
                '70%',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAddButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
      ),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            onTap: () {
              // TODO: Navigate to Add Transaction
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.surface,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catat Transaksi',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Jaga budget tetap update',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.grid_view_rounded, 'HOME', 0),
          _buildNavItem(Icons.track_changes_rounded, 'GOALS', 1),
          const SizedBox(
            width: 48,
          ), // Space for floating button if it was center docked, but here we use normal spacing since FAB floats above
          _buildNavItem(Icons.pie_chart_rounded, 'ANALYTICS', 2),
          _buildNavItem(Icons.school_rounded, 'LEARN', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.neutral,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isSelected ? AppColors.primary : AppColors.neutral,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
