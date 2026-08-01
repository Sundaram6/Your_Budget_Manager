// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryBreakdownImpl _$$CategoryBreakdownImplFromJson(
  Map<String, dynamic> json,
) => _$CategoryBreakdownImpl(
  categoryId: json['categoryId'] as String,
  categoryName: json['categoryName'] as String,
  color: (json['color'] as num).toInt(),
  icon: json['icon'] as String,
  total: (json['total'] as num).toDouble(),
  percentage: (json['percentage'] as num).toDouble(),
);

Map<String, dynamic> _$$CategoryBreakdownImplToJson(
  _$CategoryBreakdownImpl instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'color': instance.color,
  'icon': instance.icon,
  'total': instance.total,
  'percentage': instance.percentage,
};

_$DailyTrendImpl _$$DailyTrendImplFromJson(Map<String, dynamic> json) =>
    _$DailyTrendImpl(
      date: DateTime.parse(json['date'] as String),
      total: (json['total'] as num).toDouble(),
    );

Map<String, dynamic> _$$DailyTrendImplToJson(_$DailyTrendImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'total': instance.total,
    };

_$MonthOverMonthComparisonImpl _$$MonthOverMonthComparisonImplFromJson(
  Map<String, dynamic> json,
) => _$MonthOverMonthComparisonImpl(
  currentTotal: (json['currentTotal'] as num).toDouble(),
  previousTotal: (json['previousTotal'] as num).toDouble(),
  changePercent: (json['changePercent'] as num).toDouble(),
);

Map<String, dynamic> _$$MonthOverMonthComparisonImplToJson(
  _$MonthOverMonthComparisonImpl instance,
) => <String, dynamic>{
  'currentTotal': instance.currentTotal,
  'previousTotal': instance.previousTotal,
  'changePercent': instance.changePercent,
};
