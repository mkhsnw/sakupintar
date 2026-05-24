import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/core/utils/formatters.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_event.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_state.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_bloc.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';
import 'package:sakupintar/core/services/ai_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _isLoadingAi = true;
  String _arsaTitle = 'ARSA Berpikir...';
  String _arsaMessage =
      'Lagi ngecek riwayat jajan kamu nih biar bisa ngasih saran terbaik!';
  String _userSegment = 'Menganalisis...';
  String _goalEstimation = 'Sedang menghitung prediksi targetmu...';

  @override
  void initState() {
    super.initState();

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

  Future<void> _handleRefresh() async {
    context.read<TransactionBloc>().add(
      LoadTransactions(Formatters.getMonthKey(DateTime.now())),
    );
    await _fetchAiInsight();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: ValueKey('analytics'),
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
                    'Analitik & Budget',
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
            .animate(delay: 300.ms)
            .fadeIn()
            .slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildArsaInsightCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_rounded,
              size: 40,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _arsaTitle,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.surface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_isLoadingAi) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surface,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _arsaMessage,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.surface.withOpacity(0.9),
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
            gradient: LinearGradient(
              colors: [
                AppColors.surface,
                AppColors.primaryContainer.withOpacity(0.2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bar_chart_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    'Tren Pengeluaran 7 Hari',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xl),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
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
                                DateFormat('E', 'id_ID').format(date).substring(0, 3),
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
                      final isHighest = weeklySpending[i] == weeklySpending.reduce((a, b) => a > b ? a : b) && weeklySpending[i] > 0;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: weeklySpending[i],
                            color: isHighest ? AppColors.tertiary : AppColors.primary,
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
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryContainer,
            AppColors.primaryContainer.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.incomeGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.stars_rounded,
              color: AppColors.surface,
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
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

}