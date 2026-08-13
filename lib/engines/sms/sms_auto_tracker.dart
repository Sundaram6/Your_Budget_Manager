import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/database_helper.dart';
import '../merchant/merchant_engine.dart';
import '../merchant/merchant_engine_provider.dart';

final smsAutoTrackerProvider = Provider<SmsAutoTracker>((ref) {
  return SmsAutoTracker(
    merchantEngine: ref.watch(merchantEngineProvider),
  );
});

class SmsAutoTracker {
  final MerchantEngine _merchantEngine;
  final SmsQuery _smsQuery;

  SmsAutoTracker({
    required MerchantEngine merchantEngine,
    SmsQuery? smsQuery,
  })  : _merchantEngine = merchantEngine,
        _smsQuery = smsQuery ?? SmsQuery();

  void startForegroundTracking() {
    // Polling background check on startup / resume
  }

  void stopForegroundTracking() {
    // No-op
  }

  Future<int> processBackgroundQueue() async {
    final status = await Permission.sms.status;
    if (!status.isGranted) return 0;

    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt('sms_last_check_timestamp') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      // Query without artificial 50-message cap to prevent skipping unread messages
      final messages = await _smsQuery.querySms(
        kinds: [SmsQueryKind.inbox],
      );

      int processed = 0;
      int maxProcessedTimestamp = lastCheck;

      for (final msg in messages) {
        final msgDate = msg.date;
        if (msgDate == null || msgDate.millisecondsSinceEpoch <= lastCheck) continue;

        maxProcessedTimestamp = max(maxProcessedTimestamp, msgDate.millisecondsSinceEpoch);

        final parsed = _merchantEngine.parseSingleSms(msg);
        if (parsed == null) continue;

        final isDuplicate = await DatabaseHelper.instance.checkDuplicateTransaction(
          amountValue: parsed.amount,
          date: parsed.date,
          snippet: parsed.merchantName,
          sourceMessageId: parsed.smsId,
        );
        if (isDuplicate) continue;

        final success = await _merchantEngine.confirmPendingTransaction(
          transaction: parsed,
        );
        if (success) {
          processed++;
        }
      }

      await prefs.setInt('sms_last_check_timestamp', max(maxProcessedTimestamp, now));
      return processed;
    } catch (_) {
      return 0;
    }
  }
}
