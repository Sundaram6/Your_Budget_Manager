import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:logger/logger.dart';
import '../../core/utils/platform_guard.dart';
import 'data/merchant_patterns.dart';
import 'models/parsed_transaction.dart';

class SmsParserEngine {
  SmsParserEngine(this._smsQuery, this._logger);

  final SmsQuery _smsQuery;
  final Logger _logger;

  // Amount extraction regex formats:
  // Rs. 100
  // Rs 100.50
  // INR 500
  // 1,000.00
  static final RegExp _amountRegex = RegExp(
      r'(?:(?:RS|INR|₹)\.?\s?)([0-9,]+(?:\.[0-9]+)?)|([0-9,]+(?:\.[0-9]+)?)(?=\s?(?:RS|INR|₹))',
      caseSensitive: false);

  /// Parse the last [count] messages from the inbox.
  Future<List<ParsedTransaction>> scanInbox({int count = 500}) async {
    if (!PlatformGuard.isSmsSupported) {
      _logger.w('SMS parsing is only supported on Android.');
      return [];
    }

    try {
      final messages = await _smsQuery.querySms(
        kinds: [SmsQueryKind.inbox],
        count: count,
      );

      final parsedList = <ParsedTransaction>[];

      for (final msg in messages) {
        final body = msg.body ?? '';
        final date = msg.date;
        if (date == null) continue;

        // Ensure it looks like a debit/expense transaction
        if (!_isDebitTransaction(body)) continue;

        final amount = _extractAmount(body);
        if (amount == null || amount <= 0) continue;

        final merchant = _detectMerchant(body);
        if (merchant == null) continue;

        parsedList.add(ParsedTransaction(
          smsId: msg.id?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
          amount: amount,
          date: date,
          merchantName: merchant.name,
          merchantId: merchant.id,
          categoryId: merchant.categoryId,
          originalSmsBody: body,
        ));
      }

      return parsedList;
    } catch (e) {
      _logger.e('Error scanning inbox', error: e);
      return [];
    }
  }

  bool _isDebitTransaction(String body) {
    final lower = body.toLowerCase();
    return (lower.contains('debited') ||
            lower.contains('spent') ||
            lower.contains('paid')) &&
        !lower.contains('credited') && // ignore credits for expenses
        !lower.contains('requested');
  }

  double? _extractAmount(String body) {
    final match = _amountRegex.firstMatch(body);
    if (match != null) {
      final amountStr = (match.group(1) ?? match.group(2))?.replaceAll(',', '');
      if (amountStr != null) {
        return double.tryParse(amountStr);
      }
    }
    return null;
  }

  MerchantPattern? _detectMerchant(String body) {
    for (final merchant in kIndianMerchantPatterns) {
      if (merchant.regex.hasMatch(body)) {
        return merchant;
      }
    }
    return null;
  }
}
