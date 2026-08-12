// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Transaction _$TransactionFromJson(Map<String, dynamic> json) => _Transaction(
  id: json['id'] as String,
  amount: const AmountConverter().fromJson(json['amount'] as num),
  date: DateTime.parse(json['date'] as String),
  categoryId: json['categoryId'] as String,
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  note: json['note'] as String?,
  sourceApp: json['sourceApp'] as String?,
  paymentMethod:
      $enumDecodeNullable(_$PaymentMethodEnumMap, json['paymentMethod']) ??
      PaymentMethod.unknown,
  cardLast4: json['cardLast4'] as String?,
);

Map<String, dynamic> _$TransactionToJson(_Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': const AmountConverter().toJson(instance.amount),
      'date': instance.date.toIso8601String(),
      'categoryId': instance.categoryId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'note': instance.note,
      'sourceApp': instance.sourceApp,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'cardLast4': instance.cardLast4,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.expense: 'expense',
  TransactionType.income: 'income',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.upi: 'upi',
  PaymentMethod.debit_card: 'debit_card',
  PaymentMethod.credit_card: 'credit_card',
  PaymentMethod.cash: 'cash',
  PaymentMethod.unknown: 'unknown',
};
