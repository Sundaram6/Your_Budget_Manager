import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/database_providers.dart';
import '../expense/expense_engine_provider.dart';
import 'recurring_engine.dart';

part 'recurring_engine_provider.g.dart';

@Riverpod(keepAlive: true)
RecurringEngine recurringEngine(RecurringEngineRef ref) {
  final repository = ref.watch(recurringRepositoryProvider);
  final expenseEngine = ref.watch(expenseEngineProvider);
  return RecurringEngine(repository, expenseEngine);
}
