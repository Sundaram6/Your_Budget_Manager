import '../../../../core/enums.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/budget_dao.dart';
import '../../../transactions/domain/value_objects/amount.dart';
import '../../domain/entities/budget.dart' as domain;
import '../../domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetDao _dao;

  BudgetRepositoryImpl(this._dao);

  domain.Budget _mapToDomain(db.Budget entity) {
    return domain.Budget(
      id: entity.id,
      categoryId: entity.categoryId,
      limit: Amount(entity.amount),
      periodType: BudgetPeriodType.values.firstWhere((e) => e.name == entity.periodType, orElse: () => BudgetPeriodType.monthly),
      startDate: DateTime.fromMillisecondsSinceEpoch(entity.createdAt),
      endDate: DateTime.fromMillisecondsSinceEpoch(entity.createdAt).add(const Duration(days: 30)),
    );
  }

  db.Budget _mapToDrift(domain.Budget entity) {
    return db.Budget(
      id: entity.id,
      categoryId: entity.categoryId,
      amount: entity.limit.value.toDouble(),
      periodType: entity.periodType.name,
      isActive: true,
      createdAt: entity.startDate.millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Stream<List<domain.Budget>> watchAllBudgets() {
    return _dao.watchAllBudgets().map((list) => list.map(_mapToDomain).toList());
  }

  @override
  Stream<List<domain.Budget>> watchActiveBudgets() {
    return _dao.watchActiveBudgets().map((list) => list.map(_mapToDomain).toList());
  }

  @override
  Future<int> insertBudget(domain.Budget budget) {
    return _dao.insertBudget(_mapToDrift(budget));
  }

  @override
  Future<bool> updateBudget(domain.Budget budget) {
    return _dao.updateBudget(_mapToDrift(budget));
  }

  @override
  Future<int> deleteBudget(domain.Budget budget) {
    return _dao.deleteBudget(_mapToDrift(budget));
  }
}
