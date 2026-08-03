import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../database/app_database.dart';

part 'budget_controller.g.dart';

@riverpod
class BudgetController extends _$BudgetController {
  @override
  FutureOr<List<Budget>> build() async {
    final now = DateTime.now();
    return ref.watch(budgetRepositoryProvider).getBudgetsForMonth(now.month, now.year);
  }
}
