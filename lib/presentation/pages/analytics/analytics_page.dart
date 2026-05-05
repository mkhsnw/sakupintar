import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/core/utils/formatters.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_event.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_state.dart';
import 'package:sakupintar/presentation/bloc/budget/budget_bloc.dart';
import 'package:sakupintar/presentation/bloc/budget/budget_event.dart';
import 'package:sakupintar/presentation/bloc/budget/budget_state.dart';
import 'package:sakupintar/data/models/budget/budget_model.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_bloc.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';
import 'package:sakupintar/core/services/ai_service.dart';
import 'package:lottie/lottie.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final TextEditingController _incomeController = TextEditingController();

  bool _isLoadingAi = true;
  bool _isCreatingBudget = false;
  String _arsaTitle = 'ARSA Berpikir...';
  String _arsaMessage =
      'Lagi ngecek riwayat jajan kamu nih biar bisa ngasih saran terbaik!';
  String _userSegment = 'Menganalisis...';
  String _goalEstimation = 'Sedang menghitung prediksi targetmu...';

  @override
  void initState() {
    super.initState();
    _loadCurrentMonthBudget();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAiInsight();
    });
  }

  Future<void> _fetchAiInsight() async {
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
          _arsaTitle = aiResult['insight']?['title'] ?? 'ARSA Insight';
          _arsaMessage =
              aiResult['insight']?['message'] ??
              'Yuk terus catat transaksi kamu biar ARSA bisa kasih saran.';
          _userSegment = aiResult['insight']?['segment_type'] ?? 'Konsisten';
          _goalEstimation =
              aiResult['insight']?['goal_estimation'] ??
              'Yuk rajin nabung biar cepet capai target!';
          _isLoadingAi = false;
        });
      }
    }
  }

  void _loadCurrentMonthBudget() {
    final monthKey = Formatters.getMonthKey(DateTime.now());
    context.read<BudgetBloc>().add(LoadBudget(monthKey));
  }

  Future<void> _handleRefresh() async {
    _loadCurrentMonthBudget();
    context.read<TransactionBloc>().add(
      LoadTransactions(Formatters.getMonthKey(DateTime.now())),
    );
    await _fetchAiInsight();
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('analytics'),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pageHorizontal,
              vertical: AppDimensions.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Analitik & Budgeting',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnalyticsSection(),
                    const SizedBox(height: AppDimensions.xxl),
                    _buildBudgetSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ANALYTICS SECTION ====================
  Widget _buildAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildArsaInsightCard()
            .animate()
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.1),
        const SizedBox(height: AppDimensions.xl),
        _buildTrendChart().animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
        const SizedBox(height: AppDimensions.xl),
        _buildUserSegmentCard()
            .animate(delay: 200.ms)
            .fadeIn()
            .slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildArsaInsightCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/image/arsa.png',
            width: 48,
            height: 48,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.psychology_rounded,
              size: 48,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _arsaTitle,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                      ),
                    ),
                    if (_isLoadingAi) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _arsaMessage,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        // Group expenses by day for the last 7 days
        final today = DateTime.now();
        List<double> weeklySpending = List.filled(7, 0.0);

        for (var tx in state.transactions) {
          if (tx.type == 'expense') {
            final txDate = tx.date.toDate();
            final difference = today.difference(txDate).inDays;
            if (difference >= 0 && difference < 7) {
              weeklySpending[6 - difference] += tx.amount;
            }
          }
        }

        double maxVal = 10000;
        for (var v in weeklySpending) {
          if (v > maxVal) maxVal = v;
        }

        return Container(
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
                'Tren Pengeluaran 7 Hari',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.xl),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxVal * 1.2,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final date = today.subtract(
                              Duration(days: 6 - value.toInt()),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat('E').format(date).substring(0, 3),
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: weeklySpending[i],
                            color: AppColors.primary,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserSegmentCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipe Pengeluaranmu',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _userSegment,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BUDGET SECTION ====================
  Widget _buildBudgetSection() {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.currentBudget == null) {
          return _buildCreateBudgetForm();
        }

        return _buildBudgetDashboard(state.currentBudget!);
      },
    );
  }

  Widget _buildCreateBudgetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppDimensions.xl),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            size: 64,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: AppDimensions.xl),
        Text(
          'Budget Bulan Ini Belum Diatur',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.md),
        Text(
          'Masukkan total pemasukanmu bulan ini (uang saku, beasiswa, dll) untuk mulai mengatur budget.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.xxl),
        TextField(
          controller: _incomeController,
          keyboardType: TextInputType.number,
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Rp 0',
            border: InputBorder.none,
            hintStyle: AppTypography.displayMedium.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.xxl),
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
                : () {
                    final incomeStr = _incomeController.text.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    if (incomeStr.isNotEmpty) {
                      final income = double.parse(incomeStr);
                      _createBudgetWithAI(income);
                    }
                  },
            child: _isCreatingBudget
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.surface,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    'Buat Budget Pintar (AI)',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Future<void> _createBudgetWithAI(double income) async {
    setState(() => _isCreatingBudget = true);

    final user = context.read<AuthBloc>().state.user;
    final transactions = context.read<TransactionBloc>().state.transactions;
    final goals = context.read<GoalBloc>().state.goals;

    Map<String, dynamic> aiResult = {};
    if (user != null) {
      aiResult = await AiService.generateArsaInsight(
        user: user,
        recentTransactions: transactions,
        goals: goals,
        incomeToAllocate: income,
      );
    }

    if (!mounted) return;

    final budgetData =
        aiResult['budget'] as Map<String, dynamic>? ??
        {
          "default_nabung": 30,
          "default_jajan": 40,
          "default_entertainment": 20,
          "default_lainnya": 10,
        };

    final allocations = [
      AllocationModel(
        categoryId: 'default_nabung',
        label: 'Tabungan',
        limitAmount: income * ((budgetData['default_nabung'] ?? 30) / 100),
        percentage: (budgetData['default_nabung'] ?? 30).toDouble(),
      ),
      AllocationModel(
        categoryId: 'default_jajan',
        label: 'Jajan',
        limitAmount: income * ((budgetData['default_jajan'] ?? 40) / 100),
        percentage: (budgetData['default_jajan'] ?? 40).toDouble(),
      ),
      AllocationModel(
        categoryId: 'default_entertainment',
        label: 'Entertainment',
        limitAmount:
            income * ((budgetData['default_entertainment'] ?? 20) / 100),
        percentage: (budgetData['default_entertainment'] ?? 20).toDouble(),
      ),
      AllocationModel(
        categoryId: 'default_lainnya',
        label: 'Bebas',
        limitAmount: income * ((budgetData['default_lainnya'] ?? 10) / 100),
        percentage: (budgetData['default_lainnya'] ?? 10).toDouble(),
      ),
    ];

    final budget = BudgetModel(
      monthKey: Formatters.getMonthKey(DateTime.now()),
      income: income,
      createdAt: Timestamp.now(),
      allocations: allocations,
    );

    context.read<BudgetBloc>().add(SaveBudget(budget));

    setState(() {
      _isCreatingBudget = false;
      // Also update ARSA insight based on the new recommendation
      if (aiResult['insight'] != null) {
        _arsaTitle = aiResult['insight']['title'] ?? _arsaTitle;
        _arsaMessage = aiResult['insight']['message'] ?? _arsaMessage;
        _userSegment = aiResult['insight']['segment_type'] ?? _userSegment;
      }
    });
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
            _buildBudgetSummary(budget.income, totalExpense),
            const SizedBox(height: AppDimensions.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alokasi Bulan Ini',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton.icon(
                  onPressed: _isCreatingBudget
                      ? null
                      : () => _createBudgetWithAI(budget.income),
                  icon: _isCreatingBudget
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Smart Adjust'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
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
          const SizedBox(height: 4),
          Text(
            Formatters.formatCurrency(remaining),
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: remaining < 0 ? AppColors.expense : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
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
          const SizedBox(height: AppDimensions.sm),
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
          const SizedBox(height: AppDimensions.md),
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
}
