// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryBreakdown _$CategoryBreakdownFromJson(Map<String, dynamic> json) =>
    _CategoryBreakdown(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      color: (json['color'] as num).toInt(),
      icon: json['icon'] as String,
      total: (json['total'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$CategoryBreakdownToJson(_CategoryBreakdown instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'color': instance.color,
      'icon': instance.icon,
      'total': instance.total,
      'percentage': instance.percentage,
    };

_DailyTrend _$DailyTrendFromJson(Map<String, dynamic> json) => _DailyTrend(
  date: DateTime.parse(json['date'] as String),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$DailyTrendToJson(_DailyTrend instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'total': instance.total,
    };

_MonthOverMonthComparison _$MonthOverMonthComparisonFromJson(
  Map<String, dynamic> json,
) => _MonthOverMonthComparison(
  currentTotal: (json['currentTotal'] as num).toInt(),
  previousTotal: (json['previousTotal'] as num).toInt(),
  changePercent: (json['changePercent'] as num).toDouble(),
);

Map<String, dynamic> _$MonthOverMonthComparisonToJson(
  _MonthOverMonthComparison instance,
) => <String, dynamic>{
  'currentTotal': instance.currentTotal,
  'previousTotal': instance.previousTotal,
  'changePercent': instance.changePercent,
};
