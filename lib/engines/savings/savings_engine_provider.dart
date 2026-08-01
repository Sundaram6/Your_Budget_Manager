import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/database_providers.dart';
import 'savings_engine.dart';
import 'models/savings_goal.dart';

part 'savings_engine_provider.g.dart';

@riverpod
SavingsEngine savingsEngine(SavingsEngineRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return SavingsEngine(db.savingsGoalDao);
}

@riverpod
Stream<List<SavingsGoalModel>> savingsGoalsStream(SavingsGoalsStreamRef ref) {
  return ref.watch(savingsEngineProvider).watchGoals();
}

@riverpod
Stream<SavingsGoalModel?> savingsGoalStream(SavingsGoalStreamRef ref, String id) {
  return ref.watch(savingsEngineProvider).watchGoal(id);
}
