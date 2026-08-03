import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/database_providers.dart';
import '../budget/budget_engine_provider.dart';
import '../expense/expense_engine_provider.dart';
import '../savings/savings_engine_provider.dart';
import 'intelligence_engine.dart';

part 'intelligence_engine_provider.g.dart';

@riverpod
IntelligenceEngine intelligenceEngine(IntelligenceEngineRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final budgetEngine = ref.watch(budgetEngineProvider);
  final savingsEngine = ref.watch(savingsEngineProvider);
  final expenseEngine = ref.watch(expenseEngineProvider);

  return IntelligenceEngine(
    budgetEngine: budgetEngine,
    savingsEngine: savingsEngine,
    expenseEngine: expenseEngine,
    transactionDao: db.transactionDao,
    categoryDao: db.categoryDao,
  );
}
