import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_progress.freezed.dart';

@freezed
abstract class BudgetProgress with _$BudgetProgress {
  const factory BudgetProgress({
    required int spent, // Integer paise
    required int limit, // Integer paise
    required double percentage,
    required bool isOverBudget,
  }) = _BudgetProgress;
}
