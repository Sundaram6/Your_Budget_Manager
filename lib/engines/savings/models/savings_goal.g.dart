// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavingsGoalModel _$SavingsGoalModelFromJson(Map<String, dynamic> json) =>
    _SavingsGoalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      categoryId: json['categoryId'] as String?,
      targetDate: json['targetDate'] == null
          ? null
          : DateTime.parse(json['targetDate'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      status: $enumDecode(_$SavingsGoalStatusEnumMap, json['status']),
      iconName: json['iconName'] as String,
      colorHex: json['colorHex'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SavingsGoalModelToJson(_SavingsGoalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'targetAmount': instance.targetAmount,
      'currentAmount': instance.currentAmount,
      'categoryId': instance.categoryId,
      'targetDate': instance.targetDate?.toIso8601String(),
      'startDate': instance.startDate.toIso8601String(),
      'status': _$SavingsGoalStatusEnumMap[instance.status]!,
      'iconName': instance.iconName,
      'colorHex': instance.colorHex,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$SavingsGoalStatusEnumMap = {
  SavingsGoalStatus.active: 'active',
  SavingsGoalStatus.completed: 'completed',
  SavingsGoalStatus.paused: 'paused',
};
