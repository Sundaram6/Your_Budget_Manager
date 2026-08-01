import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_models.freezed.dart';
part 'analytics_models.g.dart';

@freezed
class CategoryBreakdown with _$CategoryBreakdown {
  const factory CategoryBreakdown({
    required String categoryId,
    required String categoryName,
    required int color,
    required String icon,
    required double total,
    required double percentage,
  }) = _CategoryBreakdown;

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      _$CategoryBreakdownFromJson(json);
}

@freezed
class DailyTrend with _$DailyTrend {
  const factory DailyTrend({
    required DateTime date,
    required double total,
  }) = _DailyTrend;

  factory DailyTrend.fromJson(Map<String, dynamic> json) =>
      _$DailyTrendFromJson(json);
}

@freezed
class MonthOverMonthComparison with _$MonthOverMonthComparison {
  const factory MonthOverMonthComparison({
    required double currentTotal,
    required double previousTotal,
    required double changePercent,
  }) = _MonthOverMonthComparison;

  factory MonthOverMonthComparison.fromJson(Map<String, dynamic> json) =>
      _$MonthOverMonthComparisonFromJson(json);
}
