import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:sakupintar/data/models/transaction/transaction_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final String monthKey;

  const LoadTransactions(this.monthKey);

  @override
  List<Object?> get props => [monthKey];
}

class AddTransaction extends TransactionEvent {
  final TransactionModel transaction;
  final File? receiptFile;
  final String? goalId;

  const AddTransaction(this.transaction, {this.receiptFile, this.goalId});

  @override
  List<Object?> get props => [transaction, receiptFile, goalId];
}

class TransactionsUpdated extends TransactionEvent {
  final List<TransactionModel> transactions;

  const TransactionsUpdated(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionError extends TransactionEvent {
  final String error;

  const TransactionError(this.error);

  @override
  List<Object?> get props => [error];
}
