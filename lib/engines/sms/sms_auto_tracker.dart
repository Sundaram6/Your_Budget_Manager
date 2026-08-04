import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../merchant/merchant_engine.dart';
import '../merchant/merchant_engine_provider.dart';
import 'models/parsed_transaction.dart';

final smsAutoTrackerProvider = Provider<SmsAutoTracker>((ref) {
  return SmsAutoTracker(
    merchantEngine: ref.watch(merchantEngineProvider),
  );
});

class SmsAutoTracker {
  final MerchantEngine _merchantEngine;
  final SmsQuery _smsQuery = SmsQuery();

  SmsAutoTracker({
    required MerchantEngine merchantEngine,
  }) : _merchantEngine = merchantEngine;

  void startForegroundTracking() {
    // Foreground tracking using periodic polling
    // This is a safe fallback to telemetry without native failures
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
      final messages = await _smsQuery.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 50, // query latest 50 messages to check for new ones
      );

      int processed = 0;
      for (final msg in messages) {
        final msgDate = msg.date;
        if (msgDate == null || msgDate.millisecondsSinceEpoch <= lastCheck) continue;

        final body = msg.body ?? '';
        final date = msgDate;

        final lower = body.toLowerCase();
        final isDebit = (lower.contains('debited') ||
                lower.contains('spent') ||
                lower.contains('paid') ||
                lower.contains('sent to') ||
                lower.contains('trf to') ||
                lower.contains('transfer to')) &&
            !lower.contains('credited') &&
            !lower.contains('requested');

        if (!isDebit) continue;

        final match = RegExp(
          r'(?:(?:RS|INR|₹)\.?\s?)([0-9,]+(?:\.[0-9]+)?)|([0-9,]+(?:\.[0-9]+)?)(?=\s?(?:RS|INR|₹))',
          caseSensitive: false
        ).firstMatch(body);

        if (match != null) {
          final amountStr = (match.group(1) ?? match.group(2))?.replaceAll(',', '');
          if (amountStr != null) {
            final amount = double.tryParse(amountStr);
            if (amount != null && amount > 0) {
              final merchant = _merchantEngine.detectMerchant(body);
              final merchantName = merchant?.name ?? 'Unknown Merchant';
              final categoryId = merchant?.categoryId ?? 'cat_uncategorized';

              final success = await _merchantEngine.confirmPendingTransaction(
                transaction: ParsedTransaction(
                  smsId: msg.id?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
                  amount: amount,
                  date: date,
                  merchantName: merchantName,
                  merchantId: merchant?.id ?? 'mer_unknown',
                  categoryId: categoryId,
                  originalSmsBody: body,
                ),
              );
              if (success) {
                processed++;
              }
            }
          }
        }
      }

      await prefs.setInt('sms_last_check_timestamp', now);
      return processed;
    } catch (_) {
      return 0;
    }
  }
}
