import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_models.freezed.dart';
part 'analytics_models.g.dart';

@freezed
abstract class CategoryBreakdown with _$CategoryBreakdown {
  const factory CategoryBreakdown({
    required String categoryId,
    required String categoryName,
    required int color,
    required String icon,
    required int total, // Integer paise
    required double percentage,
  }) = _CategoryBreakdown;

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      _$CategoryBreakdownFromJson(json);
}

@freezed
abstract class DailyTrend with _$DailyTrend {
  const factory DailyTrend({
    required DateTime date,
    required int total, // Integer paise
  }) = _DailyTrend;

  factory DailyTrend.fromJson(Map<String, dynamic> json) =>
      _$DailyTrendFromJson(json);
}

@freezed
abstract class MonthOverMonthComparison with _$MonthOverMonthComparison {
  const factory MonthOverMonthComparison({
    required int currentTotal, // Integer paise
    required int previousTotal, // Integer paise
    required double changePercent,
  }) = _MonthOverMonthComparison;

  factory MonthOverMonthComparison.fromJson(Map<String, dynamic> json) =>
      _$MonthOverMonthComparisonFromJson(json);
}

@freezed
abstract class RecurringCommitmentSummary with _$RecurringCommitmentSummary {
  const factory RecurringCommitmentSummary({
    required int totalMonthlyRecurringPaise, // Normalized monthly total for active recurring expenses
    required int upcomingRecurringThisMonthPaise, // Upcoming unposted recurring spend this month
    required int recurringCount, // Number of active recurring expense schedules
    required double recurringExpenseRatio, // Percentage of monthly spend/budget that is recurring
  }) = _RecurringCommitmentSummary;

  factory RecurringCommitmentSummary.fromJson(Map<String, dynamic> json) =>
      _$RecurringCommitmentSummaryFromJson(json);
}

@freezed
abstract class SavingsAnalyticsSummary with _$SavingsAnalyticsSummary {
  const factory SavingsAnalyticsSummary({
    required int totalGoalsCount, // Total savings goals count
    required int activeGoalsCount, // Active savings goals count
    required int totalSavedPaise, // Total saved amount across all goals
    required int totalTargetPaise, // Total target amount across all goals
    required int monthlyCommittedAutoSavePaise, // Monthly committed auto-deduct total
    required double overallProgressPercent, // Overall progress across goals (0.0 to 100.0)
  }) = _SavingsAnalyticsSummary;

  factory SavingsAnalyticsSummary.fromJson(Map<String, dynamic> json) =>
      _$SavingsAnalyticsSummaryFromJson(json);
}
