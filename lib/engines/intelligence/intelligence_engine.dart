import '../../database/app_database.dart';
import '../../database/daos/category_dao.dart';
import '../../database/daos/transaction_dao.dart';
import 'models/insight.dart';

class IntelligenceEngine {
  IntelligenceEngine({
    required this.transactionDao,
    required this.categoryDao,
  });

  final TransactionDao transactionDao;
  final CategoryDao categoryDao;

  /// Generates insights for the current month vs previous month.
  Future<List<Insight>> generateMonthlyInsights() async {
    final insights = <Insight>[];
    
    final now = DateTime.now();
    final startOfThisMonth = DateTime(now.year, now.month, 1);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    
    // 1. Get transactions
    final thisMonthTx = await transactionDao.getTransactionsByDateRange(
        startOfThisMonth, now);
    final lastMonthTx = await transactionDao.getTransactionsByDateRange(
        startOfLastMonth, startOfThisMonth.subtract(const Duration(milliseconds: 1)));

    // 2. Calculate totals
    final thisMonthSpend = _calculateTotal(thisMonthTx, 'expense');
    final lastMonthSpend = _calculateTotal(lastMonthTx, 'expense');

    if (thisMonthSpend > 0 && lastMonthSpend > 0) {
      if (thisMonthSpend > lastMonthSpend) {
        final diff = thisMonthSpend - lastMonthSpend;
        final percent = (diff / lastMonthSpend) * 100;
        insights.add(Insight(
          id: 'spend_increase',
          title: 'Spending Increased',
          description: 'You spent ${percent.toStringAsFixed(1)}% more this month compared to last month.',
          type: InsightType.warning,
          actionLabel: 'View Budgets',
          actionRoute: '/budgets',
        ));
      } else {
        final diff = lastMonthSpend - thisMonthSpend;
        final percent = (diff / lastMonthSpend) * 100;
        insights.add(Insight(
          id: 'spend_decrease',
          title: 'Great Job Saving!',
          description: 'You spent ${percent.toStringAsFixed(1)}% less this month compared to last month.',
          type: InsightType.positive,
        ));
      }
    }

    // 3. Find top category
    if (thisMonthTx.isNotEmpty) {
      final categoryTotals = <String, double>{};
      for (final tx in thisMonthTx) {
        if (tx.type == 'expense') {
          categoryTotals[tx.categoryId] = (categoryTotals[tx.categoryId] ?? 0) + tx.amount;
        }
      }

      if (categoryTotals.isNotEmpty) {
        final topEntry = categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
        final category = await categoryDao.getCategoryById(topEntry.key);
        if (category != null) {
          insights.add(Insight(
            id: 'top_category',
            title: 'Top Spending Category',
            description: 'You spent the most on ${category.name} this month.',
            type: InsightType.info,
          ));
        }
      }
    }

    if (insights.isEmpty) {
      insights.add(const Insight(
        id: 'no_data',
        title: 'Not enough data',
        description: 'Keep logging transactions to see insights.',
        type: InsightType.info,
      ));
    }

    return insights;
  }

  double _calculateTotal(List<Transaction> transactions, String type) {
    return transactions
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
