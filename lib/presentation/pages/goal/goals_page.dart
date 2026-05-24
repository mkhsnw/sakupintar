import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_bloc.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_event.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_state.dart';
import 'package:sakupintar/data/models/goal/goal_model.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_event.dart';
import 'package:sakupintar/core/services/ai_service.dart';
import 'package:sakupintar/core/utils/formatters.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sakupintar/core/constants/animation.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalBloc, GoalState>(
      builder: (context, state) {
        if (state.isLoading && state.goals.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          key: const ValueKey('goals'),
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<GoalBloc>().add(LoadGoals());
              context.read<TransactionBloc>().add(
                LoadTransactions(Formatters.getMonthKey(DateTime.now())),
              );
            },
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                left: AppDimensions.pageHorizontal,
                right: AppDimensions.pageHorizontal,
                top: AppDimensions.pageVertical,
                bottom: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader()
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.08),
                  const SizedBox(height: AppDimensions.lg),
                  _buildGoalEstimation(
                    context,
                  ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.08),
                  const SizedBox(height: AppDimensions.xl),
                  _buildActiveDream(
                    context,
                    state,
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.08),
                  const SizedBox(height: AppDimensions.xl),
                  _buildGoalList(
                    context,
                    state,
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.08),
                  const SizedBox(height: AppDimensions.lg),
                  _buildAddGoalButton(
                    context,
                  ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.08),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERJALANANMU',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Wujudkan',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          'Mimpimu',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalEstimation(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;
    final transactions = context.read<TransactionBloc>().state.transactions;
    final goals = context.read<GoalBloc>().state.goals;

    if (user == null) return const SizedBox();

    return FutureBuilder<Map<String, dynamic>>(
      future: AiService.generateArsaInsight(
        user: user,
        recentTransactions: transactions,
        goals: goals,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final estimation =
            data['insight']?['goal_estimation'] ??
            'Yuk rajin nabung biar cepet capai target!';

        return Container(
          width: double.infinity,
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
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.auto_graph_rounded,
                  size: 140,
                  color: AppColors.surface.withOpacity(0.15),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_graph_rounded,
                        color: AppColors.surface,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Estimasi Pencapaian Target',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    estimation,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.surface.withOpacity(0.9),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveDream(BuildContext context, GoalState state) {
    final activeGoal = state.activeGoal;

    if (activeGoal == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.tertiaryContainer,
              AppColors.primaryContainer.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tertiary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.star_border_rounded,
                size: 48,
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'Belum Ada Active Dream',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Buat target keuangan pertamamu sekarang!',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final percentage = activeGoal.targetAmount > 0
        ? (activeGoal.savedAmount / activeGoal.targetAmount)
        : 0.0;
    final progressVal = percentage.clamp(0.0, 1.0);

    final daysLeft = activeGoal.deadline
        .toDate()
        .difference(DateTime.now())
        .inDays;
    final remaining = activeGoal.targetAmount - activeGoal.savedAmount;
    final dailySave = (daysLeft > 0 && remaining > 0)
        ? (remaining / daysLeft)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.incomeGradient,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      child: Text(
                        'MIMPI AKTIF',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      activeGoal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${Formatters.formatCurrency(activeGoal.targetAmount)}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimensions.sm),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: progressVal,
                      strokeWidth: 8,
                      backgroundColor: AppColors.secondaryContainer.withOpacity(
                        0.5,
                      ),
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    '${(progressVal * 100).toInt()}%',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppDimensions.xl),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    gradient: AppColors.incomeGradient,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.neutralDark.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.savings_rounded,
                              color: AppColors.surface,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'UDAH NABUNG',
                                maxLines: 1,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.neutralDark.withOpacity(0.9),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.formatCurrency(activeGoal.savedAmount),
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.neutralDark,
                          fontWeight: FontWeight.w800,
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
                    gradient: LinearGradient(
                      colors: [AppColors.tertiary, AppColors.tertiaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.neutralDark.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.surface,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'NABUNG/HARI',
                                maxLines: 1,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.neutralDark.withOpacity(0.9),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.formatCurrency(dailySave),
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.neutralDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DEADLINE: ${DateFormat('MMM yy', 'id_ID').format(activeGoal.deadline.toDate()).toUpperCase()}',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${Formatters.formatCurrency(remaining > 0 ? remaining : 0)} LAGI',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: progressVal,
              minHeight: 12,
              backgroundColor: AppColors.primaryContainer.withOpacity(0.5),
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppDimensions.xl),
          SizedBox(
            width: double.infinity,
            child: activeGoal.savedAmount >= activeGoal.targetAmount
                ? ElevatedButton(
                    onPressed: () => _showCompletionDialog(context, activeGoal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.surface,
                        ),
                        SizedBox(width: AppDimensions.sm),
                        Text(
                          'Tandai Selesai',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      context.push(
                        '/transaction/add?type=expense&goalId=${activeGoal.id}',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Top Up Savings',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalList(BuildContext context, GoalState state) {
    final visibleGoals = state.inactiveGoals
        .where((g) => !g.isCompleted && g.savedAmount < g.targetAmount)
        .toList();
    if (visibleGoals.isEmpty) return const SizedBox();

    return Column(
      children: visibleGoals.map((goal) {
        final percentage = goal.targetAmount > 0
            ? (goal.savedAmount / goal.targetAmount)
            : 0.0;
        final isCompleted = goal.savedAmount >= goal.targetAmount;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.md),
          child: _buildGoalCard(
            context: context,
            goal: goal,
            icon: Icons.star_rounded,
            title: goal.title,
            target: '${Formatters.formatCurrency(goal.targetAmount)} target',
            statusText: isCompleted ? 'Selesai' : 'Belum Aktif',
            statusColor: isCompleted ? AppColors.secondary : AppColors.neutral,
            progress: percentage.clamp(0.0, 1.0),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalCard({
    required BuildContext context,
    required GoalModel goal,
    required IconData icon,
    required String title,
    required String target,
    required String statusText,
    required Color statusColor,
    required double progress,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<GoalBloc>().add(SetActiveGoal(goal.id));
      },
      child: Container(
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.tertiary, AppColors.tertiaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.surface, size: 24),
                ),
                Text(
                  statusText,
                  style: AppTypography.labelMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              target,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.neutralContainer,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddGoalButton(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/goals/add');
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.xl),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: AppColors.surface,
                size: 20,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'Tambah Mimpi Baru',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, GoalModel goal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        size: 48,
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(height: AppDimensions.lg),
                    Text(
                      'Target Tercapai!',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Selamat! Kamu berhasil mengumpulkan dana untuk ${goal.title}.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          context.read<GoalBloc>().add(
                            MarkGoalCompleted(goal.id),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                          ),
                        ),
                        child: Text(
                          'Selesai',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -80,
                  child: IgnorePointer(
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: Lottie.asset(
                        AppAnimations.confetti,
                        repeat: false,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
