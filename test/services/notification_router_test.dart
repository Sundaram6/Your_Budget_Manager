import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/services/notification_reader_service.dart';
import 'package:your_budget_manager/services/notification_router.dart';

void main() {
  group('NotificationReaderService & NotificationRouter Tests', () {
    test('PaymentNotificationData parses map cleanly', () {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final data = PaymentNotificationData.fromMap({
        'packageName': 'com.google.android.apps.nfc.plugin.card.wallet',
        'appName': 'Google Pay',
        'title': 'Paid to Zomato',
        'text': 'Paid ₹350.50 to Zomato via GPay. Ref: 123456789012',
        'amountPaise': 35050,
        'type': 'expense',
        'merchant': 'Zomato',
        'utr': '123456789012',
        'timestamp': nowMs,
      });

      expect(data.packageName, equals('com.google.android.apps.nfc.plugin.card.wallet'));
      expect(data.appName, equals('Google Pay'));
      expect(data.amount, equals(350.50));
      expect(data.merchant, equals('Zomato'));
      expect(data.reference, equals('123456789012'));
      expect(data.type, equals('expense'));
    });

    test('NotificationRouter toTransaction auto-categorizes food correctly', () async {
      final data = PaymentNotificationData(
        packageName: 'com.phonepe.app',
        appName: 'PhonePe',
        title: 'Paid to Swiggy',
        body: 'Paid ₹249 to Swiggy',
        amount: 249.00,
        type: 'expense',
        merchant: 'Swiggy',
        reference: 'UTR99887766',
        timestamp: DateTime.now(),
      );

      final tx = await NotificationRouter.instance.toTransaction(data);

      expect(tx.title, equals('Swiggy (PhonePe)'));
      expect(tx.amountPaise, equals(24900));
      expect(tx.categoryId, equals('cat_food'));
      expect(tx.type, equals('expense'));
      expect(tx.isAutoCaptured, isTrue);
      expect(tx.sourceApp, equals('com.phonepe.app'));
      expect(tx.notes, contains('Ref: UTR99887766'));
    });

    test('NotificationRouter toTransaction auto-categorizes shopping and transport', () async {
      final amazonData = PaymentNotificationData(
        packageName: 'com.amazon.mShop.android.shopping',
        appName: 'Amazon Pay',
        title: 'Paid to Amazon',
        body: 'Paid ₹1299 for shopping',
        amount: 1299.00,
        type: 'expense',
        merchant: 'Amazon',
        timestamp: DateTime.now(),
      );
      final amazonTx = await NotificationRouter.instance.toTransaction(amazonData);
      expect(amazonTx.categoryId, equals('cat_shopping'));

      final uberData = PaymentNotificationData(
        packageName: 'com.phonepe.app',
        appName: 'PhonePe',
        title: 'Paid to Uber',
        body: 'Paid ₹450 for ride',
        amount: 450.00,
        type: 'expense',
        merchant: 'Uber',
        timestamp: DateTime.now(),
      );
      final uberTx = await NotificationRouter.instance.toTransaction(uberData);
      expect(uberTx.categoryId, equals('cat_transport'));
    });

    test('NotificationRouter manage in-memory pending notifications', () {
      final data = PaymentNotificationData(
        packageName: 'net.one97.paytm',
        appName: 'Paytm',
        title: 'Received money',
        body: 'Received ₹500 from Alex',
        amount: 500.00,
        type: 'income',
        merchant: 'Alex',
        timestamp: DateTime.now(),
      );

      NotificationRouter.instance.onPaymentDetected(data);
      expect(NotificationRouter.instance.pendingNotification.value, equals(data));

      NotificationRouter.instance.clearPending();
      expect(NotificationRouter.instance.pendingNotification.value, isNull);
    });
  });
}
