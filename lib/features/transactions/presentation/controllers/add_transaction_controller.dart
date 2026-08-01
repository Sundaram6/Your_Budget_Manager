import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/enums.dart';
import '../../../../engines/expense/expense_engine_provider.dart';

part 'add_transaction_controller.freezed.dart';
part 'add_transaction_controller.g.dart';

@freezed
class AddTransactionState with _$AddTransactionState {
  const factory AddTransactionState({
    @Default(0.0) double amount,
    @Default(TransactionType.expense) TransactionType type,
    String? selectedCategoryId,
    required DateTime date,
    @Default('') String note,
    @Default(false) bool isSaving,
    String? error,
  }) = _AddTransactionState;
}

@riverpod
class AddTransactionController extends _$AddTransactionController {
  @override
  AddTransactionState build() {
    return AddTransactionState(date: DateTime.now());
  }

  void setAmount(double amount) => state = state.copyWith(amount: amount);
  void setType(TransactionType type) => state = state.copyWith(type: type);
  void setCategory(String categoryId) => state = state.copyWith(selectedCategoryId: categoryId);
  void setDate(DateTime date) => state = state.copyWith(date: date);
  void setNote(String note) => state = state.copyWith(note: note);

  Future<bool> saveTransaction() async {
    if (state.amount <= 0) {
      state = state.copyWith(error: 'Amount must be greater than 0');
      return false;
    }
    if (state.selectedCategoryId == null) {
      state = state.copyWith(error: 'Please select a category');
      return false;
    }

    state = state.copyWith(isSaving: true, error: null);

    try {
      final expenseEngine = ref.read(expenseEngineProvider);
      await expenseEngine.addTransaction(
        amount: state.amount,
        date: state.date,
        categoryId: state.selectedCategoryId!,
        type: state.type,
        note: state.note.isEmpty ? null : state.note,
      );
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}
