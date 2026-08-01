import '../../core/enums.dart';
import '../../features/recurring/domain/entities/recurring_transaction.dart';
import '../../features/recurring/domain/repositories/recurring_repository.dart';
import '../expense/expense_engine.dart';

class RecurringEngine {
  final RecurringRepository _repository;
  final ExpenseEngine _expenseEngine;

  RecurringEngine(this._repository, this._expenseEngine);

  Future<int> addRecurring(RecurringTransaction transaction) {
    return _repository.insert(transaction);
  }

  Future<bool> updateRecurring(RecurringTransaction transaction) {
    return _repository.updateRecurringTransaction(transaction);
  }

  Future<int> deleteRecurring(RecurringTransaction transaction) {
    return _repository.deleteRecurringTransaction(transaction);
  }

  Stream<List<RecurringTransaction>> watchAll() {
    return _repository.watchAll();
  }

  Future<void> processDueTransactions() async {
    final now = DateTime.now();
    final dueTransactions = await _repository.getDueTransactions(now);
    
    for (var recurring in dueTransactions) {
      if (recurring.nextDate.isAfter(now)) continue;
      
      await _expenseEngine.addTransaction(
        amount: recurring.amount.value,
        date: recurring.nextDate,
        categoryId: recurring.categoryId,
        type: recurring.type,
        note: recurring.note,
      );

      DateTime nextDate = _calculateNextDate(recurring.nextDate, recurring.frequency);
      
      while (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
        nextDate = _calculateNextDate(nextDate, recurring.frequency);
      }

      final updatedRecurring = recurring.copyWith(nextDate: nextDate);
      await _repository.updateRecurringTransaction(updatedRecurring);
    }
  }

  DateTime _calculateNextDate(DateTime current, RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return current.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return current.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        return DateTime(current.year, current.month + 1, current.day, current.hour, current.minute, current.second);
      case RecurringFrequency.yearly:
        return DateTime(current.year + 1, current.month, current.day, current.hour, current.minute, current.second);
    }
  }
}
