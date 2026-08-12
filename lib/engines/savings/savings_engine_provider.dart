import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/database_providers.dart';
import '../../database/app_database.dart';
import 'savings_engine.dart';

part 'savings_engine_provider.g.dart';

@riverpod
SavingsEngine savingsEngine(Ref ref) {
  final dao = ref.watch(savingsGoalDaoProvider);
  final repo = ref.watch(savingsGoalRepositoryProvider);
  return SavingsEngine(dao, repo);
}

@riverpod
SavingsEngine savingsGoalsEngine(Ref ref) {
  return ref.watch(savingsEngineProvider);
}

// Manual providers: riverpod_generator v4 cannot reference types from drift's
// generated part files (app_database.g.dart). StreamProvider.autoDispose is
// identical in behaviour to the @riverpod-generated equivalent.
final savingsGoalsStreamProvider =
    StreamProvider.autoDispose<List<SavingsGoal>>((ref) {
  return ref.watch(savingsEngineProvider).watchGoals();
});

final savingsGoalStreamProvider =
    StreamProvider.autoDispose.family<SavingsGoal?, String>((ref, id) {
  return ref.watch(savingsEngineProvider).watchGoal(id);
});
