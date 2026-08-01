import '../entities/transaction.dart';

abstract class TransactionRepository {
  Stream<List<Transaction>> watchAllTransactions();
  Stream<List<Transaction>> watchTransactionsByDateRange(DateTime start, DateTime end);
  Stream<List<Transaction>> watchTransactionsByCategory(String categoryId);
  Future<int> insertTransaction(Transaction transaction);
  Future<bool> updateTransaction(Transaction transaction);
  Future<int> deleteTransaction(Transaction transaction);
}
