// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecurringTransactionImpl _$$RecurringTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$RecurringTransactionImpl(
  id: json['id'] as String,
  amount: const AmountConverter().fromJson(json['amount'] as num),
  categoryId: json['categoryId'] as String,
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  frequency: $enumDecode(_$RecurringFrequencyEnumMap, json['frequency']),
  nextDate: DateTime.parse(json['nextDate'] as String),
  note: json['note'] as String?,
);

Map<String, dynamic> _$$RecurringTransactionImplToJson(
  _$RecurringTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': const AmountConverter().toJson(instance.amount),
  'categoryId': instance.categoryId,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'frequency': _$RecurringFrequencyEnumMap[instance.frequency]!,
  'nextDate': instance.nextDate.toIso8601String(),
  'note': instance.note,
};

const _$TransactionTypeEnumMap = {
  TransactionType.expense: 'expense',
  TransactionType.income: 'income',
};

const _$RecurringFrequencyEnumMap = {
  RecurringFrequency.daily: 'daily',
  RecurringFrequency.weekly: 'weekly',
  RecurringFrequency.monthly: 'monthly',
  RecurringFrequency.yearly: 'yearly',
};
