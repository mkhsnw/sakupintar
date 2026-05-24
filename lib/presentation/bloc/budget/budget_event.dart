import 'package:equatable/equatable.dart';
import 'package:sakupintar/data/models/budget/budget_model.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudget extends BudgetEvent {
  final String monthKey;

  const LoadBudget(this.monthKey);

  @override
  List<Object?> get props => [monthKey];
}

class BudgetUpdated extends BudgetEvent {
  final BudgetModel? budget;

  const BudgetUpdated(this.budget);

  @override
  List<Object?> get props => [budget];
}

class SaveBudget extends BudgetEvent {
  final BudgetModel budget;

  const SaveBudget(this.budget);

  @override
  List<Object?> get props => [budget];
}

class BudgetError extends BudgetEvent {
  final String error;

  const BudgetError(this.error);

  @override
  List<Object?> get props => [error];
}
