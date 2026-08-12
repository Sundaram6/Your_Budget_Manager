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

