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
  accountLast4: json['accountLast4'] as String?,
  transactionRef: json['transactionRef'] as String?,
  transferPairId: json['transferPairId'] as String?,
  isRecurring: json['isRecurring'] as bool? ?? false,
  recurringId: json['recurringId'] as String?,
  merchantName: json['merchantName'] as String?,
  merchantId: json['merchantId'] as String?,
  recurrenceOccurrenceKey: json['recurrenceOccurrenceKey'] as String?,
  sourceMessageId: json['sourceMessageId'] as String?,
  createdAt: (json['createdAt'] as num?)?.toInt(),
  updatedAt: (json['updatedAt'] as num?)?.toInt(),
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
      'accountLast4': instance.accountLast4,
      'transactionRef': instance.transactionRef,
      'transferPairId': instance.transferPairId,
      'isRecurring': instance.isRecurring,
      'recurringId': instance.recurringId,
      'merchantName': instance.merchantName,
      'merchantId': instance.merchantId,
      'recurrenceOccurrenceKey': instance.recurrenceOccurrenceKey,
      'sourceMessageId': instance.sourceMessageId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
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
