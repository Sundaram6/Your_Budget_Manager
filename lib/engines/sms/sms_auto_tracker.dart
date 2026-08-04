import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

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
  final Telephony _telephony = Telephony.instance;

  SmsAutoTracker({
    required MerchantEngine merchantEngine,
  }) : _merchantEngine = merchantEngine;

  void startForegroundTracking() {
    _telephony.listenIncomingSms(
      onNewMessage: _onNewMessage,
      onBackgroundMessage: _backgroundMessageHandler,
      listenInBackground: true,
    );
  }

  void stopForegroundTracking() {
    _telephony.listenIncomingSms(
      onNewMessage: (_) {},
      listenInBackground: false,
    );
  }

  void _onNewMessage(SmsMessage message) {
    _processMessage(message);
  }

  Future<void> _processMessage(SmsMessage message) async {
    if (message.body == null) return;
    
    final body = message.body!;
    final date = message.date != null ? DateTime.fromMillisecondsSinceEpoch(message.date!) : DateTime.now();

    final lower = body.toLowerCase();
    final isDebit = (lower.contains('debited') ||
            lower.contains('spent') ||
            lower.contains('paid') ||
            lower.contains('sent to') ||
            lower.contains('trf to') ||
            lower.contains('transfer to')) &&
        !lower.contains('credited') &&
        !lower.contains('requested');

    if (!isDebit) return;

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

          await _merchantEngine.confirmPendingTransaction(
            transaction: ParsedTransaction(
              smsId: message.id?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
              amount: amount,
              date: date,
              merchantName: merchantName,
              merchantId: merchant?.id ?? 'mer_unknown',
              categoryId: categoryId,
              originalSmsBody: body,
            ),
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('sms_auto_track_last', DateTime.now().millisecondsSinceEpoch);
        }
      }
    }
  }

  @pragma('vm:entry-point')
  static void _backgroundMessageHandler(SmsMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList('sms_background_queue') ?? [];
    pending.add('${message.date}|${message.body}');
    await prefs.setStringList('sms_background_queue', pending);
  }

  Future<int> processBackgroundQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('sms_background_queue') ?? [];
    if (queue.isEmpty) return 0;

    int processed = 0;
    for (final item in queue) {
      final parts = item.split('|');
      if (parts.length < 2) continue;
      
      final dateMs = int.tryParse(parts[0]) ?? DateTime.now().millisecondsSinceEpoch;
      final body = parts.sublist(1).join('|');

      final date = DateTime.fromMillisecondsSinceEpoch(dateMs);

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
                smsId: DateTime.now().microsecondsSinceEpoch.toString(),
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

    await prefs.remove('sms_background_queue');
    return processed;
  }
}
