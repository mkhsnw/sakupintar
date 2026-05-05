import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:sakupintar/core/theme/theme.dart';
import 'package:sakupintar/data/models/goal/goal_model.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_bloc.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_event.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_state.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
      
      final newGoal = GoalModel(
        id: const Uuid().v4(),
        title: _titleController.text,
        targetAmount: amount,
        savedAmount: 0.0,
        deadline: Timestamp.fromDate(_selectedDate!),
        createdAt: Timestamp.now(),
        isActive: true, // Make new goal active by default
      );

      context.read<GoalBloc>().add(AddGoal(newGoal));
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih deadline tabungan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GoalBloc, GoalState>(
      listenWhen: (previous, current) => previous.isSuccess != current.isSuccess || previous.error != current.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        } else if (state.isSuccess) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Target Baru',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputSection(
                  title: 'Apa impian yang ingin dicapai?',
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Beli Laptop Baru',
                      hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textDisabled),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        borderSide: const BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        borderSide: const BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Judul target tidak boleh kosong' : null,
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),
                _buildInputSection(
                  title: 'Berapa total dana yang dibutuhkan?',
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Rp 0',
                      hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textDisabled),
                      filled: true,
                      fillColor: AppColors.surface,
                      prefixText: 'Rp ',
                      prefixStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        borderSide: const BorderSide(color: AppColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        borderSide: const BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Nominal tidak boleh kosong' : null,
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),
                _buildInputSection(
                  title: 'Kapan target ini harus tercapai?',
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null ? 'Pilih Tanggal' : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                            style: AppTypography.bodyLarge.copyWith(
                              color: _selectedDate == null ? AppColors.textDisabled : AppColors.textPrimary,
                            ),
                          ),
                          const Icon(Icons.calendar_today_rounded, color: AppColors.neutral),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                BlocBuilder<GoalBloc, GoalState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _saveGoal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: AppColors.surface, strokeWidth: 2),
                              )
                            : Text(
                                'Buat Target',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        child,
      ],
    );
  }
}
