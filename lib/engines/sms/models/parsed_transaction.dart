import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums.dart';

part 'parsed_transaction.freezed.dart';
part 'parsed_transaction.g.dart';

@freezed
abstract class ParsedTransaction with _$ParsedTransaction {
  const factory ParsedTransaction({
    required String smsId, // unique ID of the SMS
    required int amount,
    required DateTime date,
    required TransactionType type,
    required String merchantName,
    required String merchantId,
    required String categoryId,
    required String originalSmsBody,
    required String sourceApp,
    @Default(PaymentMethod.unknown) PaymentMethod paymentMethod,
    String? cardLast4,
    String? accountLast4,
    String? transactionRef,
  }) = _ParsedTransaction;

  factory ParsedTransaction.fromJson(Map<String, dynamic> json) =>
      _$ParsedTransactionFromJson(json);
}
