import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakupintar/data/repositories/transaction_repository.dart';
import 'package:sakupintar/data/repositories/goal_repository.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_event.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;
  final GoalRepository? _goalRepository;
  StreamSubscription? _transactionsSubscription;

  TransactionBloc({
    required TransactionRepository repository,
    GoalRepository? goalRepository,
  })  : _repository = repository,
        _goalRepository = goalRepository,
        super(const TransactionState()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<TransactionsUpdated>(_onTransactionsUpdated);
    on<AddTransaction>(_onAddTransaction);
    on<TransactionError>(_onTransactionError);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _transactionsSubscription?.cancel();
      _transactionsSubscription = _repository
          .streamTransactions(event.monthKey)
          .listen(
            (transactions) => add(TransactionsUpdated(transactions)),
            onError: (error) {
              // Dispatch error event instead of returning empty list
              add(TransactionError(error.toString()));
            },
          );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onTransactionsUpdated(
    TransactionsUpdated event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(
      transactions: event.transactions,
      isLoading: false,
    ));
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isSuccess: false).clearError());
    try {
      var transaction = event.transaction;
      if (event.receiptFile != null) {
        final receiptUrl = await _repository.uploadReceipt(
            event.receiptFile!, transaction.id);
        transaction = transaction.copyWith(receiptUrl: receiptUrl);
      }
      await _repository.addTransaction(transaction);
      
      if (event.goalId != null && _goalRepository != null) {
        await _goalRepository.addSavedAmount(event.goalId!, transaction.amount);
      }
      
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onTransactionError(
    TransactionError event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(isLoading: false, error: event.error));
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    return super.close();
  }
}
