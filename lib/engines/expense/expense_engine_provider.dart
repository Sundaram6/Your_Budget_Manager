import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/database_providers.dart';
import 'expense_engine.dart';

part 'expense_engine_provider.g.dart';

@Riverpod(keepAlive: true)
ExpenseEngine expenseEngine(ExpenseEngineRef ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return ExpenseEngine(repository);
}
