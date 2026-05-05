// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  uid: json['uid'] as String,
  nickname: json['nickname'] as String?,
  email: json['email'] as String,
  school: json['school'] as String?,
  primaryGoal: json['primaryGoal'] as String?,
  userType: json['userType'] as String?,
  photoUrl: json['photoUrl'] as String?,
  createdAt: _timestampFromJson(json['createdAt']),
  fcmToken: json['fcmToken'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'nickname': instance.nickname,
      'email': instance.email,
      'school': instance.school,
      'primaryGoal': instance.primaryGoal,
      'userType': instance.userType,
      'photoUrl': instance.photoUrl,
      'createdAt': _timestampToJson(instance.createdAt),
      'fcmToken': instance.fcmToken,
    };
