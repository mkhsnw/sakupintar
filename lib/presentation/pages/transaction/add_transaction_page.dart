import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakupintar/core/utils/image_helper.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sakupintar/core/utils/formatters.dart';
import 'package:sakupintar/data/models/transaction/transaction_model.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_event.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_state.dart';
import 'package:sakupintar/presentation/bloc/category/category_bloc.dart';
import 'package:sakupintar/presentation/bloc/category/category_state.dart';
import 'package:sakupintar/presentation/bloc/category/category_event.dart';
import 'package:sakupintar/data/models/category/category_model.dart';

import 'package:sakupintar/presentation/bloc/goal/goal_bloc.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_state.dart';

class AddTransactionPage extends StatefulWidget {
  final String type; // 'income' or 'expense'
  final String? goalId;

  const AddTransactionPage({super.key, required this.type, this.goalId});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  DateTime _transactionTime = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = 'default_jajan'; // For expense
  String? _selectedGoalId;
  File? _receiptFile;

  @override
  void initState() {
    super.initState();
    if (widget.goalId != null) {
      _selectedCategory = 'default_nabung';
      _selectedGoalId = widget.goalId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get isExpense => widget.type == 'expense';

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state.isSuccess) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 64),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Berhasil!',
                      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Transaksi berhasil ditambahkan.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.pop();
                        },
                        child: Text(
                          'Tutup',
                          style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            isExpense ? 'New Expense' : 'New Income',
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAmountSection(),
                const SizedBox(height: AppDimensions.xl),
                if (isExpense) ...[
                  _buildCategorySection(),
                  const SizedBox(height: AppDimensions.xl),
                  if (_selectedCategory == 'default_nabung') ...[
                    _buildGoalSelectionSection(),
                    const SizedBox(height: AppDimensions.xl),
                  ],
                ],
                _buildTimeSection(),
                const SizedBox(height: AppDimensions.xl),
                _buildNoteSection(),
                const SizedBox(height: AppDimensions.xl),
                _buildReceiptSection(),
                const SizedBox(height: 100), // padding for bottom button
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _buildSaveButton(),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Center(
      child: Column(
        children: [
          Text(
            isExpense ? 'AMOUNT SPENT' : 'AMOUNT RECEIVED',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors
                        .primaryContainer, // Like the 0 in reference, but we use a better color
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppTypography.displayMedium.copyWith(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w300,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppDimensions.md),
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  ...state.categories.map((cat) {
                    Color iconColor;
                    try {
                      iconColor = Color(int.parse(cat.color));
                    } catch (_) {
                      iconColor = AppColors.primary;
                    }
                    
                    IconData iconData = Icons.category_rounded;
                    if (cat.icon == 'restaurant_rounded') iconData = Icons.restaurant_rounded;
                    else if (cat.icon == 'savings_rounded') iconData = Icons.savings_rounded;
                    else if (cat.icon == 'sports_esports_rounded') iconData = Icons.sports_esports_rounded;

                    return Padding(
                      padding: const EdgeInsets.only(right: AppDimensions.md),
                      child: _buildCategoryChip(
                        id: cat.id,
                        title: cat.name,
                        icon: iconData,
                        iconColor: iconColor,
                        backgroundColor: iconColor.withOpacity(0.1),
                      ),
                    );
                  }).toList(),
                  _buildCategoryChip(
                    id: 'custom_add',
                    title: 'Custom',
                    icon: Icons.add_rounded,
                    iconColor: AppColors.neutral,
                    backgroundColor: AppColors.neutralContainer,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String id,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    final isSelected = _selectedCategory == id && id != 'custom_add';

    return InkWell(
      onTap: () {
        if (id == 'custom_add') {
          _showAddCustomCategoryDialog();
        } else {
          setState(() {
            _selectedCategory = id;
            if (id != 'default_nabung') {
              _selectedGoalId = null;
            }
          });
        }
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSelectionSection() {
    return BlocBuilder<GoalBloc, GoalState>(
      builder: (context, state) {
        if (state.goals.isEmpty) {
          return const SizedBox.shrink();
        }
        
        _selectedGoalId ??= state.activeGoal?.id ?? state.goals.first.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Tabungan',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimensions.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGoalId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: state.goals.map((goal) {
                    return DropdownMenuItem<String>(
                      value: goal.id,
                      child: Text(
                        goal.title,
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedGoalId = value);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeSection() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _transactionTime,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          if (!context.mounted) return;
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_transactionTime),
          );
          if (!context.mounted) return;
          if (time != null) {
            setState(() {
              _transactionTime = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            });
          }
        }
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRANSACTION TIME',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MM/dd/yyyy, hh:mm a').format(_transactionTime),
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.neutral,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(
              Icons.notes_rounded,
              color: AppColors.neutral,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADD NOTE (OPTIONAL)',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextField(
                  controller: _noteController,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'What was this for?',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.neutral,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.only(top: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Receipt Photo',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
            ),
            if (_receiptFile != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
                onPressed: () => setState(() => _receiptFile = null),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        InkWell(
          onTap: () async {
            final file = await ImageHelper.pickAndCompressImage();
            if (file != null) {
              setState(() => _receiptFile = file);
            }
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: _receiptFile != null ? 0 : AppDimensions.xxl),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _receiptFile != null
                ? Image.file(_receiptFile!, fit: BoxFit.cover, height: 200, width: double.infinity)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                      const SizedBox(height: AppDimensions.md),
                      Text(
                        'Upload receipt',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Maximum size 5MB',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
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
              final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
              if (amountText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an amount')),
                );
                return;
              }
              final amount = double.parse(amountText);
              
              if (isExpense) {
                final state = context.read<TransactionBloc>().state;
                double totalIncome = 0;
                double totalExpense = 0;
                for (final tx in state.transactions) {
                  if (tx.type == 'income') totalIncome += tx.amount;
                  if (tx.type == 'expense') totalExpense += tx.amount;
                }
                
                if (totalExpense + amount > totalIncome) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pengeluaran tidak boleh melebihi sisa pemasukan bulan ini!')),
                  );
                  return;
                }
              }

              final transaction = TransactionModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                type: widget.type,
                amount: amount,
                categoryId: isExpense ? _selectedCategory : 'income_default',
                note: _noteController.text,
                date: Timestamp.fromDate(_transactionTime),
                monthKey: Formatters.getMonthKey(_transactionTime),
              );

              context.read<TransactionBloc>().add(AddTransaction(
                transaction,
                receiptFile: _receiptFile,
                goalId: _selectedCategory == 'default_nabung' ? _selectedGoalId : null,
              ));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Text(
                  'Save Transaction',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCustomCategoryDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Tambah Kategori Custom',
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Nama Kategori',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final cat = CategoryModel(
                    id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    icon: 'category_rounded',
                    color: '0xFF2962FF',
                    createdAt: Timestamp.now() as dynamic,
                  );
                  context.read<CategoryBloc>().add(AddCategory(cat));
                  Navigator.pop(dialogContext);
                  setState(() => _selectedCategory = cat.id);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
