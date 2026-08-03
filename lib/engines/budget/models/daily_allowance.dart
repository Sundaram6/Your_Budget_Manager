import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_allowance.freezed.dart';

@freezed
class DailyAllowance with _$DailyAllowance {
  const factory DailyAllowance({
    required int amount, // Integer daily allowance amount (in paise: e.g. 50000 = ₹500)
    required String message,
    required bool isOverBudget,
    required int remaining, // Integer remaining amount in paise
    required int daysLeft,
  }) = _DailyAllowance;
}
