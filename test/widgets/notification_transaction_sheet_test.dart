import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/database_helper.dart';
import 'package:your_budget_manager/services/notification_reader_service.dart';
import 'package:your_budget_manager/services/notification_router.dart';
import 'package:your_budget_manager/widgets/notification_transaction_sheet.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    DatabaseHelper.instance.setDatabase(db);

    final now = DateTime.now().millisecondsSinceEpoch;
    // Seed fixed category IDs for FK constraints
    await db.customStatement("INSERT INTO categories (id, name, icon, color, created_at, updated_at) VALUES ('cat_transport', 'Transport', 'directions_car', '#FF0000', $now, $now)");
    await db.customStatement("INSERT INTO categories (id, name, icon, color, created_at, updated_at) VALUES ('cat_food', 'Food', 'fastfood', '#00FF00', $now, $now)");
    await db.customStatement("INSERT INTO categories (id, name, icon, color, created_at, updated_at) VALUES ('cat_misc', 'Misc', 'category', '#0000FF', $now, $now)");
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets('NotificationTransactionSheet renders notification details correctly', (tester) async {
    final data = PaymentNotificationData(
      packageName: 'com.phonepe.app',
      appName: 'PhonePe',
      title: 'Paid to Swiggy',
      body: 'Paid ₹350 to Swiggy',
      amount: 350.00,
      type: 'expense',
      merchant: 'Swiggy',
      reference: 'UTR12345678',
      timestamp: DateTime.now(),
    );

    await tester.pumpWidget(buildTestableWidget(NotificationTransactionSheet(data: data)));
    await tester.pumpAndSettle();

    expect(find.text('Payment Detected'), findsOneWidget);
    expect(find.text('₹350'), findsOneWidget);
    expect(find.text('PhonePe'), findsOneWidget);
    expect(find.text('Swiggy'), findsOneWidget);
    expect(find.text('UTR12345678'), findsOneWidget);
    expect(find.text('Ignore'), findsOneWidget);
    expect(find.text('Add to Budget'), findsOneWidget);
  });

  testWidgets('NotificationTransactionSheet clears pending on Ignore', (tester) async {
    final data = PaymentNotificationData(
      packageName: 'net.one97.paytm',
      appName: 'Paytm',
      title: 'Paid to Zomato',
      body: 'Paid ₹250',
      amount: 250.00,
      type: 'expense',
      merchant: 'Zomato',
      timestamp: DateTime.now(),
    );

    NotificationRouter.instance.onPaymentDetected(data);
    expect(NotificationRouter.instance.pendingNotification.value, equals(data));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => NotificationTransactionSheet(data: data),
              );
            },
            child: const Text('Open Sheet'),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ignore'));
    await tester.pumpAndSettle();

    expect(NotificationRouter.instance.pendingNotification.value, isNull);
  });

  testWidgets('NotificationTransactionSheet adds to budget on button tap', (tester) async {
    final data = PaymentNotificationData(
      packageName: 'com.google.android.apps.nfc.plugin.card.wallet',
      appName: 'Google Pay',
      title: 'Paid to Uber',
      body: 'Paid ₹180 to Uber',
      amount: 180.00,
      type: 'expense',
      merchant: 'Uber',
      reference: 'TXN998877',
      timestamp: DateTime.now(),
    );

    NotificationRouter.instance.onPaymentDetected(data);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (ctx) => NotificationTransactionSheet(data: data),
              );
            },
            child: const Text('Open Sheet'),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add to Budget'));
    await tester.pumpAndSettle();

    expect(NotificationRouter.instance.pendingNotification.value, isNull);
    expect(find.text('Transaction saved'), findsOneWidget);
  });
}
