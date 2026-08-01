import 'package:freezed_annotation/freezed_annotation.dart';

part 'amount.freezed.dart';

@freezed
class Amount with _$Amount {
  const factory Amount(double value) = _Amount;

  const Amount._();

  bool get isPositive => value > 0;
  bool get isNegative => value < 0;
  String toFormattedString() => value.toStringAsFixed(2);
}
