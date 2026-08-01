// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetImpl _$$BudgetImplFromJson(Map<String, dynamic> json) => _$BudgetImpl(
  id: json['id'] as String,
  categoryId: json['categoryId'] as String,
  limit: const AmountConverter().fromJson(json['limit'] as num),
  periodType: $enumDecode(_$BudgetPeriodTypeEnumMap, json['periodType']),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
);

Map<String, dynamic> _$$BudgetImplToJson(_$BudgetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'limit': const AmountConverter().toJson(instance.limit),
      'periodType': _$BudgetPeriodTypeEnumMap[instance.periodType]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };

const _$BudgetPeriodTypeEnumMap = {
  BudgetPeriodType.monthly: 'monthly',
  BudgetPeriodType.weekly: 'weekly',
};
