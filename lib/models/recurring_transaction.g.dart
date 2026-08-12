// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecurringTransactionModel _$RecurringTransactionModelFromJson(
  Map<String, dynamic> json,
) => _RecurringTransactionModel(
  id: json['id'] as String,
  title: json['title'] as String,
  amountPaise: (json['amount_paise'] as num).toInt(),
  categoryId: json['category_id'] as String,
  type: json['type'] as String,
  frequency: json['frequency'] as String,
  intervalDays: (json['interval_days'] as num?)?.toInt(),
  startDate: const YyyyMmDdConverter().fromJson(json['start_date'] as String),
  endDate: const NullableYyyyMmDdConverter().fromJson(
    json['end_date'] as String?,
  ),
  nextDueDate: const YyyyMmDdConverter().fromJson(
    json['next_due_date'] as String,
  ),
  lastGeneratedDate: const NullableYyyyMmDdConverter().fromJson(
    json['last_generated_date'] as String?,
  ),
  isActive: json['is_active'] as bool? ?? true,
  autoConfirm: json['auto_confirm'] as bool? ?? false,
  notes: json['notes'] as String?,
  createdAt: const Iso8601Converter().fromJson(json['created_at'] as String),
  updatedAt: const Iso8601Converter().fromJson(json['updated_at'] as String),
);

Map<String, dynamic> _$RecurringTransactionModelToJson(
  _RecurringTransactionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'amount_paise': instance.amountPaise,
  'category_id': instance.categoryId,
  'type': instance.type,
  'frequency': instance.frequency,
  'interval_days': instance.intervalDays,
  'start_date': const YyyyMmDdConverter().toJson(instance.startDate),
  'end_date': const NullableYyyyMmDdConverter().toJson(instance.endDate),
  'next_due_date': const YyyyMmDdConverter().toJson(instance.nextDueDate),
  'last_generated_date': const NullableYyyyMmDdConverter().toJson(
    instance.lastGeneratedDate,
  ),
  'is_active': instance.isActive,
  'auto_confirm': instance.autoConfirm,
  'notes': instance.notes,
  'created_at': const Iso8601Converter().toJson(instance.createdAt),
  'updated_at': const Iso8601Converter().toJson(instance.updatedAt),
};
