import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakupintar/data/repositories/budget_repository.dart';
import 'package:sakupintar/presentation/bloc/budget/budget_event.dart';
import 'package:sakupintar/presentation/bloc/budget/budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository _repository;
  StreamSubscription? _budgetSubscription;

  BudgetBloc({required BudgetRepository repository})
      : _repository = repository,
        super(const BudgetState()) {
    on<LoadBudget>(_onLoadBudget);
    on<BudgetUpdated>(_onBudgetUpdated);
    on<SaveBudget>(_onSaveBudget);
    on<BudgetError>(_onBudgetError);
  }

  Future<void> _onLoadBudget(
    LoadBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true).clearError());
    try {
      await _budgetSubscription?.cancel();
      _budgetSubscription = _repository.streamBudget(event.monthKey).listen(
        (budget) => add(BudgetUpdated(budget)),
        onError: (error) {
          // Don't emit here - use add() to dispatch error event instead
          add(BudgetError(error.toString()));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onBudgetUpdated(
    BudgetUpdated event,
    Emitter<BudgetState> emit,
  ) {
    emit(state.copyWith(
      currentBudget: event.budget,
      clearBudget: event.budget == null,
      isLoading: false,
    ));
  }

  Future<void> _onSaveBudget(
    SaveBudget event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isSuccess: false).clearError());
    try {
      await _repository.saveBudget(event.budget);
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onBudgetError(
    BudgetError event,
    Emitter<BudgetState> emit,
  ) {
    emit(state.copyWith(isLoading: false, error: event.error));
  }

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    return super.close();
  }
}
