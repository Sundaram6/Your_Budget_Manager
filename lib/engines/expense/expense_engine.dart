import 'package:uuid/uuid.dart';

import '../../core/enums.dart';
import '../../core/errors/app_exception.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/value_objects/amount.dart';

class ExpenseEngine {
  final TransactionRepository _repository;
  final Uuid _uuid;

  ExpenseEngine(this._repository, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Adds transaction with [amount] in integer paise.
  Future<Transaction> addTransaction({
    required int amount,
    required DateTime date,
    required String categoryId,
    required TransactionType type,
    String? note,
    String? sourceApp,
    PaymentMethod paymentMethod = PaymentMethod.unknown,
    String? cardLast4,
    bool isRecurring = false,
    String? recurringId,
    String? merchantName,
    String? merchantId,
    String? recurrenceOccurrenceKey,
    String? sourceMessageId,
    int? createdAt,
  }) async {
    if (amount <= 0) {
      throw const ValidationException('Amount must be greater than 0');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final transaction = Transaction(
      id: _uuid.v4(),
      amount: Amount(amount),
      date: date,
      categoryId: categoryId,
      type: type,
      note: note,
      sourceApp: sourceApp,
      paymentMethod: paymentMethod,
      cardLast4: cardLast4,
      isRecurring: isRecurring,
      recurringId: recurringId,
      merchantName: merchantName,
      merchantId: merchantId,
      recurrenceOccurrenceKey: recurrenceOccurrenceKey,
      sourceMessageId: sourceMessageId,
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
    await _repository.insertTransaction(transaction);
    return transaction;
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    if (transaction.amount.value <= 0) {
      throw const ValidationException('Amount must be greater than 0');
    }
    return await _repository.updateTransaction(transaction);
  }

  Future<int> deleteTransaction(Transaction transaction) async {
    return await _repository.deleteTransaction(transaction);
  }

  Future<Transaction?> getTransactionById(String id) async {
    final stream = _repository.watchAllTransactions();
    final all = await stream.first;
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  Stream<List<Transaction>> watchTransactionsByMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);
    return _repository.watchTransactionsByDateRange(start, end);
  }

  Future<List<Transaction>> getTransactionsByMonth(DateTime month) async {
    return await watchTransactionsByMonth(month).first;
  }

  /// Calculates monthly total in integer paise.
  Future<int> getMonthlyTotal(DateTime month, {TransactionType? type}) async {
    final transactions = await getTransactionsByMonth(month);
    int total = 0;
    for (final t in transactions) {
      if (type == null || t.type == type) {
        total += t.amount.value;
      }
    }
    return total;
  }
}
