import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../engines/savings/savings_engine_provider.dart';

part 'savings_controller.g.dart';

@riverpod
class SavingsController extends _$SavingsController {
  @override
  FutureOr<void> build() {}

  Future<void> createGoal({
    required String name,
    required double targetAmount,
    String? categoryId,
    DateTime? targetDate,
    String iconName = 'savings',
    String colorHex = '#FFD700',
    String? note,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(savingsEngineProvider).createGoal(
          name: name,
          targetAmount: targetAmount,
          categoryId: categoryId,
          targetDate: targetDate,
          iconName: iconName,
          colorHex: colorHex,
          note: note,
        ));
  }

  Future<void> addDeposit(String goalId, double amount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(savingsEngineProvider).deposit(goalId, amount));
  }
}
