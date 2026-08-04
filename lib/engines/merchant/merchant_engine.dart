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

  /// Parse inbox messages with full historical scan support or count/date limits.
  Future<List<ParsedTransaction>> scanInbox({int? count, int? year, int? month}) async {
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
        final parsed = parseSingleSms(msg);
        if (parsed == null) continue;

        if (year != null && month != null) {
          if (parsed.date.year != year || parsed.date.month != month) continue;
        }

        parsedList.add(parsed);
      }

      return parsedList;
    } catch (e, st) {
      _logger.e('Error scanning inbox', error: e, stackTrace: st);
      return [];
    }
  }

  /// Single SMS parser handling UPI, Card, IMPS, NEFT, Wallet & Generic Bank messages
  ParsedTransaction? parseSingleSms(SmsMessage msg) {
    if (msg.body == null || msg.body!.trim().isEmpty) return null;

    final body = msg.body!;
    final lowerBody = body.toLowerCase();

    if (!_isFinancial(lowerBody)) return null;

    final parsed = _parseUpi(body, lowerBody, msg) ??
        _parseCard(body, lowerBody, msg) ??
        _parseImps(body, lowerBody, msg) ??
        _parseNeft(body, lowerBody, msg) ??
        _parseWallet(body, lowerBody, msg) ??
        _parseGenericBank(body, lowerBody, msg);

    if (parsed == null) return null;

    final patternMerchant = detectMerchant(body);
    final finalMerchantName = patternMerchant?.name ?? parsed.merchantName;
    final finalCategory = patternMerchant?.categoryId ?? parsed.categoryId;

    return ParsedTransaction(
      smsId: msg.id?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      amount: parsed.amount,
      date: parsed.date,
      merchantName: finalMerchantName,
      merchantId: patternMerchant?.id ?? 'mer_unknown',
      categoryId: finalCategory,
      originalSmsBody: body,
    );
  }

  /// Confirm pending transaction by saving to DB and doing post-write read-back verification
  Future<bool> confirmPendingTransaction({
    required ParsedTransaction transaction,
    String? categoryId,
    TransactionType type = TransactionType.expense,
  }) async {
    final targetCategoryId = categoryId ?? transaction.categoryId;

    try {
      final savedTx = await _expenseEngine.addTransaction(
        amount: transaction.amount,
        date: transaction.date,
        categoryId: targetCategoryId,
        type: type,
        note: 'Auto-tracked: ${transaction.merchantName}',
      );

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

  bool _isFinancial(String text) {
    final keywords = [
      'debited', 'credited', 'spent', 'paid', 'received',
      'upi', 'imps', 'neft', 'rtgs', 'transaction',
      'inr', 'rs.', 'rs ', '₹', 'amount',
      'gpay', 'phonepe', 'paytm', 'amazon pay',
      'debit card', 'credit card', 'acct', 'a/c',
      'transfer', 'withdrawn', 'deposited',
    ];
    return keywords.any((k) => text.contains(k));
  }

  // ─── UPI PARSER ───
  ParsedTransaction? _parseUpi(String body, String lower, SmsMessage msg) {
    if (!lower.contains('upi')) return null;

    final amount = _extractAmount(body);
    if (amount == null) return null;

    String merchant = 'UPI Payment';

    // Pattern 1: UPI/VPA/MERCHANT/REF/...
    final detailMatch = RegExp(
      r'upi[/\\]([^/\\]+)[/\\]([^/\\]+)',
      caseSensitive: false,
    ).firstMatch(body);

    if (detailMatch != null) {
      final vpa = detailMatch.group(1)?.trim();
      final name = detailMatch.group(2)?.trim();
      if (name != null && name.length > 2) {
        merchant = name;
      } else if (vpa != null) {
        merchant = vpa.split('@').first;
      }
    }

    // Pattern 2: "to MERCHANT" or "from MERCHANT" or "paid to MERCHANT"
    final toMatch = RegExp(
      r'(?:to|from|paid to|sent to|received from|money sent to)\s+([a-zA-Z0-9\s\.\-]{3,40}?)(?:\s+upi|\s+ref|\s+txn|\s+for|\s+rs|\s+via|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);

    if (toMatch != null) {
      final m = toMatch.group(1)?.trim();
      if (m != null && m.length > 2) merchant = m;
    }

    final isCredit = lower.contains('credited') ||
        lower.contains('received') ||
        lower.contains('money added') ||
        (lower.contains('from') && !lower.contains('to'));

    if (isCredit) return null; // We focus on expenses / debit tracking

    return ParsedTransaction(
      smsId: msg.id?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      date: _extractDate(body, msg),
      merchantName: _cleanMerchant(merchant),
      merchantId: 'mer_upi',
      categoryId: _categorize(merchant),
      originalSmsBody: body,
    );
  }

  // ─── CARD PARSER ───
  ParsedTransaction? _parseCard(String body, String lower, SmsMessage msg) {
    final hasCard = ['debit card', 'credit card', 'card xx', 'card ending', 'card no']
        .any((i) => lower.contains(i));
    final hasSpend = ['spent', 'purchase', 'payment made'].any((i) => lower.contains(i));

    if (!hasCard && !hasSpend) return null;

    final amount = _extractAmount(body);
    if (amount == null) return null;

    String merchant = 'Card Transaction';

    final atMatch = RegExp(
      r'(?:at|to|on|via|merchant)\s+([a-zA-Z0-9\s\.\-]{2,30}?)(?:\s+trxn|\s+txn|\s+ref|\s+avail|\s+a/c|\s+ac|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);

    if (atMatch != null) {
      final m = atMatch.group(1)?.trim();
      if (m != null && m.length > 1) merchant = m;
    }

    if (lower.contains('credited') || lower.contains('refund')) return null;

    return ParsedTransaction(
      smsId: msg.id?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      date: _extractDate(body, msg),
      merchantName: _cleanMerchant(merchant),
      merchantId: 'mer_card',
      categoryId: _categorize(merchant),
      originalSmsBody: body,
    );
  }

  // ─── IMPS PARSER ───
  ParsedTransaction? _parseImps(String body, String lower, SmsMessage msg) {
    if (!lower.contains('imps')) return null;

    final amount = _extractAmount(body);
    if (amount == null) return null;

    String merchant = 'IMPS Transfer';

    final fromToMatch = RegExp(
      r'(?:from|to|by)\s+([a-zA-Z\s\.]{3,30}?)(?:\s+mobile|\s+ac\s+|\s+a/c|\s+rrn|\s+for|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);

    if (fromToMatch != null) {
      final m = fromToMatch.group(1)?.trim();
      if (m != null && m.length > 2) merchant = m;
    }

    final isCredit = lower.contains('credited') ||
        (lower.contains('from') && !lower.contains('debited'));

    if (isCredit) return null;

    return ParsedTransaction(
      smsId: msg.id?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      date: _extractDate(body, msg),
      merchantName: _cleanMerchant(merchant),
      merchantId: 'mer_imps',
      categoryId: CategoryEngine.catUtilities,
      originalSmsBody: body,
    );
  }

  // ─── NEFT/RTGS PARSER ───
  ParsedTransaction? _parseNeft(String body, String lower, SmsMessage msg) {
    if (!lower.contains('neft') && !lower.contains('rtgs')) return null;

    final amount = _extractAmount(body);
    if (amount == null) return null;

    String merchant = lower.contains('neft') ? 'NEFT Transfer' : 'RTGS Transfer';

    final fromToMatch = RegExp(
      r'(?:from|to|by|name)[:\s]+([a-zA-Z0-9\s\.\-]{3,30}?)(?:\s+ifsc|\s+utr|\s+ref|\s+for|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);

    if (fromToMatch != null) {
      final m = fromToMatch.group(1)?.trim();
      if (m != null && m.length > 2) merchant = m;
    }

    final isCredit = lower.contains('cr') || lower.contains('credited');
    if (isCredit) return null;

    return ParsedTransaction(
      smsId: msg.id?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      date: _extractDate(body, msg),
      merchantName: _cleanMerchant(merchant),
      merchantId: 'mer_neft',
      categoryId: CategoryEngine.catUtilities,
      originalSmsBody: body,
    );
  }

  // ─── WALLET PARSER ───
  ParsedTransaction? _parseWallet(String body, String lower, SmsMessage msg) {
    final wallets = {
      'paytm': 'Paytm',
      'phonepe': 'PhonePe',
      'gpay': 'Google Pay',
      'google pay': 'Google Pay',
      'amazon pay': 'Amazon Pay',
      'mobikwik': 'Mobikwik',
      'freecharge': 'Freecharge',
    };

    String? walletName;
    for (final entry in wallets.entries) {
      if (lower.contains(entry.key)) {
        walletName = entry.value;
        break;
      }
    }
    if (walletName == null) return null;

    final amount = _extractAmount(body);
    if (amount == null) return null;

    String merchant = walletName;

    final merchantMatch = RegExp(
      r'(?:to|at|for|merchant|paid to)[:\s]+([a-zA-Z0-9\s\.\-]{2,30}?)(?:\s+order|\s+txn|\s+ref|\s+upi|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);

    if (merchantMatch != null) {
      final m = merchantMatch.group(1)?.trim();
      if (m != null && m.length > 2 && !m.toLowerCase().contains('rs')) {
        merchant = '$walletName - $m';
      }
    }

    final isCredit = lower.contains('credited') ||
        lower.contains('added') ||
        lower.contains('received') ||
        lower.contains('cashback');

    if (isCredit) return null;

    return ParsedTransaction(
      smsId: msg.id?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      date: _extractDate(body, msg),
      merchantName: _cleanMerchant(merchant),
      merchantId: 'mer_wallet',
      categoryId: _categorize(merchant),
      originalSmsBody: body,
    );
  }

  // ─── GENERIC BANK PARSER ───
  ParsedTransaction? _parseGenericBank(String body, String lower, SmsMessage msg) {
    final bankIndicators = ['a/c', 'ac no', 'account', 'avail bal', 'avl bal', 'bank'];
    if (!bankIndicators.any((i) => lower.contains(i))) return null;

    final amount = _extractAmount(body);
    if (amount == null) return null;

    String merchant = 'Bank Transaction';

    final merchantMatch = RegExp(
      r'(?:for|to|from|towards)[:\s]+([a-zA-Z0-9\s\.\-]{3,30}?)(?:\s+a/c|\s+ac|\s+bal|\s+ref|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);

    if (merchantMatch != null) {
      final m = merchantMatch.group(1)?.trim();
      if (m != null && m.length > 2 && !m.toLowerCase().contains('inr')) {
        merchant = m;
      }
    }

    final isDebit = (lower.contains('debited') ||
            lower.contains('spent') ||
            lower.contains('paid') ||
            lower.contains('sent to') ||
            lower.contains('trf to') ||
            lower.contains('transfer to')) &&
        !lower.contains('credited') &&
        !lower.contains('requested');

    if (!isDebit) return null;

    return ParsedTransaction(
      smsId: msg.id?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      date: _extractDate(body, msg),
      merchantName: _cleanMerchant(merchant),
      merchantId: 'mer_bank',
      categoryId: _categorize(merchant),
      originalSmsBody: body,
    );
  }

  // ─── HELPERS ───

  double? _extractAmount(String text) {
    final patterns = [
      r'(?:rs\.?|inr|₹)\s*[\.,]?\s*([\d,]+\.?\d{0,2})',
      r'([\d,]+\.?\d{0,2})\s*(?:rs\.?|inr|₹)',
      r'(?:amount\s*(?:of|is)?\s*[:]?)\s*[\.,]?\s*([\d,]+\.?\d{0,2})',
    ];

    for (final pattern in patterns) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(text);
      if (match != null) {
        final clean = match.group(1)?.replaceAll(',', '');
        if (clean != null) {
          final val = double.tryParse(clean);
          if (val != null && val > 0 && val < 10000000) return val;
        }
      }
    }
    return null;
  }

  DateTime _extractDate(String body, SmsMessage msg) {
    final patterns = [
      RegExp(r'on\s+(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2,4})', caseSensitive: false),
      RegExp(r'on\s+(\d{1,2})\s*([a-zA-Z]{3,})\s*(\d{2,4})?', caseSensitive: false),
      RegExp(r'(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2,4})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        try {
          final day = int.parse(match.group(1)!);
          final monthOrName = match.group(2)!;
          final yearStr = match.group(3);

          int month;
          if (RegExp(r'^\d+$').hasMatch(monthOrName)) {
            month = int.parse(monthOrName);
          } else {
            month = _monthNameToNum(monthOrName);
          }

          int year = yearStr != null ? int.parse(yearStr) : DateTime.now().year;
          if (year < 100) year += 2000;

          if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            return DateTime(year, month, day);
          }
        } catch (_) {}
      }
    }

    if (msg.date != null) {
      return msg.date!;
    }
    return DateTime.now();
  }

  int _monthNameToNum(String name) {
    final map = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
      'january': 1, 'february': 2, 'march': 3, 'april': 4,
    };
    return map[name.toLowerCase().trim()] ?? DateTime.now().month;
  }

  String _cleanMerchant(String raw) {
    return raw
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s\.\-&]'), '')
        .trim()
        .toUpperCase();
  }

  String _categorize(String merchant) {
    final m = merchant.toLowerCase();

    if (m.contains('zomato') || m.contains('swiggy') || m.contains('zepto') ||
        m.contains('blinkit') || m.contains('bigbasket') || m.contains('dominos') ||
        m.contains('pizza') || m.contains('restaurant') || m.contains('food') ||
        m.contains('eat') || m.contains('cafe') || m.contains('bakery')) {
      return CategoryEngine.catFood;
    }

    if (m.contains('dmart') || m.contains('reliance') || m.contains('mart') ||
        m.contains('grocery') || m.contains('kirana') || m.contains('supermarket') ||
        m.contains('grofers') || m.contains('jio mart')) {
      return CategoryEngine.catGroceries;
    }

    if (m.contains('amazon') || m.contains('flipkart') || m.contains('myntra') ||
        m.contains('ajio') || m.contains('meesho') || m.contains('shopping') ||
        m.contains('nykaa') || m.contains('tatacliq')) {
      return CategoryEngine.catShopping;
    }

    if (m.contains('uber') || m.contains('ola') || m.contains('makemytrip') ||
        m.contains('irctc') || m.contains('redbus') || m.contains('travel') ||
        m.contains('cab') || m.contains('petrol') || m.contains('fuel') ||
        m.contains('rapido') || m.contains('train')) {
      return CategoryEngine.catTransport;
    }

    if (m.contains('netflix') || m.contains('prime') || m.contains('hotstar') ||
        m.contains('spotify') || m.contains('youtube') || m.contains('movie') ||
        m.contains('bookmyshow') || m.contains('sony liv') || m.contains('zee5')) {
      return CategoryEngine.catEntertainment;
    }

    if (m.contains('electricity') || m.contains('water') || m.contains('gas') ||
        m.contains('broadband') || m.contains('mobile') || m.contains('recharge') ||
        m.contains('bill') || m.contains('insurance') || m.contains('emi') ||
        m.contains('loan') || m.contains('rent') || m.contains('maintenance')) {
      return CategoryEngine.catUtilities;
    }

    return CategoryEngine.catUncategorized;
  }

  MerchantPattern? detectMerchant(String body) {
    for (final merchant in kIndianMerchantPatterns) {
      if (merchant.regex.hasMatch(body)) {
        return merchant;
      }
    }
    return null;
  }
}
