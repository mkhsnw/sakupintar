import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/core/utils/formatters.dart';
import 'package:sakupintar/data/models/category/category_model.dart';
import 'package:sakupintar/data/models/transaction/transaction_model.dart';
import 'package:sakupintar/data/repositories/transaction_repository.dart';
import 'package:sakupintar/presentation/bloc/category/category_bloc.dart';
import 'package:sakupintar/presentation/bloc/category/category_state.dart';
import 'package:shimmer/shimmer.dart';

class TransactionListPage extends StatefulWidget {
  final String monthKey;

  const TransactionListPage({
    super.key,
    required this.monthKey,
  });

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  final TransactionRepository _repository = TransactionRepository();
  final ScrollController _scrollController = ScrollController();
  final List<TransactionModel> _transactions = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  String? _filterCategoryId;

  @override
  void initState() {
    super.initState();
    _loadInitialTransactions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadInitialTransactions() async {
    setState(() {
      _isLoading = true;
      _transactions.clear();
      _lastDocument = null;
      _hasMore = true;
    });

    try {
      final result = await _repository.getTransactionsPaginated(
        widget.monthKey,
        limit: 10,
      );

      if (!mounted) return;

      setState(() {
        _transactions.addAll(
          result['transactions'] as List<TransactionModel>,
        );
        _lastDocument = result['lastDocument'] as DocumentSnapshot?;
        _hasMore = result['hasMore'] as bool;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat transaksi: ${e.toString()}'),
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

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final result = await _repository.getTransactionsPaginated(
        widget.monthKey,
        limit: 10,
        lastDocument: _lastDocument,
      );

      if (!mounted) return;

      setState(() {
        _transactions.addAll(
          result['transactions'] as List<TransactionModel>,
        );
        _lastDocument = result['lastDocument'] as DocumentSnapshot?;
        _hasMore = result['hasMore'] as bool;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  List<TransactionModel> get _filteredTransactions {
    if (_filterCategoryId == null) return _transactions;
    return _transactions
        .where((tx) => tx.categoryId == _filterCategoryId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar()
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.08),
            const SizedBox(height: AppDimensions.md),
            _buildFilterChips()
                .animate(delay: 80.ms)
                .fadeIn()
                .slideY(begin: 0.08),
            const SizedBox(height: AppDimensions.md),
            Expanded(
              child: _isLoading
                  ? _buildShimmerList()
                  : _filteredTransactions.isEmpty
                      ? _buildEmptyState()
                      : _buildTransactionList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    // Parse the monthKey into a human-readable month name
    String displayMonth;
    try {
      final parts = widget.monthKey.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      displayMonth = DateFormat('MMMM yyyy', 'id_ID').format(DateTime(year, month));
    } catch (_) {
      displayMonth = widget.monthKey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
        vertical: AppDimensions.sm,
      ),
      child: Row(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Riwayat Transaksi',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  displayMonth,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = state.categories;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pageHorizontal,
          ),
          child: Row(
            children: [
              _buildFilterChip(
                label: 'Semua',
                isSelected: _filterCategoryId == null,
                onTap: () => setState(() => _filterCategoryId = null),
              ),
              ...categories.map((cat) {
                Color chipColor;
                try {
                  chipColor = Color(int.parse(cat.color));
                } catch (_) {
                  chipColor = AppColors.neutral;
                }
                return Padding(
                  padding: const EdgeInsets.only(left: AppDimensions.sm),
                  child: _buildFilterChip(
                    label: cat.name,
                    isSelected: _filterCategoryId == cat.id,
                    color: chipColor,
                    onTap: () => setState(() => _filterCategoryId = cat.id),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.primary)
                : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.surface : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    final transactions = _filteredTransactions;

    // Group transactions by date
    final Map<String, List<TransactionModel>> groupedByDate = {};
    for (final tx in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.date.toDate());
      groupedByDate.putIfAbsent(dateKey, () => []).add(tx);
    }

    final sortedKeys = groupedByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _loadInitialTransactions,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pageHorizontal,
        ),
        itemCount: sortedKeys.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == sortedKeys.length) {
            return _buildLoadingMoreIndicator();
          }

          final dateKey = sortedKeys[index];
          final dateTxs = groupedByDate[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
                child: Text(
                  _formatDateHeader(dateKey),
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...dateTxs.asMap().entries.map((entry) {
                final tx = entry.value;
                return _buildTransactionItem(tx, context)
                    .animate(delay: (entry.key * 60).ms)
                    .fadeIn()
                    .slideX(begin: 0.04);
              }),
              const SizedBox(height: AppDimensions.sm),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx, BuildContext context) {
    final categoryState = context.watch<CategoryBloc>().state;
    final categories = categoryState.categories;
    final isExpense = tx.type == 'expense';

    final category = categories.firstWhere(
      (c) => c.id == tx.categoryId,
      orElse: () => CategoryModel(
        id: tx.categoryId,
        name: tx.categoryId.replaceAll('custom_', '').replaceAll('default_', ''),
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

    return Container(
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
                DateFormat('HH:mm').format(tx.date.toDate()),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
      child: Center(
        child: _isLoadingMore
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    'Memuat lebih banyak...',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: AppColors.neutralContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(
              'Belum Ada Transaksi',
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Transaksi yang kamu catat akan muncul di sini.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.neutralContainer,
        highlightColor: AppColors.surface,
        child: ListView.builder(
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.sm),
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.neutralContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 14,
                          color: AppColors.neutralContainer,
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        Container(
                          width: 80,
                          height: 10,
                          color: AppColors.neutralContainer,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 16,
                    color: AppColors.neutralContainer,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDateHeader(String dateKey) {
    try {
      final date = DateTime.parse(dateKey);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final parsedDate = DateTime(date.year, date.month, date.day);

      if (parsedDate == today) return 'Hari Ini';
      if (parsedDate == yesterday) return 'Kemarin';
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return dateKey;
    }
  }
}
