import '../../../../core/enums.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/transaction_dao.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/value_objects/amount.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDao _dao;

  TransactionRepositoryImpl(this._dao);

  domain.Transaction _mapToDomain(db.Transaction entity) {
    return domain.Transaction(
      id: entity.id,
      amount: Amount(entity.amount),
      date: DateTime.fromMillisecondsSinceEpoch(entity.date),
      categoryId: entity.categoryId,
      type: TransactionType.values.firstWhere((e) => e.name == entity.type),
      note: entity.note,
      sourceApp: entity.sourceApp,
      paymentMethod: PaymentMethod.fromString(entity.paymentMethod),
      cardLast4: entity.cardLast4,
    );
  }

  db.Transaction _mapToDrift(domain.Transaction entity) {
    return db.Transaction(
      id: entity.id,
      amount: entity.amount.value,
      type: entity.type.name,
      categoryId: entity.categoryId,
      date: entity.date.millisecondsSinceEpoch,
      note: entity.note,
      sourceApp: entity.sourceApp,
      paymentMethod: entity.paymentMethod.name,
      cardLast4: entity.cardLast4,
      isRecurring: false,
      isAutoCaptured: entity.sourceApp != null && entity.sourceApp != 'manual',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Stream<List<domain.Transaction>> watchAllTransactions() {
    return _dao.watchAllTransactions().map((list) => list.map(_mapToDomain).toList());
  }

  @override
  Stream<List<domain.Transaction>> watchTransactionsByDateRange(DateTime start, DateTime end) {
    return _dao.watchTransactionsByDateRange(start, end).map((list) => list.map(_mapToDomain).toList());
  }

  @override
  Stream<List<domain.Transaction>> watchTransactionsByCategory(String categoryId) {
    return _dao.watchTransactionsByCategory(categoryId).map((list) => list.map(_mapToDomain).toList());
  }

  @override
  Future<int> insertTransaction(domain.Transaction transaction) {
    return _dao.insertTransaction(_mapToDrift(transaction));
  }

  @override
  Future<bool> updateTransaction(domain.Transaction transaction) {
    return _dao.updateTransaction(_mapToDrift(transaction));
  }

  @override
  Future<int> deleteTransaction(domain.Transaction transaction) {
    return _dao.deleteTransaction(_mapToDrift(transaction));
  }
}
