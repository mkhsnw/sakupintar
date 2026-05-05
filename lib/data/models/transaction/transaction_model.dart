import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
abstract class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    required String type, // "income" | "expense"
    required double amount,
    required String categoryId,
    String? note,
    String? receiptUrl,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required Timestamp date,
    required String monthKey, // "YYYY-MM"
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}

Timestamp _timestampFromJson(dynamic value) =>
    value is Timestamp ? value : Timestamp.now();
dynamic _timestampToJson(Timestamp time) => time;
