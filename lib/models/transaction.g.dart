// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionModelImpl _$$TransactionModelImplFromJson(
  Map<String, dynamic> json,
) => _$TransactionModelImpl(
  id: json['id'] as String,
  title: json['title'] as String?,
  amountPaise: (json['amount_paise'] as num).toInt(),
  categoryId: json['category_id'] as String,
  type: json['type'] as String,
  date: const YyyyMmDdConverter().fromJson(json['date'] as String),
  notes: json['notes'] as String?,
  isRecurring: json['is_recurring'] as bool? ?? false,
  recurringId: json['recurring_id'] as String?,
  isAutoCaptured: json['is_auto_captured'] as bool? ?? false,
  sourceApp: json['source_app'] as String?,
  createdAt: _$JsonConverterFromJson<String, DateTime>(
    json['created_at'],
    const Iso8601Converter().fromJson,
  ),
);

Map<String, dynamic> _$$TransactionModelImplToJson(
  _$TransactionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'amount_paise': instance.amountPaise,
  'category_id': instance.categoryId,
  'type': instance.type,
  'date': const YyyyMmDdConverter().toJson(instance.date),
  'notes': instance.notes,
  'is_recurring': instance.isRecurring,
  'recurring_id': instance.recurringId,
  'is_auto_captured': instance.isAutoCaptured,
  'source_app': instance.sourceApp,
  'created_at': _$JsonConverterToJson<String, DateTime>(
    instance.createdAt,
    const Iso8601Converter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
