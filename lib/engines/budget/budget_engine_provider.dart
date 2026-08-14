import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/database_providers.dart';
import '../expense/expense_engine_provider.dart';
import '../savings/savings_engine_provider.dart';
import 'budget_engine.dart';
import 'models/daily_allowance.dart';

part 'budget_engine_provider.g.dart';

@Riverpod(keepAlive: true)
BudgetEngine budgetEngine(Ref ref) {
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final expenseEng = ref.watch(expenseEngineProvider);
  final recurringRepo = ref.watch(recurringRepositoryProvider);
  final savingsEng = ref.watch(savingsEngineProvider);

  return BudgetEngine(
    budgetRepo,
    expenseEng,
    recurringRepository: recurringRepo,
    savingsEngine: savingsEng,
  );
}

@Riverpod(keepAlive: true)
Future<DailyAllowance?> dailyAllowance(Ref ref) {
  final engine = ref.watch(budgetEngineProvider);
  return engine.calculateDailyAllowance();
}
