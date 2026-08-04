import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/models/recurring_transaction.dart';

void main() {
  group('RecurringTransactionModel', () {
    test('serializes to and from JSON with yyyy-MM-dd date formats', () {
      final now = DateTime.now();
      final startDate = DateTime(2026, 8, 1);
      final endDate = DateTime(2027, 8, 1);
      final nextDueDate = DateTime(2026, 9, 1);

      final model = RecurringTransactionModel(
        id: 'rec-123',
        title: 'Netflix Subscription',
        amountPaise: 64900,
        categoryId: 'cat_entertainment',
        type: 'expense',
        frequency: 'monthly',
        intervalDays: 30,
        startDate: startDate,
        endDate: endDate,
        nextDueDate: nextDueDate,
        lastGeneratedDate: null,
        isActive: true,
        autoConfirm: false,
        notes: 'Monthly HD plan',
        createdAt: now,
        updatedAt: now,
      );

      final json = model.toJson();

      expect(json['id'], equals('rec-123'));
      expect(json['title'], equals('Netflix Subscription'));
      expect(json['amount_paise'], equals(64900));
      expect(json['category_id'], equals('cat_entertainment'));
      expect(json['type'], equals('expense'));
      expect(json['frequency'], equals('monthly'));
      expect(json['interval_days'], equals(30));
      expect(json['start_date'], equals('2026-08-01'));
      expect(json['end_date'], equals('2027-08-01'));
      expect(json['next_due_date'], equals('2026-09-01'));
      expect(json['last_generated_date'], isNull);
      expect(json['is_active'], isTrue);
      expect(json['auto_confirm'], isFalse);
      expect(json['notes'], equals('Monthly HD plan'));

      final deserialized = RecurringTransactionModel.fromJson(json);
      expect(deserialized.id, equals(model.id));
      expect(deserialized.title, equals(model.title));
      expect(deserialized.amountPaise, equals(model.amountPaise));
      expect(deserialized.startDate.year, equals(2026));
      expect(deserialized.startDate.month, equals(8));
      expect(deserialized.startDate.day, equals(1));
    });
  });
}
