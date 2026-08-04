import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'notification_router.dart';

class PaymentNotificationData {
  final String packageName;
  final String appName;
  final String title;
  final String body;
  final double amount;
  final String type; // 'expense' or 'income'
  final String? merchant;
  final String? reference;
  final DateTime timestamp;

  const PaymentNotificationData({
    required this.packageName,
    required this.appName,
    required this.title,
    required this.body,
    required this.amount,
    required this.type,
    this.merchant,
    this.reference,
    required this.timestamp,
  });

  factory PaymentNotificationData.fromMap(Map<dynamic, dynamic> map) {
    final amountPaise = map['amountPaise'] as num?;
    final amountDouble = map['amount'] as num?;
    final calcAmount = amountPaise != null
        ? (amountPaise.toDouble() / 100.0)
        : (amountDouble?.toDouble() ?? 0.0);

    final ts = map['timestamp'] as num?;
    final date = ts != null
        ? DateTime.fromMillisecondsSinceEpoch(ts.toInt())
        : DateTime.now();

    return PaymentNotificationData(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? map['text'] as String? ?? '',
      amount: calcAmount,
      type: map['type'] as String? ?? 'expense',
      merchant: map['merchant'] as String?,
      reference: map['reference'] as String? ?? map['utr'] as String?,
      timestamp: date,
    );
  }
}

class NotificationReaderService {
  static final NotificationReaderService instance = NotificationReaderService._();

  NotificationReaderService._();

  static const MethodChannel _channel =
      MethodChannel('com.ybm.your_budget_manager/notification_listener');

  final ValueNotifier<PaymentNotificationData?> latestNotification =
      ValueNotifier<PaymentNotificationData?>(null);

  void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onNotificationReceived' || call.method == 'onPaymentNotification') {
      final args = call.arguments;
      if (args is Map) {
        final data = PaymentNotificationData.fromMap(args);
        latestNotification.value = data;
        NotificationRouter.instance.onPaymentDetected(data);
      }
    }
    return null;
  }

  Future<bool> isPermissionGranted() async {
    try {
      final result = await _channel.invokeMethod<bool>('isNotificationAccessGranted');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> openNotificationSettings() async {
    try {
      final result = await _channel.invokeMethod<bool>('openNotificationSettings');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
