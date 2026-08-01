import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/engines/notification/notification_engine.dart';

void main() {
  late NotificationEngine notificationEngine;

  setUp(() {
    notificationEngine = NotificationEngine();
  });

  group('NotificationEngine (Phase 1 Stub)', () {
    test('checkBudgetAlerts returns an empty list', () async {
      final alerts = await notificationEngine.checkBudgetAlerts();
      expect(alerts, isEmpty);
    });

    test('checkRecurringReminders returns an empty list', () async {
      final reminders = await notificationEngine.checkRecurringReminders();
      expect(reminders, isEmpty);
    });
  });
}
