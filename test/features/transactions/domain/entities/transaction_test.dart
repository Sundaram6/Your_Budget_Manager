import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';

void main() {
  group('Transaction Entity', () {
    final tDate = DateTime(2023, 1, 1);
    final tTransaction = Transaction(
      id: '1',
      amount: const Amount(100.0),
      date: tDate,
      categoryId: 'cat1',
      type: TransactionType.expense,
      note: 'Groceries',
    );

    test('should support value equality', () {
      final tTransaction2 = Transaction(
        id: '1',
        amount: const Amount(100.0),
        date: tDate,
        categoryId: 'cat1',
        type: TransactionType.expense,
        note: 'Groceries',
      );

      expect(tTransaction, equals(tTransaction2));
    });

    test('copyWith should work correctly', () {
      final updatedTransaction = tTransaction.copyWith(
        amount: const Amount(200.0),
      );

      expect(updatedTransaction.amount.value, 200.0);
      expect(updatedTransaction.id, tTransaction.id);
    });

    test('should correctly serialize and deserialize from JSON', () {
      final json = tTransaction.toJson();
      
      expect(json, {
        'id': '1',
        'amount': 100.0,
        'date': tDate.toIso8601String(),
        'categoryId': 'cat1',
        'type': 'expense',
        'note': 'Groceries',
      });

      final fromJson = Transaction.fromJson(json);
      expect(fromJson, equals(tTransaction));
    });
  });
}
