import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/database_providers.dart';
import '../expense/expense_engine_provider.dart';
import 'budget_engine.dart';
import 'models/daily_allowance.dart';

part 'budget_engine_provider.g.dart';

@Riverpod(keepAlive: true)
BudgetEngine budgetEngine(BudgetEngineRef ref) {
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final expenseEng = ref.watch(expenseEngineProvider);
  final recurringRepo = ref.watch(recurringRepositoryProvider);

  return BudgetEngine(budgetRepo, expenseEng, recurringRepo);
}

@Riverpod(keepAlive: true)
Future<DailyAllowance> dailyAllowance(DailyAllowanceRef ref) {
  final engine = ref.watch(budgetEngineProvider);
  return engine.calculateDailyAllowance();
}
