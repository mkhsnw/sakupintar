import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'budget_model.freezed.dart';
part 'budget_model.g.dart';

@freezed
abstract class BudgetModel with _$BudgetModel {
  const factory BudgetModel({
    required String monthKey, // "YYYY-MM"
    required double income,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required Timestamp createdAt,
    @Default([]) List<AllocationModel> allocations,
  }) = _BudgetModel;

  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);
}

@freezed
abstract class AllocationModel with _$AllocationModel {
  const factory AllocationModel({
    required String categoryId,
    required String label,
    required double limitAmount,
    required double percentage,
  }) = _AllocationModel;

  factory AllocationModel.fromJson(Map<String, dynamic> json) =>
      _$AllocationModelFromJson(json);
}

Timestamp _timestampFromJson(dynamic value) =>
    value is Timestamp ? value : Timestamp.now();
dynamic _timestampToJson(Timestamp time) => time;
