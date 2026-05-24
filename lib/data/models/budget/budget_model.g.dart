// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetModel _$BudgetModelFromJson(Map<String, dynamic> json) => _BudgetModel(
  monthKey: json['monthKey'] as String,
  income: (json['income'] as num).toDouble(),
  createdAt: _timestampFromJson(json['createdAt']),
  allocations:
      (json['allocations'] as List<dynamic>?)
          ?.map((e) => AllocationModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$BudgetModelToJson(_BudgetModel instance) =>
    <String, dynamic>{
      'monthKey': instance.monthKey,
      'income': instance.income,
      'createdAt': _timestampToJson(instance.createdAt),
      'allocations': instance.allocations.map((e) => e.toJson()).toList(),
    };

_AllocationModel _$AllocationModelFromJson(Map<String, dynamic> json) =>
    _AllocationModel(
      categoryId: json['categoryId'] as String,
      label: json['label'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$AllocationModelToJson(_AllocationModel instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'label': instance.label,
      'limitAmount': instance.limitAmount,
      'percentage': instance.percentage,
    };
