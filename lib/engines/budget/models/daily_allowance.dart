import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_allowance.freezed.dart';

@freezed
class DailyAllowance with _$DailyAllowance {
  const factory DailyAllowance({
    required double amount,
    required double remaining,
    required int daysLeft,
    required bool isHealthy,
  }) = _DailyAllowance;
}
