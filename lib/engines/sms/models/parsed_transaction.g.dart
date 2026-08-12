// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsed_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParsedTransaction _$ParsedTransactionFromJson(Map<String, dynamic> json) =>
    _ParsedTransaction(
      smsId: json['smsId'] as String,
      amount: (json['amount'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      merchantName: json['merchantName'] as String,
      merchantId: json['merchantId'] as String,
      categoryId: json['categoryId'] as String,
      originalSmsBody: json['originalSmsBody'] as String,
      sourceApp: json['sourceApp'] as String,
      paymentMethod:
          $enumDecodeNullable(_$PaymentMethodEnumMap, json['paymentMethod']) ??
          PaymentMethod.unknown,
      cardLast4: json['cardLast4'] as String?,
    );

Map<String, dynamic> _$ParsedTransactionToJson(_ParsedTransaction instance) =>
    <String, dynamic>{
      'smsId': instance.smsId,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'merchantName': instance.merchantName,
      'merchantId': instance.merchantId,
      'categoryId': instance.categoryId,
      'originalSmsBody': instance.originalSmsBody,
      'sourceApp': instance.sourceApp,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'cardLast4': instance.cardLast4,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.upi: 'upi',
  PaymentMethod.debit_card: 'debit_card',
  PaymentMethod.credit_card: 'credit_card',
  PaymentMethod.cash: 'cash',
  PaymentMethod.unknown: 'unknown',
};
