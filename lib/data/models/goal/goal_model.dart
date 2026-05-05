import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'goal_model.freezed.dart';
part 'goal_model.g.dart';

@freezed
abstract class GoalModel with _$GoalModel {
  const factory GoalModel({
    required String id,
    required String title,
    required double targetAmount,
    required double savedAmount,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required Timestamp deadline,
    String? imageUrl,
    @Default(false) bool isCompleted,
    @Default(false) bool isActive,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required Timestamp createdAt,
  }) = _GoalModel;

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);
}

Timestamp _timestampFromJson(dynamic value) =>
    value is Timestamp ? value : Timestamp.now();
dynamic _timestampToJson(Timestamp time) => time;
