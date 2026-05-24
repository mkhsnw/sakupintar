import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sakupintar/core/services/ai_service.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_bloc.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:sakupintar/presentation/bloc/education/education_bloc.dart';
import 'package:sakupintar/data/models/education/education_model.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;
  bool _isLoadingAi = true;
  List<Map<String, dynamic>> _aiTips = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadAiEducation();
    });
  }

  Future<void> _loadAiEducation() async {
    if (!mounted) return;

    final txState = context.read<TransactionBloc>().state;
    final goalState = context.read<GoalBloc>().state;

    // Jika transaksi masih loading, tunggu
    if (txState.isLoading || goalState.isLoading) {
      developer.log('[Education] Waiting for data...');
      return;
    }

    setState(() => _isLoadingAi = true);

    try {
      final user = context.read<AuthBloc>().state.user;
      final transactions = txState.transactions;
      final goals = goalState.goals;

      if (user != null) {
        developer.log(
          '[Education] Fetching AI education for: ${user.nickname}',
        );
        final tips = await AiService.generateEducationMicro(
          user: user,
          recentTransactions: transactions,
          goals: goals,
        );
        if (mounted) {
          setState(() {
            _aiTips = tips;
            _isLoadingAi = false;
          });
          developer.log(
            '[Education] AI tips loaded: ${tips.length} items',
          );
        }
      } else {
        developer.log('[Education] User is null, fallback to static');
        _loadStaticEducation();
      }
    } catch (e, stackTrace) {
      developer.log(
        '[Education] ERROR: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      );
      _loadStaticEducation();
    }
  }

  void _loadStaticEducation() {
    if (!mounted) return;
    developer.log('[Education] Loading static fallback content');
    context.read<EducationBloc>().add(LoadEducation());
    if (mounted) {
      setState(() {
        _isLoadingAi = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    // Force refresh AI content (clear cache)
    AiService.generateEducationMicro(
      user: context.read<AuthBloc>().state.user!,
      recentTransactions: context.read<TransactionBloc>().state.transactions,
      goals: context.read<GoalBloc>().state.goals,
    );
    await _loadAiEducation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: ValueKey('education'),
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EDUKASI MIKRO',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1),
                    SizedBox(height: 4),
                    Text(
                      'Tips dari ARSA',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Dibuat khusus untuk kondisi keuanganmu saat ini',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                    const SizedBox(height: AppDimensions.xxl),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: _isLoadingAi
                  ? _buildShimmerLoading()
                  : _aiTips.isNotEmpty
                      ? _buildAiContent()
                      : _buildStaticFallback(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  color: AppColors.surface,
                ),
                child: Shimmer.fromColors(
                  baseColor: AppColors.neutralContainer,
                  highlightColor: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.xl),
                        Container(
                          width: double.infinity,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 200,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.xl),
        _buildPageIndicators(3),
      ],
    );
  }

  Widget _buildAiContent() {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _aiTips.length,
            itemBuilder: (context, index) {
              final tip = _aiTips[index];
              final isActive = index == _currentPage;
              return _buildArsaCard(tip, isActive, index);
            },
          ),
        ),
        const SizedBox(height: AppDimensions.xl),
        _buildPageIndicators(_aiTips.length),
        const SizedBox(height: AppDimensions.xxl),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildStaticFallback() {
    return BlocBuilder<EducationBloc, EducationState>(
      builder: (context, state) {
        if (state.isLoading && state.contents.isEmpty) {
          return _buildShimmerLoading();
        }

        if (state.contents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 64,
                  color: AppColors.neutral,
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  'Belum ada tips edukasi.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: state.contents.length,
                itemBuilder: (context, index) {
                  final content = state.contents[index];
                  final isActive = index == _currentPage;
                  return _buildStaticCard(content, isActive, index);
                },
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            _buildPageIndicators(state.contents.length),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildArsaCard(
    Map<String, dynamic> tip,
    bool isActive,
    int index,
  ) {
    final title = tip['title'] ?? 'Tips Keuangan';
    final content = tip['content'] ?? '...';
    final category = tip['category'] ?? 'Umum';
    final priority = tip['priority'] ?? 'normal';

    // Warna berdasarkan priority
    final Color accentColor = priority == 'high'
        ? AppColors.tertiary
        : priority == 'medium'
            ? AppColors.primary
            : AppColors.secondary;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(
        right: AppDimensions.md,
        left: index == 0 ? 0 : AppDimensions.sm,
        top: isActive ? 0 : 32,
        bottom: isActive ? 0 : 32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF651FFF),
            Color(0xFF2962FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Color(0xFF651FFF).withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ]
            : [],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ARSA Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.surface,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.xl),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.surface,
                  ),
                ),
                SizedBox(height: AppDimensions.lg),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      content,
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.md),
                // ARSA footer
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.smart_toy_rounded,
                        color: AppColors.surface,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppDimensions.sm),
                    Text(
                      'Dibuat oleh ARSA',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      child: Text(
                        priority == 'high' ? 'Penting!' : 'Tips',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticCard(
    EducationModel content,
    bool isActive,
    int index,
  ) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(
        right: AppDimensions.md,
        left: index == 0 ? 0 : AppDimensions.sm,
        top: isActive ? 0 : 32,
        bottom: isActive ? 0 : 32,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ]
            : [],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                  ),
                  child: Text(
                    content.category.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.xl),
                Text(
                  content.title,
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: AppDimensions.lg),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      content.content,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.neutralContainer,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}