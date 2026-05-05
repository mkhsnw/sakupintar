import 'package:equatable/equatable.dart';
import 'package:sakupintar/data/models/transaction/transaction_model.dart';

class TransactionState extends Equatable {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;
  final bool isSuccess; // Untuk trigger animasi success

  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Jika error tidak di-pass null explicitly, behavior copyWith normal biasanya preserve, tapi kita butuh error = null saat reset. Kita pakai pattern berbeda.
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
  
  TransactionState clearError() {
    return TransactionState(
      transactions: transactions,
      isLoading: isLoading,
      error: null,
      isSuccess: isSuccess,
    );
  }

  @override
  List<Object?> get props => [transactions, isLoading, error, isSuccess];
}
