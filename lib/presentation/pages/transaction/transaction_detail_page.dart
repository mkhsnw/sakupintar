import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/data/models/transaction/transaction_model.dart';
import 'package:sakupintar/core/utils/formatters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakupintar/presentation/bloc/category/category_bloc.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(AppDimensions.md),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.error_outline, size: 50, color: AppColors.error),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == 'expense';
    final amountColor = isExpense ? AppColors.expense : AppColors.income;
    final amountPrefix = isExpense ? '-' : '+';
    
    // Find category
    final categoryState = context.read<CategoryBloc>().state;
    final category = categoryState.categories.firstWhere(
      (c) => c.id == transaction.categoryId,
      orElse: () => categoryState.categories.first, // Fallback
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Transaksi',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: AppDimensions.xl),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: amountColor,
                size: 40,
              ),
            ),
            SizedBox(height: AppDimensions.md),
            Text(
              '$amountPrefix Rp ${Formatters.formatCurrency(transaction.amount).replaceAll('Rp ', '')}',
              style: AppTypography.displayMedium.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: AppDimensions.xs),
            Text(
              Formatters.formatDateTime(transaction.date.toDate()),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppDimensions.xxl),
            
            // Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Tipe', isExpense ? 'Pengeluaran' : 'Pemasukan'),
                  Divider(color: AppColors.cardBorder, height: 32),
                  _buildDetailRow('Kategori', category.name),
                  Divider(color: AppColors.cardBorder, height: 32),
                  _buildDetailRow('Catatan', transaction.note?.isNotEmpty == true ? transaction.note! : '-'),
                ],
              ),
            ),
            SizedBox(height: AppDimensions.xl),
            
            // Receipt Image
            if (transaction.receiptUrl != null && transaction.receiptUrl!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bukti Transaksi',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: AppDimensions.md),
                  GestureDetector(
                    onTap: () => _showImagePopup(context, transaction.receiptUrl!),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(color: AppColors.cardBorder),
                        image: DecorationImage(
                          image: NetworkImage(transaction.receiptUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                            ),
                          ),
                          Icon(Icons.zoom_in_rounded, color: Colors.white, size: 48),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
