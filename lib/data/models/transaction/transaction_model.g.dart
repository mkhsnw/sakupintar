// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    _TransactionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      note: json['note'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      date: _timestampFromJson(json['date']),
      monthKey: json['monthKey'] as String,
    );

Map<String, dynamic> _$TransactionModelToJson(_TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'categoryId': instance.categoryId,
      'note': instance.note,
      'receiptUrl': instance.receiptUrl,
      'date': _timestampToJson(instance.date),
      'monthKey': instance.monthKey,
    };
