import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/enums.dart';
import 'package:your_budget_manager/features/transactions/domain/entities/transaction.dart';
import 'package:your_budget_manager/features/transactions/domain/value_objects/amount.dart';

void main() {
  group('Transaction Entity', () {
    final tDate = DateTime(2023, 1, 1);
    final tTransaction = Transaction(
      id: '1',
      amount: const Amount(10000),
      date: tDate,
      categoryId: 'cat1',
      type: TransactionType.expense,
      note: 'Groceries',
    );

    test('should support value equality', () {
      final tTransaction2 = Transaction(
        id: '1',
        amount: const Amount(10000),
        date: tDate,
        categoryId: 'cat1',
        type: TransactionType.expense,
        note: 'Groceries',
      );

      expect(tTransaction, equals(tTransaction2));
    });

    test('copyWith should work correctly', () {
      final updatedTransaction = tTransaction.copyWith(
        amount: const Amount(20000),
      );

      expect(updatedTransaction.amount.value, 20000);
      expect(updatedTransaction.id, tTransaction.id);
    });

    test('should correctly serialize and deserialize from JSON', () {
      final json = tTransaction.toJson();
      
      expect(json, {
        'id': '1',
        'amount': 10000,
        'date': tDate.toIso8601String(),
        'categoryId': 'cat1',
        'type': 'expense',
        'note': 'Groceries',
        'sourceApp': null,
        'paymentMethod': 'unknown',
        'cardLast4': null,
        'accountLast4': null,
        'transactionRef': null,
        'transferPairId': null,
        'isRecurring': false,
        'recurringId': null,
        'merchantName': null,
        'merchantId': null,
        'recurrenceOccurrenceKey': null,
        'sourceMessageId': null,
        'createdAt': null,
        'updatedAt': null,
      });

      final fromJson = Transaction.fromJson(json);
      expect(fromJson, equals(tTransaction));
    });

    test('should correctly serialize and deserialize with debit card, cardLast4, accountLast4, and transactionRef', () {
      final cardTx = Transaction(
        id: '2',
        amount: const Amount(25000),
        date: tDate,
        categoryId: 'cat_food',
        type: TransactionType.expense,
        note: 'Dinner',
        sourceApp: 'sms:hdfc',
        paymentMethod: PaymentMethod.debit_card,
        cardLast4: '4521',
        accountLast4: '1234',
        transactionRef: 'REF998877',
      );

      final json = cardTx.toJson();
      expect(json['paymentMethod'], 'debit_card');
      expect(json['cardLast4'], '4521');
      expect(json['accountLast4'], '1234');
      expect(json['transactionRef'], 'REF998877');

      final fromJson = Transaction.fromJson(json);
      expect(fromJson, equals(cardTx));
      expect(fromJson.paymentMethod, PaymentMethod.debit_card);
      expect(fromJson.cardLast4, '4521');
      expect(fromJson.accountLast4, '1234');
      expect(fromJson.transactionRef, 'REF998877');
    });
  });
}
