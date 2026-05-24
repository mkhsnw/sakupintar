import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/core/utils/app_router.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';

import 'package:sakupintar/presentation/bloc/auth/auth_state.dart';
import 'package:sakupintar/presentation/bloc/category/category_event.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_event.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_state.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_event.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_state.dart';
import 'package:sakupintar/presentation/bloc/category/category_bloc.dart';

import 'package:sakupintar/data/models/category/category_model.dart';
import 'package:sakupintar/data/models/transaction/transaction_model.dart';
import 'package:sakupintar/core/utils/formatters.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sakupintar/presentation/pages/goal/goals_page.dart';
import 'package:sakupintar/presentation/pages/analytics/analytics_page.dart';
import 'package:sakupintar/presentation/pages/education/education_page.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_bloc.dart';
import 'package:sakupintar/core/services/ai_service.dart';
import 'package:sakupintar/presentation/bloc/budget/budget_bloc.dart';
import 'package:sakupintar/presentation/bloc/budget/budget_event.dart';
import 'package:sakupintar/presentation/bloc/budget/budget_state.dart';
import 'package:sakupintar/data/models/budget/budget_model.dart';
import 'package:sakupintar/core/utils/app_router.dart';

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

  final TextEditingController _incomeController = TextEditingController();
  bool _isCreatingBudget = false;

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

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
    context.read<BudgetBloc>().add(
      LoadBudget(Formatters.getMonthKey(_selectedMonth)),
    );
  }

  Future<void> _fetchAiInsights() async {
    if (!mounted) return;

    final txState = context.read<TransactionBloc>().state;
    final goalState = context.read<GoalBloc>().state;

    if (txState.isLoading || goalState.isLoading) return;

    setState(() => _isLoadingAi = true);
    developer.log('[Dashboard] _fetchAiInsights started');

    try {
      final user = context.read<AuthBloc>().state.user;
      final transactions = txState.transactions;
      final goals = goalState.goals;

      if (user != null) {
        developer.log(
          '[Dashboard] Fetching ARSA insight for user: ${user.nickname}',
        );
        final aiResult = await AiService.generateArsaInsight(
          user: user,
          recentTransactions: transactions,
          goals: goals,
        );
        developer.log(
          '[Dashboard] ARSA insight received. Alerts count: ${(aiResult['insight']?['alerts'] as List?)?.length ?? 0}',
        );

        if (mounted) {
          setState(() {
            _alerts = aiResult['insight']?['alerts'] ?? [];
            _isLoadingAi = false;
          });
        }
      } else {
        developer.log('[Dashboard] User is null, skipping AI insight');
      }
    } catch (e, stackTrace) {
      developer.log(
        '[Dashboard] ERROR fetching AI insights: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _isLoadingAi = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TransactionBloc, TransactionState>(
          listenWhen: (prev, curr) =>
              prev.isLoading != curr.isLoading ||
              prev.transactions != curr.transactions,
          listener: (context, state) {
            if (!state.isLoading) _fetchAiInsights();
          },
        ),
        BlocListener<GoalBloc, GoalState>(
          listenWhen: (prev, curr) =>
              prev.isLoading != curr.isLoading || prev.goals != curr.goals,
          listener: (context, state) {
            if (!state.isLoading) _fetchAiInsights();
          },
        ),
        BlocListener<BudgetBloc, BudgetState>(
          listenWhen: (prev, curr) =>
              prev.isSuccess != curr.isSuccess || prev.error != curr.error,
          listener: (context, state) {
            if (state.isSuccess) {
              developer.log('[Dashboard] Budget saved successfully');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Rencana budget berhasil disimpan!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              );
            } else if (state.error != null && state.error!.isNotEmpty) {
              developer.log('[Dashboard] Budget save error: ${state.error}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal menyimpan budget: ${state.error}'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
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
      ),
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
      key: ValueKey('dashboard'),
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
              _buildBudgetSection()
                  .animate(delay: 250.ms)
                  .fadeIn()
                  .slideY(begin: 0.08),
              const SizedBox(height: AppDimensions.xl),
              _buildRecentTransactionsSection()
                  .animate(delay: 300.ms)
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
                  onTap: () => context.push(Routes.profile),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
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
                      'HAI, ${nickname.toUpperCase()}',
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
              icon: Icon(Icons.notifications_rounded, color: AppColors.primary),
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
              'Saran ARSA',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'PAKAI AI',
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
          SizedBox(
            width: double.infinity,
            child: _buildInsightCard(
              title: 'Halo!',
              icon: Icons.lightbulb_outline_rounded,
              content:
                  'ARSA sedang memantau keuanganmu nih, belum ada alert khusus untuk sekarang. Semangat menabung!',
              buttonText: 'Siap ARSA',
              isPrimary: true,
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth > 0
                  ? constraints.maxWidth - AppDimensions.md
                  : MediaQuery.of(context).size.width * 0.88;
              return SizedBox(
                height: 320,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: _alerts.map((alert) {
                      final isWarning = alert['type'] == 'warning';
                      return Container(
                        width: cardWidth,
                        padding: const EdgeInsets.only(right: AppDimensions.md),
                        child: _buildInsightCard(
                          title: alert['title'] ?? 'Saran',
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
              );
            },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width * 0.85;

        return Container(
          width: cardWidth,
          constraints: BoxConstraints(minHeight: 200, maxHeight: 320),
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
                      offset: Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                  SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        color: isPrimary
                            ? AppColors.surface
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.md),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Text(
                    content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isPrimary
                          ? Colors.white.withOpacity(0.9)
                          : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
      },
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
                  DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth),
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
          decoration: BoxDecoration(
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
                        DateFormat('MMMM yyyy', 'id_ID').format(month),
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
                          ? Icon(
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
                        context.read<BudgetBloc>().add(
                          LoadBudget(Formatters.getMonthKey(month)),
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

    return Column(
      children: [
        // Total Balance (Premium Gradient Card)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Icon Watermark
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 140,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SISA BUDGET',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppDimensions.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Rp',
                          style: AppTypography.currencySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          Formatters.formatCurrency(
                            sisaBudget,
                          ).replaceAll('Rp ', ''),
                          style: AppTypography.currencyLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.md),
                    Text(
                      'Atur keuanganmu dengan bijak',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.md),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.secondaryDark,
                        size: 20,
                      ),
                    ),
                    SizedBox(height: AppDimensions.md),
                    Text(
                      'PEMASUKAN',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      Formatters.formatCurrency(totalIncome),
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: AppDimensions.md),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.expense.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.trending_down_rounded,
                        color: AppColors.expense,
                        size: 20,
                      ),
                    ),
                    SizedBox(height: AppDimensions.md),
                    Text(
                      'PENGELUARAN',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.expense,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatCurrency(totalExpense),
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
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
        name: categoryId
            .replaceAll('custom_', 'Kategori ')
            .replaceAll('default_', ''),
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

  Widget _buildRecentTransactionsSection() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final categoryState = context.watch<CategoryBloc>().state;
        final categories = categoryState.categories;

        // Get only expense/income transactions, latest 3
        final recentTransactions = state.transactions.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Transaksi',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final monthKey = Formatters.getMonthKey(_selectedMonth);
                    context.push(
                      '${Routes.transactionList}?monthKey=$monthKey',
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    child: Text(
                      'Lihat Semua',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.md),
            if (state.isLoading)
              _buildTransactionShimmer()
            else if (recentTransactions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 40,
                      color: AppColors.neutral.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Belum ada transaksi bulan ini',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...recentTransactions.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                  child: _buildRecentTransactionItem(entry.value, categories)
                      .animate(delay: (entry.key * 60).ms)
                      .fadeIn()
                      .slideX(begin: 0.04),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildRecentTransactionItem(
    TransactionModel tx,
    List<CategoryModel> categories,
  ) {
    final isExpense = tx.type == 'expense';
    final category = categories.firstWhere(
      (c) => c.id == tx.categoryId,
      orElse: () => CategoryModel(
        id: tx.categoryId,
        name: tx.categoryId
            .replaceAll('custom_', '')
            .replaceAll('default_', ''),
        icon: 'category',
        color: '0xFF73739E',
        createdAt: Timestamp.now(),
      ),
    );

    Color catColor;
    try {
      catColor = Color(int.parse(category.color));
    } catch (_) {
      catColor = AppColors.neutral;
    }

    return GestureDetector(
      onTap: () {
        context.push(Routes.transactionDetail, extra: tx);
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Icon(
                isExpense
                    ? Icons.trending_down_rounded
                    : Icons.trending_up_rounded,
                color: catColor,
                size: AppDimensions.iconSm,
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (tx.note != null && tx.note!.isNotEmpty)
                    Text(
                      tx.note!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}${Formatters.formatCurrency(tx.amount)}',
                  style: AppTypography.titleMedium.copyWith(
                    color: isExpense ? AppColors.expense : AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DateFormat('dd MMM, HH:mm', 'id_ID').format(tx.date.toDate()),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionShimmer() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.sm),
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.neutralContainer,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.neutralContainer,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXs,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.neutralContainer,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXs,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.neutralContainer,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetSection() {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.currentBudget == null) {
          final txState = context.watch<TransactionBloc>().state;
          double totalIncome = 0;
          for (final tx in txState.transactions) {
            if (tx.type == 'income') {
              totalIncome += tx.amount;
            }
          }
          return _buildCreateBudgetForm(totalIncome);
        }

        return _buildBudgetDashboard(state.currentBudget!);
      },
    );
  }

  Widget _buildCreateBudgetForm(double totalIncome) {
    if (totalIncome <= 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neutral.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 40,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'Belum Ada Pemasukan',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Catat pemasukan bulan ini terlebih dahulu menggunakan tombol + untuk mulai menggunakan fitur Smart Budget.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.primaryContainer.withOpacity(0.3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppDimensions.md),
          Text(
            'Budget Pintar',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'ARSA akan membuatkan rencana alokasi budget cerdas berdasarkan total pemasukanmu sebesar ${Formatters.formatCurrency(totalIncome)} dan menyesuaikannya dengan kategori yang kamu punya.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
              onPressed: _isCreatingBudget
                  ? null
                  : () => _createBudgetWithAI(totalIncome),
              child: _isCreatingBudget
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.surface,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(
                      'Buat Rencana Budget',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Future<void> _createBudgetWithAI(double income) async {
    developer.log('[Dashboard] _createBudgetWithAI started. Income: $income');
    setState(() => _isCreatingBudget = true);

    try {
      final user = context.read<AuthBloc>().state.user;
      final transactions = context.read<TransactionBloc>().state.transactions;
      final goals = context.read<GoalBloc>().state.goals;
      final categories = context.read<CategoryBloc>().state.categories;

      developer.log(
        '[Dashboard] User: ${user?.nickname}, Categories count: ${categories.length}, Transactions count: ${transactions.length}',
      );

      Map<String, dynamic> aiResult = {};
      if (user != null) {
        developer.log(
          '[Dashboard] Calling AiService.generateArsaInsight with incomeToAllocate=$income',
        );
        aiResult = await AiService.generateArsaInsight(
          user: user,
          recentTransactions: transactions,
          goals: goals,
          incomeToAllocate: income,
          categories: categories,
        );
        developer.log(
          '[Dashboard] AiService returned keys: ${aiResult.keys.toList()}',
        );
      } else {
        developer.log('[Dashboard] ERROR: User is null');
      }

      if (!mounted) return;

      // Robust parsing: handle multiple possible formats
      Map<String, dynamic> budgetData = {};
      try {
        final rawBudget = aiResult['budget'];
        if (rawBudget is Map<String, dynamic>) {
          budgetData = rawBudget;
        } else if (rawBudget is Map) {
          budgetData = Map<String, dynamic>.from(rawBudget);
        }
      } catch (e) {
        developer.log('[Dashboard] Error parsing budget data: $e');
      }
      developer.log('[Dashboard] Budget data from AI: $budgetData');

      final allocations = <AllocationModel>[];

      if (budgetData.isNotEmpty) {
        budgetData.forEach((key, value) {
          try {
            developer.log(
              '[Dashboard] Parsing budget item: key=$key, value=$value',
            );
            final cat = categories.firstWhere(
              (c) => c.id == key,
              orElse: () => CategoryModel(
                id: key,
                name: key
                    .replaceAll('custom_', 'Kategori ')
                    .replaceAll('default_', ''),
                icon: 'category',
                color: '0xFF73739E',
                createdAt: Timestamp.now(),
              ),
            );
            // Handle multiple number formats from AI
            double percentage = 0.0;
            if (value is num) {
              percentage = value.toDouble();
            } else if (value is String) {
              percentage = double.tryParse(value) ?? 0.0;
            } else if (value is int) {
              percentage = value.toDouble();
            }
            if (percentage > 0) {
              allocations.add(
                AllocationModel(
                  categoryId: key,
                  label: cat.name,
                  limitAmount: income * (percentage / 100),
                  percentage: percentage,
                ),
              );
            }
          } catch (itemError) {
            developer.log(
              '[Dashboard] Error parsing budget item $key: $itemError',
            );
          }
        });
      } else {
        developer.log(
          '[Dashboard] Budget data empty, using equal distribution fallback',
        );
        final numCategories = categories.isEmpty ? 1 : categories.length;
        final percentage = 100.0 / numCategories;
        for (final cat in categories) {
          allocations.add(
            AllocationModel(
              categoryId: cat.id,
              label: cat.name,
              limitAmount: income * (percentage / 100),
              percentage: percentage,
            ),
          );
        }
      }

      final budget = BudgetModel(
        monthKey: Formatters.getMonthKey(_selectedMonth),
        income: income,
        createdAt: Timestamp.now(),
        allocations: allocations,
      );

      developer.log(
        '[Dashboard] Saving budget with ${allocations.length} allocations',
      );
      context.read<BudgetBloc>().add(SaveBudget(budget));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rencana budget berhasil dibuat! ARSA sudah mengalokasikan ${allocations.length} kategori untukmu.',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        '[Dashboard] ERROR creating budget: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat rencana budget: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingBudget = false;
        });
      }
    }
  }

  Widget _buildBudgetDashboard(BudgetModel budget) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, txState) {
        double totalExpense = 0;
        Map<String, double> expenseByCategory = {};

        for (var tx in txState.transactions) {
          if (tx.type == 'expense') {
            totalExpense += tx.amount;
            expenseByCategory[tx.categoryId] =
                (expenseByCategory[tx.categoryId] ?? 0) + tx.amount;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alokasi Bulan Ini',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _showCustomAllocationSheet(budget),
                      icon: Icon(Icons.edit_rounded, size: 20),
                      color: AppColors.primary,
                      tooltip: 'Edit Manual',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    TextButton.icon(
                      onPressed: _isCreatingBudget
                          ? null
                          : () => _createBudgetWithAI(budget.income),
                      icon: _isCreatingBudget
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.refresh_rounded, size: 18),
                      label: Text('Sesuaikan'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            ...budget.allocations.map((alloc) {
              final spent = expenseByCategory[alloc.categoryId] ?? 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: _buildAllocationItem(alloc, spent),
              );
            }),
          ],
        ).animate().fadeIn();
      },
    );
  }

  Widget _buildBudgetSummary(double income, double expense) {
    final remaining = income - expense;
    final percentage = income > 0 ? (expense / income).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sisa Budget',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Total: ${Formatters.formatCurrency(income)}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            Formatters.formatCurrency(remaining),
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: remaining < 0 ? AppColors.expense : AppColors.primary,
            ),
          ),
          SizedBox(height: AppDimensions.xl),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: AppColors.neutralContainer,
              color: percentage > 0.8 ? AppColors.expense : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'Terpakai: ${Formatters.formatCurrency(expense)}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationItem(AllocationModel alloc, double spent) {
    final percentage = alloc.limitAmount > 0
        ? (spent / alloc.limitAmount).clamp(0.0, 1.0)
        : 0.0;
    final isWarning = percentage > 0.8;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                alloc.label,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${alloc.percentage.toInt()}%',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.formatCurrency(spent),
                style: AppTypography.bodyMedium.copyWith(
                  color: isWarning ? AppColors.expense : AppColors.textPrimary,
                ),
              ),
              Text(
                '/ ${Formatters.formatCurrency(alloc.limitAmount)}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: AppColors.neutralContainer,
              color: isWarning ? AppColors.expense : AppColors.secondary,
            ),
          ),
        ],
      ),
    );
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
              _buildNavItem(Icons.grid_view_rounded, 'BERANDA', 0),
              _buildNavItem(Icons.track_changes_rounded, 'MIMPI', 1),
              _buildAddTransactionButton(context),
              _buildNavItem(Icons.pie_chart_rounded, 'ANALITIK', 2),
              _buildNavItem(Icons.school_rounded, 'BELAJAR', 3),
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
        duration: Duration(milliseconds: 300),
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
              SizedBox(width: 6),
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
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: AppColors.surface, size: 32),
      ),
    );
  }

  void _showTransactionTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
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
            SizedBox(height: AppDimensions.xl),
            Text(
              'Pilih Jenis Transaksi',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppDimensions.xl),
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
                SizedBox(width: AppDimensions.md),
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

  void _showCustomAllocationSheet(BudgetModel budget) {
    if (budget.income <= 0) return;

    List<AllocationModel> editableAllocations = List.from(budget.allocations);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            double totalAllocated = 0;
            for (var alloc in editableAllocations) {
              totalAllocated += alloc.limitAmount;
            }
            double totalPercentage = (totalAllocated / budget.income) * 100;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusXl),
                ),
              ),
              child: Column(
                children: [
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
                  SizedBox(height: AppDimensions.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sesuaikan Alokasi',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: totalPercentage <= 100.1
                            ? () {
                                final newBudget = budget.copyWith(
                                  allocations: editableAllocations,
                                );
                                this.context.read<BudgetBloc>().add(
                                  SaveBudget(newBudget),
                                );
                                Navigator.pop(sheetContext);
                              }
                            : null,
                        child: Text('Simpan'),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.sm),
                  Container(
                    padding: EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      color: totalPercentage > 100
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Dialokasikan',
                          style: AppTypography.bodyMedium,
                        ),
                        Text(
                          '${totalPercentage.toStringAsFixed(1)}%',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: totalPercentage > 100
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.lg),
                  Expanded(
                    child: ListView.builder(
                      itemCount: editableAllocations.length,
                      itemBuilder: (context, index) {
                        final alloc = editableAllocations[index];
                        final category = this.context
                            .read<CategoryBloc>()
                            .state
                            .categories
                            .firstWhere(
                              (c) => c.id == alloc.categoryId,
                              orElse: () => CategoryModel(
                                id: alloc.categoryId,
                                name: 'Lainnya',
                                icon: 'category',
                                color: '0xFF9E9E9E',
                                createdAt: Timestamp.now(),
                              ),
                            );

                        double currentPercent =
                            (alloc.limitAmount / budget.income) * 100;

                        return Container(
                          margin: EdgeInsets.only(bottom: AppDimensions.md),
                          padding: EdgeInsets.all(AppDimensions.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLg,
                            ),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category.name,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${currentPercent.toStringAsFixed(1)}% (Rp ${Formatters.formatCurrency(alloc.limitAmount).replaceAll('Rp ', '')})',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: currentPercent,
                                min: 0,
                                max: 100,
                                divisions: 100,
                                activeColor: AppColors.primary,
                                inactiveColor: AppColors.primaryContainer,
                                onChanged: (val) {
                                  setStateSheet(() {
                                    double newAmount =
                                        budget.income * (val / 100);
                                    editableAllocations[index] = alloc.copyWith(
                                      limitAmount: newAmount,
                                      percentage: val,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
