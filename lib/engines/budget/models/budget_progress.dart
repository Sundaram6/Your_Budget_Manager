import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_progress.freezed.dart';

@freezed
abstract class BudgetProgress with _$BudgetProgress {
  const factory BudgetProgress({
    required int spent, // Integer paise (posted expense transactions)
    required int limit, // Integer paise (monthly budget limit)
    required double percentage,
    required bool isOverBudget,
    @Default(0) int committedRecurring, // Upcoming active recurring expenses this period (paise)
    @Default(0) int committedSavings, // Scheduled unexecuted auto-deduct goals this period (paise)
    @Default(0) int totalCommitted, // spent + committedRecurring + committedSavings (paise)
    @Default(0) int remaining, // signed: limit - totalCommitted (paise)
  }) = _BudgetProgress;
}
