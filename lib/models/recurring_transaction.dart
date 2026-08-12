import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_transaction.freezed.dart';
part 'recurring_transaction.g.dart';

class YyyyMmDdConverter implements JsonConverter<DateTime, String> {
  const YyyyMmDdConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) {
    final y = object.year.toString().padLeft(4, '0');
    final m = object.month.toString().padLeft(2, '0');
    final d = object.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class NullableYyyyMmDdConverter implements JsonConverter<DateTime?, String?> {
  const NullableYyyyMmDdConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    return DateTime.parse(json);
  }

  @override
  String? toJson(DateTime? object) {
    if (object == null) return null;
    final y = object.year.toString().padLeft(4, '0');
    final m = object.month.toString().padLeft(2, '0');
    final d = object.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class Iso8601Converter implements JsonConverter<DateTime, String> {
  const Iso8601Converter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

@freezed
abstract class RecurringTransactionModel with _$RecurringTransactionModel {
  const factory RecurringTransactionModel({
    required String id,
    required String title,
    @JsonKey(name: 'amount_paise') required int amountPaise,
    @JsonKey(name: 'category_id') required String categoryId,
    required String type,
    required String frequency,
    @JsonKey(name: 'interval_days') int? intervalDays,
    @YyyyMmDdConverter() @JsonKey(name: 'start_date') required DateTime startDate,
    @NullableYyyyMmDdConverter() @JsonKey(name: 'end_date') DateTime? endDate,
    @YyyyMmDdConverter() @JsonKey(name: 'next_due_date') required DateTime nextDueDate,
    @NullableYyyyMmDdConverter() @JsonKey(name: 'last_generated_date') DateTime? lastGeneratedDate,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'auto_confirm') @Default(false) bool autoConfirm,
    String? notes,
    @Iso8601Converter() @JsonKey(name: 'created_at') required DateTime createdAt,
    @Iso8601Converter() @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _RecurringTransactionModel;

  factory RecurringTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$RecurringTransactionModelFromJson(json);
}
