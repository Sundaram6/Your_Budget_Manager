import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/database_providers.dart';
import '../transfer/self_transfer_engine_provider.dart';
import 'expense_engine.dart';

part 'expense_engine_provider.g.dart';

@Riverpod(keepAlive: true)
ExpenseEngine expenseEngine(Ref ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final selfTransferEngine = ref.watch(selfTransferEngineProvider);
  return ExpenseEngine(repository, selfTransferEngine: selfTransferEngine);
}
