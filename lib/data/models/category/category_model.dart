import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
abstract class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    required String icon,
    required String color,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required Timestamp createdAt,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
}

Timestamp _timestampFromJson(dynamic value) =>
    value is Timestamp ? value : Timestamp.now();
dynamic _timestampToJson(Timestamp time) => time;
