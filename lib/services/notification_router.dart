import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction.dart';
import 'notification_reader_service.dart';

class NotificationRouter {
  static final NotificationRouter instance = NotificationRouter._();

  NotificationRouter._();

  final ValueNotifier<PaymentNotificationData?> pendingNotification =
      ValueNotifier<PaymentNotificationData?>(null);

  void onPaymentDetected(PaymentNotificationData data) {
    pendingNotification.value = data;
  }

  void clearPending() {
    pendingNotification.value = null;
  }

  Future<TransactionModel> toTransaction(PaymentNotificationData data) async {
    final amountPaise = (data.amount * 100).round();
    final categoryId = _categorize(data.merchant, data.title, data.body, data.type);
    final uuid = const Uuid().v4();

    final title = data.merchant != null && data.merchant!.isNotEmpty
        ? '${data.merchant} (${data.appName})'
        : '${data.appName} Payment';

    final notes = data.reference != null && data.reference!.isNotEmpty
        ? 'Auto-captured from ${data.appName}. Ref: ${data.reference}'
        : 'Auto-captured from ${data.appName}';

    return TransactionModel(
      id: 'tx_$uuid',
      title: title,
      amountPaise: amountPaise,
      categoryId: categoryId,
      type: data.type,
      date: data.timestamp,
      notes: notes,
      isAutoCaptured: true,
      sourceApp: data.packageName,
      createdAt: DateTime.now(),
    );
  }

  String _categorize(String? merchant, String title, String body, String type) {
    final combined = '${merchant ?? ''} $title $body'.toLowerCase();

    if (combined.contains('zomato') ||
        combined.contains('swiggy') ||
        combined.contains('blinkit') ||
        combined.contains('zepto') ||
        combined.contains('eats') ||
        combined.contains('food')) {
      return 'cat_food';
    }

    if (combined.contains('amazon') ||
        combined.contains('flipkart') ||
        combined.contains('myntra') ||
        combined.contains('meesho') ||
        combined.contains('ajio') ||
        combined.contains('shopping')) {
      return 'cat_shopping';
    }

    if (combined.contains('uber') ||
        combined.contains('ola') ||
        combined.contains('rapido') ||
        combined.contains('irctc') ||
        combined.contains('namma') ||
        combined.contains('metro') ||
        combined.contains('cab') ||
        combined.contains('ride')) {
      return 'cat_transport';
    }

    if (combined.contains('electricity') ||
        combined.contains('water') ||
        combined.contains('bescom') ||
        combined.contains('gas') ||
        combined.contains('recharge') ||
        combined.contains('airtel') ||
        combined.contains('jio') ||
        combined.contains('vi ') ||
        combined.contains('bill')) {
      return 'cat_utilities';
    }

    if (combined.contains('netflix') ||
        combined.contains('spotify') ||
        combined.contains('prime') ||
        combined.contains('hotstar') ||
        combined.contains('cinema') ||
        combined.contains('movie') ||
        combined.contains('pvr') ||
        combined.contains('bookmyshow')) {
      return 'cat_entertainment';
    }

    if (type.toLowerCase() == 'income') {
      return 'cat_income';
    }

    return 'cat_misc';
  }
}
