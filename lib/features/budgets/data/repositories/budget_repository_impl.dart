import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/budget_dao.dart';
import '../../domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetDao _dao;

  BudgetRepositoryImpl(this._dao);

  @override
  Stream<List<db.Budget>> watchAllBudgets() {
    return _dao.watchAllBudgets();
  }

  @override
  Future<List<db.Budget>> getBudgetsForMonth(int month, int year) {
    return _dao.getBudgetsForMonth(month, year);
  }

  @override
  Future<db.Budget?> getOverallBudget(int month, int year) {
    return _dao.getOverallBudget(month, year);
  }

  @override
  Future<db.Budget?> getCategoryBudget(String categoryId, int month, int year) {
    return _dao.getCategoryBudget(categoryId, month, year);
  }

  @override
  Future<void> insertBudget(db.Budget budget) async {
    await _dao.insertBudget(budget);
  }

  @override
  Future<void> updateBudget(db.Budget budget) async {
    await _dao.updateBudget(budget);
  }

  @override
  Future<int> deleteBudget(db.Budget budget) {
    return _dao.deleteBudget(budget);
  }
}
