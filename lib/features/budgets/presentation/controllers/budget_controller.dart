import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../engines/budget/budget_engine_provider.dart';
import '../../domain/entities/budget.dart';

part 'budget_controller.g.dart';

@riverpod
class BudgetController extends _$BudgetController {
  @override
  FutureOr<List<Budget>> build() async {
    return ref.watch(budgetEngineProvider).watchActiveBudgets().first;
  }
}
