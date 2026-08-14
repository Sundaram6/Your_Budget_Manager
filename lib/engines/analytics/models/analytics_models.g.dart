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

_RecurringCommitmentSummary _$RecurringCommitmentSummaryFromJson(
  Map<String, dynamic> json,
) => _RecurringCommitmentSummary(
  totalMonthlyRecurringPaise: (json['totalMonthlyRecurringPaise'] as num)
      .toInt(),
  upcomingRecurringThisMonthPaise:
      (json['upcomingRecurringThisMonthPaise'] as num).toInt(),
  recurringCount: (json['recurringCount'] as num).toInt(),
  recurringExpenseRatio: (json['recurringExpenseRatio'] as num).toDouble(),
);

Map<String, dynamic> _$RecurringCommitmentSummaryToJson(
  _RecurringCommitmentSummary instance,
) => <String, dynamic>{
  'totalMonthlyRecurringPaise': instance.totalMonthlyRecurringPaise,
  'upcomingRecurringThisMonthPaise': instance.upcomingRecurringThisMonthPaise,
  'recurringCount': instance.recurringCount,
  'recurringExpenseRatio': instance.recurringExpenseRatio,
};

_SavingsAnalyticsSummary _$SavingsAnalyticsSummaryFromJson(
  Map<String, dynamic> json,
) => _SavingsAnalyticsSummary(
  totalGoalsCount: (json['totalGoalsCount'] as num).toInt(),
  activeGoalsCount: (json['activeGoalsCount'] as num).toInt(),
  totalSavedPaise: (json['totalSavedPaise'] as num).toInt(),
  totalTargetPaise: (json['totalTargetPaise'] as num).toInt(),
  monthlyCommittedAutoSavePaise: (json['monthlyCommittedAutoSavePaise'] as num)
      .toInt(),
  overallProgressPercent: (json['overallProgressPercent'] as num).toDouble(),
);

Map<String, dynamic> _$SavingsAnalyticsSummaryToJson(
  _SavingsAnalyticsSummary instance,
) => <String, dynamic>{
  'totalGoalsCount': instance.totalGoalsCount,
  'activeGoalsCount': instance.activeGoalsCount,
  'totalSavedPaise': instance.totalSavedPaise,
  'totalTargetPaise': instance.totalTargetPaise,
  'monthlyCommittedAutoSavePaise': instance.monthlyCommittedAutoSavePaise,
  'overallProgressPercent': instance.overallProgressPercent,
};
