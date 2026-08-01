import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/value_objects/amount.dart';

part 'recurring_transaction.freezed.dart';
part 'recurring_transaction.g.dart';

@freezed
class RecurringTransaction with _$RecurringTransaction {
  const factory RecurringTransaction({
    required String id,
    @AmountConverter() required Amount amount,
    required String categoryId,
    required TransactionType type,
    required RecurringFrequency frequency,
    required DateTime nextDate,
    String? note,
  }) = _RecurringTransaction;

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) =>
      _$RecurringTransactionFromJson(json);
}
