import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/database_providers.dart';
import '../../database/app_database.dart';
import 'savings_engine.dart';

part 'savings_engine_provider.g.dart';

@riverpod
SavingsEngine savingsEngine(SavingsEngineRef ref) {
  final dao = ref.watch(savingsGoalDaoProvider);
  final repo = ref.watch(savingsGoalRepositoryProvider);
  return SavingsEngine(dao, repo);
}

@riverpod
SavingsEngine savingsGoalsEngine(SavingsGoalsEngineRef ref) {
  return ref.watch(savingsEngineProvider);
}

@riverpod
Stream<List<SavingsGoal>> savingsGoalsStream(SavingsGoalsStreamRef ref) {
  return ref.watch(savingsEngineProvider).watchGoals();
}

@riverpod
Stream<SavingsGoal?> savingsGoalStream(SavingsGoalStreamRef ref, String id) {
  return ref.watch(savingsEngineProvider).watchGoal(id);
}
