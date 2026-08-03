import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../engines/savings/savings_engine_provider.dart';

part 'savings_controller.g.dart';

@riverpod
class SavingsController extends _$SavingsController {
  @override
  FutureOr<void> build() {}

  Future<void> createGoal({
    required String name,
    required double targetAmountRupees,
    DateTime? deadline,
    String? linkedBudgetId,
    bool autoDeduct = false,
    double? autoDeductAmountRupees,
    String? categoryId,
    String iconName = 'savings',
    String colorHex = '#FFD700',
    String? note,
  }) async {
    state = const AsyncValue.loading();
    final targetPaise = (targetAmountRupees * 100).round();
    final autoDeductPaise = autoDeductAmountRupees != null ? (autoDeductAmountRupees * 100).round() : null;

    state = await AsyncValue.guard(() => ref.read(savingsEngineProvider).createGoal(
          name: name,
          targetAmountPaise: targetPaise,
          deadline: deadline,
          linkedBudgetId: linkedBudgetId,
          autoDeduct: autoDeduct,
          autoDeductAmountPaise: autoDeductPaise,
          categoryId: categoryId,
          iconName: iconName,
          colorHex: colorHex,
          note: note,
        ));
  }

  Future<void> addDeposit(String goalId, double amountRupees) async {
    state = const AsyncValue.loading();
    final amountPaise = (amountRupees * 100).round();
    state = await AsyncValue.guard(() => ref.read(savingsEngineProvider).contributeToGoal(goalId, amountPaise));
  }
}
