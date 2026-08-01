import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/value_objects/amount.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
class Budget with _$Budget {
  const factory Budget({
    required String id,
    required String categoryId,
    @AmountConverter() required Amount limit,
    required BudgetPeriodType periodType,
    required DateTime startDate,
    required DateTime endDate,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) =>
      _$BudgetFromJson(json);
}
