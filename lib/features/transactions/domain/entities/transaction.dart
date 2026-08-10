import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums.dart';
import '../value_objects/amount.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

class AmountConverter implements JsonConverter<Amount, num> {
  const AmountConverter();

  @override
  Amount fromJson(num json) => Amount(json.toDouble());

  @override
  num toJson(Amount object) => object.value;
}

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    @AmountConverter() required Amount amount,
    required DateTime date,
    required String categoryId,
    required TransactionType type,
    String? note,
    String? sourceApp,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
