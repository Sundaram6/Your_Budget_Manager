import 'package:freezed_annotation/freezed_annotation.dart';

part 'parsed_transaction.freezed.dart';
part 'parsed_transaction.g.dart';

@freezed
class ParsedTransaction with _$ParsedTransaction {
  const factory ParsedTransaction({
    required String smsId, // unique ID of the SMS
    required double amount,
    required DateTime date,
    required String merchantName,
    required String merchantId,
    required String categoryId,
    required String originalSmsBody,
  }) = _ParsedTransaction;

  factory ParsedTransaction.fromJson(Map<String, dynamic> json) =>
      _$ParsedTransactionFromJson(json);
}
