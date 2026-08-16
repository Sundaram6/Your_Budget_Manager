import 'package:uuid/uuid.dart';

import '../../core/enums.dart';
import '../../core/errors/app_exception.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/value_objects/amount.dart';
import '../transfer/self_transfer_engine.dart';

class ExpenseEngine {
  final TransactionRepository _repository;
  final SelfTransferEngine? _selfTransferEngine;
  final Uuid _uuid;

  ExpenseEngine(
    this._repository, {
    SelfTransferEngine? selfTransferEngine,
    Uuid? uuid,
  })  : _selfTransferEngine = selfTransferEngine,
        _uuid = uuid ?? const Uuid();

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
    String? accountLast4,
    String? transactionRef,
    String? transferPairId,
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
      accountLast4: accountLast4,
      transactionRef: transactionRef,
      transferPairId: transferPairId,
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

    // Post-processing pass: scan for self-transfer match
    if (_selfTransferEngine != null && !transaction.isSelfTransfer) {
      final match = await _selfTransferEngine!.scanAndProcess(transaction);
      if (match != null && match.isAutoLinked && match.transferPairId != null) {
        return transaction.copyWith(transferPairId: match.transferPairId);
      }
    }

    return transaction;
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    if (transaction.amount.value <= 0) {
      throw const ValidationException('Amount must be greater than 0');
    }

    // Unlink transfer pair if amount or type is modified
    if (transaction.isSelfTransfer && _selfTransferEngine != null) {
      final existing = await getTransactionById(transaction.id);
      if (existing != null && (existing.amount.value != transaction.amount.value || existing.type != transaction.type)) {
        await _selfTransferEngine!.unlinkPair(existing.transferPairId!);
        return await _repository.updateTransaction(transaction.copyWith(transferPairId: null));
      }
    }

    return await _repository.updateTransaction(transaction);
  }

  Future<int> deleteTransaction(Transaction transaction) async {
    // If deleting one side of a linked pair, unlink the remaining counterpart first
    if (transaction.isSelfTransfer && _selfTransferEngine != null && transaction.transferPairId != null) {
      await _selfTransferEngine!.unlinkPair(transaction.transferPairId!);
    }
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

  /// Calculates monthly total in integer paise, strictly excluding self-transfers.
  Future<int> getMonthlyTotal(DateTime month, {TransactionType? type}) async {
    final transactions = await getTransactionsByMonth(month);
    int total = 0;
    for (final t in transactions) {
      if (t.isSelfTransfer) continue;
      if (type == null || t.type == type) {
        total += t.amount.value;
      }
    }
    return total;
  }
}
