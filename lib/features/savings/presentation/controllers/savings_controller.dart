import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../engines/savings/savings_engine_provider.dart';

part 'savings_controller.g.dart';

@riverpod
class SavingsController extends _$SavingsController {
  @override
  FutureOr<void> build() {}

  Future<void> createGoal({
    required String name,
    required int targetAmountPaise,
    DateTime? deadline,
    String? linkedBudgetId,
    bool autoDeduct = false,
    int? autoDeductAmountPaise,
    String? categoryId,
    String iconName = 'savings',
    String colorHex = '#FFD700',
    String? note,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(savingsEngineProvider).createGoal(
          name: name,
          targetAmountPaise: targetAmountPaise,
          deadline: deadline,
          linkedBudgetId: linkedBudgetId,
          autoDeduct: autoDeduct,
          autoDeductAmountPaise: autoDeductAmountPaise,
          categoryId: categoryId,
          iconName: iconName,
          colorHex: colorHex,
          note: note,
        ));
  }

  Future<void> addDeposit(String goalId, int amountPaise) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(savingsEngineProvider).contributeToGoal(goalId, amountPaise));
  }
}
