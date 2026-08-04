import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:logger/logger.dart';

import '../../core/enums.dart';
import '../../core/utils/platform_guard.dart';
import '../category/category_engine.dart';
import '../expense/expense_engine.dart';
import '../sms/data/merchant_patterns.dart';
import '../sms/models/parsed_transaction.dart';

class MerchantEngine {
  MerchantEngine(this._smsQuery, this._logger, this._expenseEngine);

  final SmsQuery _smsQuery;
  final Logger _logger;
  final ExpenseEngine _expenseEngine;

  static final RegExp _amountRegex = RegExp(
      r'(?:(?:RS|INR|₹)\.?\s?)([0-9,]+(?:\.[0-9]+)?)|([0-9,]+(?:\.[0-9]+)?)(?=\s?(?:RS|INR|₹))',
      caseSensitive: false);

  /// Parse inbox messages with full historical scan support or count limits.
  Future<List<ParsedTransaction>> scanInbox({int? count}) async {
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
        final date = msg.date ?? DateTime.now();

        if (!_isDebitTransaction(body)) continue;

        final amount = _extractAmount(body);
        if (amount == null || amount <= 0) continue;

        final merchant = detectMerchant(body);
        final merchantName = merchant?.name ?? _extractFallbackMerchantName(body);
        final categoryId = merchant?.categoryId ?? CategoryEngine.catUncategorized;

        parsedList.add(ParsedTransaction(
          smsId: msg.id?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
          amount: amount,
          date: date,
          merchantName: merchantName,
          merchantId: merchant?.id ?? 'mer_unknown',
          categoryId: categoryId,
          originalSmsBody: body,
        ));

      }

      return parsedList;
    } catch (e, st) {
      _logger.e('Error scanning inbox', error: e, stackTrace: st);
      return [];
    }
  }

  /// Confirm pending transaction by saving to DB and doing post-write read-back verification
  Future<bool> confirmPendingTransaction({
    required ParsedTransaction transaction,
    String? categoryId,
    TransactionType type = TransactionType.expense,
  }) async {
    final targetCategoryId = categoryId ?? transaction.categoryId;


    try {
      // 1. Add transaction to DB via ExpenseEngine
      final savedTx = await _expenseEngine.addTransaction(
        amount: transaction.amount,
        date: transaction.date,
        categoryId: targetCategoryId,
        type: type,
        note: 'Auto-tracked: ${transaction.merchantName}',
      );

      // 2. Post-write read-back verification: query DB directly to confirm persistence
      final verifiedTx = await _expenseEngine.getTransactionById(savedTx.id);

      if (verifiedTx != null && verifiedTx.id == savedTx.id && verifiedTx.amount.value == transaction.amount) {
        _logger.i('Verified DB save for pending transaction ${savedTx.id}');
        return true;
      } else {
        _logger.e('Post-write read-back verification failed for transaction ${savedTx.id}');
        throw StateError('Post-write read-back verification failed for transaction ${savedTx.id}: row not found in SQLite database.');
      }
    } catch (e, st) {
      _logger.e('Failed to confirm pending transaction', error: e, stackTrace: st);
      rethrow;
    }
  }


  bool _isDebitTransaction(String body) {
    final lower = body.toLowerCase();
    return (lower.contains('debited') ||
            lower.contains('spent') ||
            lower.contains('paid') ||
            lower.contains('sent to') ||
            lower.contains('trf to') ||
            lower.contains('transfer to')) &&
        !lower.contains('credited') &&
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

  MerchantPattern? detectMerchant(String body) {
    for (final merchant in kIndianMerchantPatterns) {
      if (merchant.regex.hasMatch(body)) {
        return merchant;
      }
    }
    return null;
  }

  String _extractFallbackMerchantName(String body) {
    final match = RegExp(r'(?:to|at|vpa|info)\s+([A-Za-z0-9\.\@\_]+)', caseSensitive: false).firstMatch(body);
    if (match != null) {
      return match.group(1) ?? 'Unknown Merchant';
    }
    return 'Unknown Merchant';
  }
}
