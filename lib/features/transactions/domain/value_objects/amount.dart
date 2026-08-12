import 'package:freezed_annotation/freezed_annotation.dart';

part 'amount.freezed.dart';

@freezed
abstract class Amount with _$Amount {
  /// Stores amount in integer paise (1 rupee = 100 paise).
  const factory Amount(int value) = _Amount;

  const Amount._();

  bool get isPositive => value > 0;
  bool get isNegative => value < 0;
  double toRupees() => value / 100.0;
  String toFormattedString() => (value / 100.0).toStringAsFixed(2);
}
