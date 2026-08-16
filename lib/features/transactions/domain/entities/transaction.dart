import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums.dart';
import '../value_objects/amount.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

class AmountConverter implements JsonConverter<Amount, num> {
  const AmountConverter();

  @override
  Amount fromJson(num json) => Amount(json.toInt());

  @override
  num toJson(Amount object) => object.value;
}

@freezed
abstract class Transaction with _$Transaction {
  const Transaction._();

  const factory Transaction({
    required String id,
    @AmountConverter() required Amount amount,
    required DateTime date,
    required String categoryId,
    required TransactionType type,
    String? note,
    String? sourceApp,
    @Default(PaymentMethod.unknown) PaymentMethod paymentMethod,
    String? cardLast4,
    String? accountLast4,
    String? transactionRef,
    String? transferPairId,
    @Default(false) bool isRecurring,
    String? recurringId,
    String? merchantName,
    String? merchantId,
    String? recurrenceOccurrenceKey,
    String? sourceMessageId,
    int? createdAt,
    int? updatedAt,
  }) = _Transaction;

  bool get isSelfTransfer => transferPairId != null && transferPairId!.trim().isNotEmpty;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
