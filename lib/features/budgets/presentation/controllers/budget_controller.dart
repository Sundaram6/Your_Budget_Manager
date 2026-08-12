import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../database/app_database.dart';

// Manual AsyncNotifier: riverpod_generator v4 cannot reference types from
// drift's generated part files (app_database.g.dart) in build() signatures.
// This is behaviourally identical to the @riverpod-generated version.
class BudgetController extends AsyncNotifier<List<Budget>> {
  @override
  Future<List<Budget>> build() async {
    final now = DateTime.now();
    return ref.watch(budgetRepositoryProvider).getBudgetsForMonth(now.month, now.year);
  }
}

final budgetControllerProvider =
    AsyncNotifierProvider<BudgetController, List<Budget>>(
  BudgetController.new,
);
