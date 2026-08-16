import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

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

class Iso8601Converter implements JsonConverter<DateTime, String> {
  const Iso8601Converter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

@freezed
abstract class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    String? title,
    @JsonKey(name: 'amount_paise') required int amountPaise,
    @JsonKey(name: 'category_id') required String categoryId,
    required String type,
    @YyyyMmDdConverter() required DateTime date,
    String? notes,
    @JsonKey(name: 'is_recurring') @Default(false) bool isRecurring,
    @JsonKey(name: 'recurring_id') String? recurringId,
    @JsonKey(name: 'is_auto_captured') @Default(false) bool isAutoCaptured,
    @JsonKey(name: 'source_app') String? sourceApp,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'card_last_4') String? cardLast4,
    @JsonKey(name: 'account_last_4') String? accountLast4,
    @JsonKey(name: 'transaction_ref') String? transactionRef,
    @JsonKey(name: 'transfer_pair_id') String? transferPairId,
    @JsonKey(name: 'recurrence_occurrence_key') String? recurrenceOccurrenceKey,
    @JsonKey(name: 'source_message_id') String? sourceMessageId,
    @Iso8601Converter() @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}
