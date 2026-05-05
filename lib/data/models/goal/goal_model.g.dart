// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoalModel _$GoalModelFromJson(Map<String, dynamic> json) => _GoalModel(
  id: json['id'] as String,
  title: json['title'] as String,
  targetAmount: (json['targetAmount'] as num).toDouble(),
  savedAmount: (json['savedAmount'] as num).toDouble(),
  deadline: _timestampFromJson(json['deadline']),
  imageUrl: json['imageUrl'] as String?,
  isCompleted: json['isCompleted'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? false,
  createdAt: _timestampFromJson(json['createdAt']),
);

Map<String, dynamic> _$GoalModelToJson(_GoalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'targetAmount': instance.targetAmount,
      'savedAmount': instance.savedAmount,
      'deadline': _timestampToJson(instance.deadline),
      'imageUrl': instance.imageUrl,
      'isCompleted': instance.isCompleted,
      'isActive': instance.isActive,
      'createdAt': _timestampToJson(instance.createdAt),
    };
