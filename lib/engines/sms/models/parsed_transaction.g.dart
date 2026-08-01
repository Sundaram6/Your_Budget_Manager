// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsed_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParsedTransactionImpl _$$ParsedTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$ParsedTransactionImpl(
  smsId: json['smsId'] as String,
  amount: (json['amount'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  merchantName: json['merchantName'] as String,
  merchantId: json['merchantId'] as String,
  categoryId: json['categoryId'] as String,
  originalSmsBody: json['originalSmsBody'] as String,
);

Map<String, dynamic> _$$ParsedTransactionImplToJson(
  _$ParsedTransactionImpl instance,
) => <String, dynamic>{
  'smsId': instance.smsId,
  'amount': instance.amount,
  'date': instance.date.toIso8601String(),
  'merchantName': instance.merchantName,
  'merchantId': instance.merchantId,
  'categoryId': instance.categoryId,
  'originalSmsBody': instance.originalSmsBody,
};
