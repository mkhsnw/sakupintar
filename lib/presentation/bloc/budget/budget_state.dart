import 'package:equatable/equatable.dart';
import 'package:sakupintar/data/models/budget/budget_model.dart';

class BudgetState extends Equatable {
  final BudgetModel? currentBudget;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const BudgetState({
    this.currentBudget,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  BudgetState copyWith({
    BudgetModel? currentBudget,
    bool? isLoading,
    String? error,
    bool? isSuccess,
    bool clearBudget = false,
  }) {
    return BudgetState(
      currentBudget: clearBudget ? null : (currentBudget ?? this.currentBudget),
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  BudgetState clearError() {
    return BudgetState(
      currentBudget: currentBudget,
      isLoading: isLoading,
      error: null,
      isSuccess: isSuccess,
    );
  }

  @override
  List<Object?> get props => [currentBudget, isLoading, error, isSuccess];
}
