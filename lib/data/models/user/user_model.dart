import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    String? nickname,
    required String email,
    String? school,
    String? primaryGoal, // "Menabung" | "Mengatur Jajan" | "Investasi"
    String? userType, // "Hemat" | "Impulsif" | "Konsisten"
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    Timestamp? createdAt,
    String? fcmToken,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

Timestamp? _timestampFromJson(dynamic value) =>
    value is Timestamp ? value : null;
dynamic _timestampToJson(Timestamp? time) => time;
