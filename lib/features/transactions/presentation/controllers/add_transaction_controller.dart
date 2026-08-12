import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/enums.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../engines/category/category_engine.dart';
import '../../../../engines/expense/expense_engine_provider.dart';

part 'add_transaction_controller.freezed.dart';
part 'add_transaction_controller.g.dart';

@freezed
abstract class AddTransactionState with _$AddTransactionState {
  const factory AddTransactionState({
    @Default(0) int amount, // Integer paise
    @Default(TransactionType.expense) TransactionType type,
    String? selectedCategoryId,
    required DateTime date,
    @Default('') String note,
    @Default(PaymentMethod.cash) PaymentMethod paymentMethod,
    @Default(false) bool isSaving,
    String? error,
  }) = _AddTransactionState;
}

@riverpod
class AddTransactionController extends _$AddTransactionController {
  @override
  AddTransactionState build() {
    final now = DateTime.now();
    return AddTransactionState(
      date: now,
      selectedCategoryId: null,
    );
  }

  void setAmount(int amountPaise) => state = state.copyWith(amount: amountPaise, error: null);

  void setType(TransactionType type) {
    if (type == TransactionType.income && state.selectedCategoryId == null) {
      state = state.copyWith(type: type, selectedCategoryId: CategoryEngine.catIncome, error: null);
    } else {
      state = state.copyWith(type: type, error: null);
    }
  }

  void setCategory(String categoryId) => state = state.copyWith(selectedCategoryId: categoryId, error: null);
  void setDate(DateTime date) => state = state.copyWith(date: date, error: null);
  void setNote(String note) => state = state.copyWith(note: note, error: null);
  void setPaymentMethod(PaymentMethod method) => state = state.copyWith(paymentMethod: method, error: null);

  /// Checks if adding the specified expense amount will exceed the overall monthly budget.
  Future<({bool isExceeded, int projectedSpendPaise, int budgetAmountPaise, int remainingPaise})?> checkBudgetOverflow() async {
    if (state.type != TransactionType.expense || state.amount <= 0) return null;

    final now = state.date;
    final expenseEngine = ref.read(expenseEngineProvider);
    final budgetRepo = ref.read(budgetRepositoryProvider);

    final overallBudget = await budgetRepo.getOverallBudget(now.month, now.year);
    if (overallBudget == null || overallBudget.amount <= 0) return null;

    final spentPaise = await expenseEngine.getMonthlyTotal(now, type: TransactionType.expense);
    final thisExpensePaise = state.amount;

    final projectedSpendPaise = spentPaise + thisExpensePaise;

    if (projectedSpendPaise > overallBudget.amount) {
      final remainingPaise = max(0, overallBudget.amount - spentPaise);
      return (
        isExceeded: true,
        projectedSpendPaise: projectedSpendPaise,
        budgetAmountPaise: overallBudget.amount,
        remainingPaise: remainingPaise,
      );
    }

    return null;
  }

  Future<bool> saveTransaction() async {
    if (state.amount <= 0) {
      state = state.copyWith(error: 'Amount must be greater than 0');
      return false;
    }

    final categoryId = state.selectedCategoryId ??
        (state.type == TransactionType.income
            ? CategoryEngine.catIncome
            : CategoryEngine.catUncategorized);

    state = state.copyWith(isSaving: true, error: null);

    try {
      final expenseEngine = ref.read(expenseEngineProvider);
      await expenseEngine.addTransaction(
        amount: state.amount,
        date: state.date,
        categoryId: categoryId,
        type: state.type,
        note: state.note.isEmpty ? null : state.note,
        sourceApp: 'manual',
        paymentMethod: state.paymentMethod,
      );
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }
}
