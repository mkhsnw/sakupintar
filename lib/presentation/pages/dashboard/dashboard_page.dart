import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_event.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_state.dart';
import 'package:sakupintar/presentation/bloc/category/category_event.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_event.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_event.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_state.dart';
import 'package:sakupintar/presentation/bloc/category/category_bloc.dart';
import 'package:sakupintar/presentation/bloc/category/category_state.dart';
import 'package:sakupintar/data/models/category/category_model.dart';
import 'package:sakupintar/core/utils/formatters.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sakupintar/presentation/pages/goal/goals_page.dart';
import 'package:sakupintar/presentation/pages/analytics/analytics_page.dart';
import 'package:sakupintar/presentation/pages/education/education_page.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_bloc.dart';
import 'package:sakupintar/core/services/ai_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  DateTime _selectedMonth = DateTime.now();
  List<dynamic> _alerts = [];
  bool _isLoadingAi = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleRefresh();
    });
  }

  Future<void> _handleRefresh() async {
    context.read<TransactionBloc>().add(
      LoadTransactions(Formatters.getMonthKey(_selectedMonth)),
    );
    context.read<GoalBloc>().add(LoadGoals());
    context.read<CategoryBloc>().add(LoadCategories());
    await _fetchAiInsights();
  }

  Future<void> _fetchAiInsights() async {
    if (!mounted) return;

    setState(() => _isLoadingAi = true);

    final user = context.read<AuthBloc>().state.user;
    final transactions = context.read<TransactionBloc>().state.transactions;
    final goals = context.read<GoalBloc>().state.goals;

    if (user != null) {
      final aiResult = await AiService.generateArsaInsight(
        user: user,
        recentTransactions: transactions,
        goals: goals,
      );

      if (mounted) {
        setState(() {
          _alerts = aiResult['insight']?['alerts'] ?? [];
          _isLoadingAi = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const GoalsPage();
      case 2:
        return const AnalyticsPage();
      case 3:
        return const EducationPage();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SafeArea(
      key: const ValueKey('dashboard'),
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: AppDimensions.pageHorizontal,
            right: AppDimensions.pageHorizontal,
            top: AppDimensions.pageVertical,
            bottom: 32, // Reduced since bottom nav is floating/safe area
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader()
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.08),
              const SizedBox(height: AppDimensions.lg),
              _buildArsaInsights()
                  .animate(delay: 50.ms)
                  .fadeIn()
                  .slideY(begin: 0.08),
              const SizedBox(height: AppDimensions.xl),
              _buildMonthSelector()
                  .animate(delay: 100.ms)
                  .fadeIn()
                  .slideY(begin: 0.08),
              const SizedBox(height: AppDimensions.md),
              BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      _buildBalanceCards(
                        state,
                      ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.08),
                      const SizedBox(height: AppDimensions.xl),
                      _buildMonthlySpending(
                        context,
                        state,
                      ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.08),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppDimensions.xl),
              _buildFinancialLiteration()
                  .animate(delay: 250.ms)
                  .fadeIn()
                  .slideY(begin: 0.08),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final nickname = state.user?.nickname ?? 'Siswa';
        final photoUrl = state.user?.photoUrl;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showProfileMenu(context),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryContainer,
                      backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null || photoUrl.isEmpty
                          ? Text(
                              nickname.isNotEmpty
                                  ? nickname[0].toUpperCase()
                                  : 'S',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
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

  void _showProfileMenu(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final nickname = authState.user?.nickname ?? 'Siswa';
    final email = authState.user?.email ?? '';
    final photoUrl = authState.user?.photoUrl;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
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
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  // Profile info
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryContainer,
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? Text(
                            nickname.isNotEmpty
                                ? nickname[0].toUpperCase()
                                : 'S',
                            style: AppTypography.displayMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    nickname,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    email,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  // Divider
                  Divider(color: AppColors.cardBorder, height: 1),
                  const SizedBox(height: AppDimensions.sm),
                  // Logout button
                  InkWell(
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showLogoutConfirmation(context);
                    },
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.md,
                        horizontal: AppDimensions.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.expense.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: AppColors.expense,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Text(
                            'Keluar',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.expense,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                ],
              ),
            ),
          ),
        );
      },
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
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.expense,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                'Keluar dari SakuPintar?',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Kamu yakin ingin keluar dari akunmu?',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.cardBorder),
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
        if (_isLoadingAi)
          const Center(child: CircularProgressIndicator())
        else if (_alerts.isEmpty)
          _buildInsightCard(
            title: 'Halo!',
            icon: Icons.lightbulb_outline_rounded,
            content:
                'ARSA sedang memantau keuanganmu nih, belum ada alert khusus untuk sekarang. Semangat menabung!',
            buttonText: 'Siap ARSA',
            isPrimary: true,
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: _alerts.map((alert) {
                final isWarning = alert['type'] == 'warning';
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.md),
                  child: _buildInsightCard(
                    title: alert['title'] ?? 'Insight',
                    icon: isWarning
                        ? Icons.warning_amber_rounded
                        : Icons.lightbulb_outline_rounded,
                    content: alert['message'] ?? '',
                    buttonText: isWarning ? 'Perhatikan' : 'Lanjutkan',
                    isPrimary: !isWarning,
                  ),
                );
              }).toList(),
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
        InkWell(
          onTap: _showMonthPicker,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.neutral,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMonthPicker() {
    final months = List.generate(12, (index) {
      return DateTime(DateTime.now().year, DateTime.now().month - index, 1);
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.xl),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutralContainer,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),
              Text(
                'Pilih Bulan',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.xl),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final isSelected =
                        _selectedMonth.month == month.month &&
                        _selectedMonth.year == month.year;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                      ),
                      title: Text(
                        DateFormat('MMMM yyyy').format(month),
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _selectedMonth = month);
                        context.read<TransactionBloc>().add(
                          LoadTransactions(Formatters.getMonthKey(month)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceCards(TransactionState state) {
    double totalExpense = 0;
    double totalIncome = 0;
    for (final tx in state.transactions) {
      if (tx.type == 'expense') {
        totalExpense += tx.amount;
      } else {
        totalIncome += tx.amount;
      }
    }
    final sisaBudget = totalIncome - totalExpense;

    double percentage = 0.0;
    if (totalIncome > 0) {
      percentage = (sisaBudget / totalIncome) * 100;
    }
    final isPositive = sisaBudget >= 0;
    final percentageColor = isPositive
        ? AppColors.secondary
        : AppColors.expense;
    final percentageBgColor = isPositive
        ? AppColors.secondaryContainer
        : AppColors.expense.withOpacity(0.1);
    final percentageIcon = isPositive
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;
    final percentageText = '${percentage.abs().toStringAsFixed(1)}%';

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
                  Text(
                    Formatters.formatCurrency(sisaBudget).replaceAll('Rp ', ''),
                    style: AppTypography.currencyLarge,
                  ),
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
                      color: percentageBgColor,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(percentageIcon, size: 12, color: percentageColor),
                        const SizedBox(width: 4),
                        Text(
                          percentageText,
                          style: AppTypography.labelSmall.copyWith(
                            color: percentageColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    'Dari total pemasukan',
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
                      Formatters.formatCurrency(totalIncome),
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
                      Formatters.formatCurrency(totalExpense),
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

  Widget _buildMonthlySpending(BuildContext context, TransactionState state) {
    final categoryState = context.watch<CategoryBloc>().state;
    final categories = categoryState.categories;

    double totalExpense = 0;
    final Map<String, double> expenseByCategory = {};

    for (final tx in state.transactions) {
      if (tx.type == 'expense') {
        totalExpense += tx.amount;
        expenseByCategory[tx.categoryId] =
            (expenseByCategory[tx.categoryId] ?? 0) + tx.amount;
      }
    }

    final List<PieChartSectionData> sections = [];
    final List<Widget> legends = [];
    int index = 0;

    final sortedCategories = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedCategories) {
      final categoryInfo = _getCategoryInfo(entry.key, index, categories);
      final color = categoryInfo['color'] as Color;
      final name = categoryInfo['name'] as String;
      final amount = entry.value;

      sections.add(
        PieChartSectionData(color: color, value: amount, title: '', radius: 24),
      );

      legends.add(_buildLegendItem(color, name));
      index++;
    }

    if (sections.isEmpty) {
      sections.add(
        PieChartSectionData(
          color: AppColors.primaryContainer,
          value: 1,
          title: '',
          radius: 24,
        ),
      );
    }

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
          // Doughnut Chart
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 56,
                      sectionsSpace: 4,
                      startDegreeOffset: -90,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      Formatters.formatCurrency(totalExpense),
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
          if (legends.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: legends,
              ),
            ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo(
    String categoryId,
    int index,
    List<CategoryModel> categories,
  ) {
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryModel(
        id: categoryId,
        name: categoryId.replaceAll('custom_', 'Kategori '),
        icon: 'category',
        color: '0xFF73739E',
        createdAt:
            Timestamp.now()
                as dynamic, // use Timestamp for Firestore compatibility
      ),
    );

    Color color;
    try {
      color = Color(int.parse(category.color));
    } catch (_) {
      color =
          AppColors.categoryPalette[index % AppColors.categoryPalette.length];
    }

    return {'name': category.name, 'color': color};
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
    return Container(); // Removed, replaced by center bottom nav button
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.grid_view_rounded, 'HOME', 0),
              _buildNavItem(Icons.track_changes_rounded, 'GOALS', 1),
              _buildAddTransactionButton(context),
              _buildNavItem(Icons.pie_chart_rounded, 'ANALYTICS', 2),
              _buildNavItem(Icons.school_rounded, 'LEARN', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          setState(() => _currentIndex = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.surface : AppColors.neutral,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.2),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddTransactionButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTransactionTypeBottomSheet(context),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.surface,
          size: 32,
        ),
      ),
    );
  }

  void _showTransactionTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutralContainer,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Text(
              'Pilih Jenis Transaksi',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            Row(
              children: [
                Expanded(
                  child: _buildTransactionTypeCard(
                    context,
                    title: 'Pemasukan',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.secondary,
                    backgroundColor: AppColors.secondaryContainer,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/transaction/add?type=income');
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: _buildTransactionTypeCard(
                    context,
                    title: 'Pengeluaran',
                    icon: Icons.trending_down_rounded,
                    color: AppColors.expense,
                    backgroundColor: AppColors.expense.withOpacity(0.1),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/transaction/add?type=expense');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
