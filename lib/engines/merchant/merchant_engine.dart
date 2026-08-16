import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:logger/logger.dart';

import '../../core/enums.dart';
import '../../core/utils/platform_guard.dart';
import '../../core/utils/currency_formatter.dart';
import '../category/category_engine.dart';
import '../expense/expense_engine.dart';
import '../sms/data/merchant_patterns.dart';
import '../sms/models/parsed_transaction.dart';

class MerchantEngine {
  MerchantEngine(this._smsQuery, this._logger, this._expenseEngine);

  final SmsQuery _smsQuery;
  final Logger _logger;
  final ExpenseEngine _expenseEngine;

  /// Generates a deterministic, immutable SHA-256 identity for an SMS message
  /// from its immutable properties: Android Telephony ID, sender address, timestamp, and body.
  /// Guarantees that re-processing the same SMS at any point produces the exact same ID.
  static String generateDurableSmsId(SmsMessage msg) {
    final id = msg.id?.toString().trim() ?? '';
    final address = msg.address?.trim().toUpperCase() ?? '';
    final timestamp = msg.date?.millisecondsSinceEpoch.toString() ?? '0';
    final body = msg.body?.trim() ?? '';

    final raw = 'sms:$id:$address:$timestamp:$body';
    final hash = sha256.convert(utf8.encode(raw)).toString();
    return 'sms_sha256_$hash';
  }

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
        _parseImps(body, lowerBody, msg) ??
        _parseNeft(body, lowerBody, msg) ??
        _parseCard(body, lowerBody, msg) ??
        _parseWallet(body, lowerBody, msg) ??
        _parseGenericBank(body, lowerBody, msg);

    if (parsed == null) return null;

    final patternMerchant = detectMerchant(body);
    final isGenericProvider = patternMerchant != null &&
        const {
          'mer_paytm',
          'mer_phonepe',
          'mer_gpay',
          'mer_hdfc',
          'mer_icici',
          'mer_sbi',
          'mer_axis'
        }.contains(patternMerchant.id);

    const genericParsedNames = {
      'UPI Payment',
      'UPI Credit',
      'Card Transaction',
      'Card Refund',
      'IMPS Transfer',
      'IMPS Credit',
      'NEFT Transfer',
      'NEFT Credit',
      'RTGS Transfer',
      'RTGS Credit',
      'Bank Transaction',
      'Bank Credit',
      'Paytm',
      'PhonePe',
      'Google Pay',
      'Amazon Pay',
      'Mobikwik',
      'Freecharge',
    };

    final isParsedSpecific = !genericParsedNames.contains(parsed.merchantName) && parsed.merchantName.trim().isNotEmpty;

    final finalMerchantName = (patternMerchant != null && (!isGenericProvider || !isParsedSpecific))
        ? patternMerchant.name
        : parsed.merchantName;

    // For credit transactions, default category to catIncome unless a specific merchant category is identified
    final finalCategory = parsed.type == TransactionType.income &&
            (patternMerchant == null ||
                patternMerchant.categoryId == CategoryEngine.catUncategorized ||
                patternMerchant.categoryId == CategoryEngine.catUtilities)
        ? CategoryEngine.catIncome
        : (patternMerchant?.categoryId ?? parsed.categoryId);

    final finalMerchantId = patternMerchant?.id ?? parsed.merchantId;
    String finalSourceApp = 'sms:unknown';

    if (finalMerchantId.startsWith('mer_')) {
      finalSourceApp = 'sms:${finalMerchantId.substring(4)}';
    }

    final paymentEvidence = extractPaymentEvidence(body);
    final accountLast4 = _extractAccountLast4(body);
    final transactionRef = _extractTransactionRef(body);

    return ParsedTransaction(
      smsId: generateDurableSmsId(msg),
      amount: parsed.amount,
      date: parsed.date,
      type: parsed.type,
      merchantName: finalMerchantName,
      merchantId: finalMerchantId,
      categoryId: finalCategory,
      originalSmsBody: body,
      sourceApp: finalSourceApp,
      paymentMethod: paymentEvidence.method,
      cardLast4: paymentEvidence.cardLast4,
      accountLast4: accountLast4,
      transactionRef: transactionRef,
    );
  }

  /// Confirm pending transaction by saving to DB and doing post-write read-back verification
  Future<bool> confirmPendingTransaction({
    required ParsedTransaction transaction,
    String? categoryId,
    TransactionType? type,
  }) async {
    final targetCategoryId = categoryId ?? transaction.categoryId;
    final targetType = type ?? transaction.type;

    try {
      final amountPaise = transaction.amount;
      final savedTx = await _expenseEngine.addTransaction(
        amount: amountPaise,
        date: transaction.date,
        categoryId: targetCategoryId,
        type: targetType,
        note: 'Auto-tracked: ${transaction.merchantName}',
        sourceApp: transaction.sourceApp,
        paymentMethod: transaction.paymentMethod,
        cardLast4: transaction.cardLast4,
        accountLast4: transaction.accountLast4,
        transactionRef: transaction.transactionRef,
        merchantName: transaction.merchantName,
        sourceMessageId: transaction.smsId,
      );

      final verifiedTx = await _expenseEngine.getTransactionById(savedTx.id);

      if (verifiedTx != null && verifiedTx.id == savedTx.id && verifiedTx.amount.value == amountPaise) {
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

    final isCredit = lower.contains('credited') ||
        lower.contains('received') ||
        lower.contains('money added') ||
        lower.contains('deposited') ||
        (lower.contains('from') && !lower.contains('to') && !lower.contains('debited'));

    final type = isCredit ? TransactionType.income : TransactionType.expense;
    String merchant = isCredit ? 'UPI Credit' : 'UPI Payment';

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
      r'(?:to|from|paid to|sent to|received from|credited by|money sent to)\s+([a-zA-Z0-9\s\.\-]{3,40}?)(?:\s+upi|\s+ref|\s+txn|\s+for|\s+rs|\s+via|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);

    if (toMatch != null) {
      final m = toMatch.group(1)?.trim();
      if (m != null && m.length > 2) merchant = m;
    }

    final categoryId = isCredit ? CategoryEngine.catIncome : _categorize(merchant);

    return ParsedTransaction(
      smsId: generateDurableSmsId(msg),
      amount: amount,
      date: _extractDate(body, msg),
      type: type,
      merchantName: _cleanMerchant(merchant),
      merchantId: 'mer_upi',
      categoryId: categoryId,
      originalSmsBody: body,
      sourceApp: 'sms:upi',
    );
  }

  // ─── CARD PARSER ───
  ParsedTransaction? _parseCard(String body, String lower, SmsMessage msg) {
    if (lower.contains('imps') || lower.contains('neft') || lower.contains('rtgs')) return null;

    final hasCard = ['debit card', 'credit card', 'card xx', 'card ending', 'card no']
        .any((i) => lower.contains(i));
    final hasSpend = ['spent', 'purchase', 'payment made', 'debited'].any((i) => lower.contains(i));
    final hasCredit = ['credited', 'refund', 'cashback', 'reversed'].any((i) => lower.contains(i));

    if (!hasCard && !hasSpend && !hasCredit) return null;

    final amount = _extractAmount(body);
    if (amount == null) return null;

    final isCredit = lower.contains('credited') ||
        lower.contains('refund') ||
        lower.contains('cashback') ||
        lower.contains('reversed');
    final type = isCredit ? TransactionType.income : TransactionType.expense;

    String merchant = isCredit ? 'Card Refund' : 'Card Transaction';

    final atMatch = RegExp(
      r'(?:at|to|on|via|merchant|from)\s+([a-zA-Z0-9\s\.\-]{2,30}?)(?:\s+trxn|\s+txn|\s+ref|\s+avail|\s+a/c|\s+ac|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);

    if (atMatch != null) {
      final m = atMatch.group(1)?.trim();
      if (m != null && m.length > 1) merchant = m;
    }

    final categoryId = isCredit ? CategoryEngine.catIncome : _categorize(merchant);

    return ParsedTransaction(
      smsId: generateDurableSmsId(msg),
      amount: amount,
      date: _extractDate(body, msg),
      type: type,
      merchantName: _cleanMerchant(merchant),
      merchantId: 'mer_card',
      categoryId: categoryId,
      originalSmsBody: body,
      sourceApp: 'sms:card',
    );
  }

  // ─── IMPS PARSER ───
  ParsedTransaction? _parseImps(String body, String lower, SmsMessage msg) {
    if (!lower.contains('imps')) return null;

    final amount = _extractAmount(body);
    if (amount == null) return null;

    final isCredit = lower.contains('credited') ||
        (lower.contains('from') && !lower.contains('debited') && !lower.contains('to'));
    final type = isCredit ? TransactionType.income : TransactionType.expense;

    String merchant = isCredit ? 'IMPS Credit' : 'IMPS Transfer';

    final fromToMatch = RegExp(
      r'(?:from|to|by)\s+([a-zA-Z\s\.]{3,30}?)(?:\s+mobile|\s+ac\s+|\s+a/c|\s+rrn|\s+for|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);

    if (fromToMatch != null) {
      final m = fromToMatch.group(1)?.trim();
      if (m != null && m.length > 2) merchant = m;
    }

    final categoryId = isCredit ? CategoryEngine.catIncome : CategoryEngine.catUncategorized;

    return ParsedTransaction(
      smsId: generateDurableSmsId(msg),
      amount: amount,
      date: _extractDate(body, msg),
      type: type,
      merchantName: _cleanMerchant(merchant),
      merchantId: 'mer_imps',
      categoryId: categoryId,
      originalSmsBody: body,
      sourceApp: 'sms:imps',
    );
  }

  // ─── NEFT/RTGS PARSER ───
  ParsedTransaction? _parseNeft(String body, String lower, SmsMessage msg) {
    if (!lower.contains('neft') && !lower.contains('rtgs')) return null;

    final amount = _extractAmount(body);
    if (amount == null) return null;

    final isCredit = lower.contains('credited') ||
        lower.contains('received') ||
        (lower.contains('cr') && !lower.contains('card') && !lower.contains('across'));
    final type = isCredit ? TransactionType.income : TransactionType.expense;

    String merchant = isCredit
        ? (lower.contains('neft') ? 'NEFT Credit' : 'RTGS Credit')
        : (lower.contains('neft') ? 'NEFT Transfer' : 'RTGS Transfer');

    final fromToMatch = RegExp(
      r'(?:from|to|by|name)[:\s]+([a-zA-Z0-9\s\.\-]{3,30}?)(?:\s+ifsc|\s+utr|\s+ref|\s+for|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);

    if (fromToMatch != null) {
      final m = fromToMatch.group(1)?.trim();
      if (m != null && m.length > 2) merchant = m;
    }

    final categoryId = isCredit ? CategoryEngine.catIncome : CategoryEngine.catUncategorized;

    return ParsedTransaction(
      smsId: generateDurableSmsId(msg),
      amount: amount,
      date: _extractDate(body, msg),
      type: type,
      merchantName: _cleanMerchant(merchant),
      merchantId: 'mer_neft',
      categoryId: categoryId,
      originalSmsBody: body,
      sourceApp: 'sms:neft',
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

    final isCredit = lower.contains('credited') ||
        lower.contains('added') ||
        lower.contains('received') ||
        lower.contains('cashback') ||
        lower.contains('refund');
    final type = isCredit ? TransactionType.income : TransactionType.expense;

    String merchant = walletName;

    final merchantMatches = RegExp(
      r'(?:for|to|at|merchant|paid to|from|received from)\s+([a-zA-Z0-9\s\.\-]{2,30}?)(?:\s+order|\s+txn|\s+ref|\s+upi|\n|$)',
      caseSensitive: false,
    ).allMatches(body);

    for (final match in merchantMatches) {
      final val = match.group(1)?.trim();
      if (val != null && val.length > 2 && !val.toLowerCase().contains('rs') && !wallets.containsKey(val.toLowerCase())) {
        merchant = '$walletName - $val';
        break;
      }
    }

    final categoryId = isCredit ? CategoryEngine.catIncome : _categorize(merchant);

    return ParsedTransaction(
      smsId: generateDurableSmsId(msg),
      amount: amount,
      date: _extractDate(body, msg),
      type: type,
      merchantName: _cleanMerchant(merchant),
      merchantId: 'mer_wallet',
      categoryId: categoryId,
      originalSmsBody: body,
      sourceApp: 'sms:wallet',
    );
  }

  // ─── GENERIC BANK PARSER ───
  ParsedTransaction? _parseGenericBank(String body, String lower, SmsMessage msg) {
    final bankIndicators = ['a/c', 'ac no', 'account', 'avail bal', 'avl bal', 'bank'];
    if (!bankIndicators.any((i) => lower.contains(i))) return null;

    final amount = _extractAmount(body);
    if (amount == null) return null;

    final isDebit = (lower.contains('debited') ||
            lower.contains('spent') ||
            lower.contains('paid') ||
            lower.contains('sent to') ||
            lower.contains('trf to') ||
            lower.contains('transfer to') ||
            lower.contains('withdrawn')) &&
        !lower.contains('credited') &&
        !lower.contains('deposited') &&
        !lower.contains('requested');

    final isCredit = (lower.contains('credited') ||
            lower.contains('received') ||
            lower.contains('deposited') ||
            lower.contains('cr to') ||
            lower.contains('credited to') ||
            lower.contains('salary') ||
            lower.contains('refund')) &&
        !lower.contains('debited') &&
        !lower.contains('requested');

    if (!isDebit && !isCredit) return null;

    final type = isCredit ? TransactionType.income : TransactionType.expense;
    String merchant = isCredit ? 'Bank Credit' : 'Bank Transaction';

    final merchantMatch = RegExp(
      r'(?:for|to|from|towards|by)[:\s]+([a-zA-Z0-9\s\.\-]{3,30}?)(?:\s+a/c|\s+ac|\s+bal|\s+ref|\n|$)',
      caseSensitive: false,
    ).firstMatch(body);

    if (merchantMatch != null) {
      final m = merchantMatch.group(1)?.trim();
      if (m != null && m.length > 2 && !m.toLowerCase().contains('inr')) {
        merchant = m;
      }
    }

    final categoryId = isCredit ? CategoryEngine.catIncome : _categorize(merchant);

    return ParsedTransaction(
      smsId: generateDurableSmsId(msg),
      amount: amount,
      date: _extractDate(body, msg),
      type: type,
      merchantName: _cleanMerchant(merchant),
      merchantId: 'mer_bank',
      categoryId: categoryId,
      originalSmsBody: body,
      sourceApp: 'sms:bank',
    );
  }

  // ─── HELPERS ───

  int? _extractAmount(String text) {
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
          final val = CurrencyFormatter.parseRupeesToPaise(clean);
          if (val != null && val > 0 && val < 1000000000) return val; // sanity check in paise
        }
      }
    }
    return null;
  }

  DateTime _extractDate(String body, SmsMessage msg) {
    final patterns = [
      // 1. "15-Aug-2026", "15 August 2026", "15.August.2026", "15-AUG-26"
      RegExp(r'\b(\d{1,2})[\s\-\/\.]+([a-zA-Z]{3,})(?:[\s\-\/\.]+(\d{2,4}))?\b', caseSensitive: false),
      // 2. "August 15, 2026", "Aug 15 2026"
      RegExp(r'\b([a-zA-Z]{3,})[\s\-\/\.]+(\d{1,2})(?:[,\s\-\/\.]+(\d{2,4}))?\b', caseSensitive: false),
      // 3. "15/08/2026", "15-08-2026", "15.08.2026", "15/08/26"
      RegExp(r'\b(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2,4})\b', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      for (final match in pattern.allMatches(body)) {
        try {
          int day;
          int? month;
          String? yearStr;

          final g1 = match.group(1)!;
          final g2 = match.group(2)!;
          final g3 = match.group(3);

          if (RegExp(r'^\d+$').hasMatch(g1)) {
            day = int.parse(g1);
            if (RegExp(r'^\d+$').hasMatch(g2)) {
              month = int.parse(g2);
            } else {
              month = _monthNameToNum(g2);
            }
            yearStr = g3;
          } else {
            month = _monthNameToNum(g1);
            day = int.parse(g2);
            yearStr = g3;
          }

          if (month == null || month < 1 || month > 12) continue;
          if (day < 1 || day > 31) continue;

          int year = yearStr != null ? int.parse(yearStr) : (msg.date?.year ?? DateTime.now().year);
          if (year < 100) year += 2000;

          if (msg.date != null) {
            return DateTime(
              year,
              month,
              day,
              msg.date!.hour,
              msg.date!.minute,
              msg.date!.second,
              msg.date!.millisecond,
            );
          }

          return DateTime(year, month, day);
        } catch (_) {}
      }
    }

    if (msg.date != null) {
      return msg.date!;
    }
    return DateTime.now();
  }

  int? _monthNameToNum(String name) {
    final map = {
      'jan': 1, 'january': 1,
      'feb': 2, 'february': 2,
      'mar': 3, 'march': 3,
      'apr': 4, 'april': 4,
      'may': 5, 'may': 5,
      'jun': 6, 'june': 6,
      'jul': 7, 'july': 7,
      'aug': 8, 'august': 8,
      'sep': 9, 'sept': 9, 'september': 9,
      'oct': 10, 'october': 10,
      'nov': 11, 'november': 11,
      'dec': 12, 'december': 12,
    };
    return map[name.toLowerCase().trim()];
  }

  String _cleanMerchant(String raw) {
    String cleaned = raw
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s\.\-&]'), '')
        .trim();

    cleaned = cleaned.replaceAll(RegExp(r'\s+ON\s+\d{1,2}[A-Za-z]{3}\d{0,4}$', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+ON\s+\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]?\d{0,4}$', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+(?:TRXN|TXN|REF|ORDER|UPI)\s.*$', caseSensitive: false), '');

    return cleaned.trim();
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

  /// Extracts structured payment evidence strictly from the SMS body text.
  /// Does NOT guess from sourceApp, merchantName, or bank name.
  ({PaymentMethod method, String? cardLast4}) extractPaymentEvidence(String body) {
    final lower = body.toLowerCase();

    // 1. Check for Debit Card evidence
    final isDebitCard = lower.contains('debit card') ||
        RegExp(r'\bdc\s*(?:ending|no\.?|xx+|\*+|\#)', caseSensitive: false).hasMatch(body);

    if (isDebitCard) {
      final cardLast4 = _extractCardLast4(body, isDebit: true);
      return (method: PaymentMethod.debit_card, cardLast4: cardLast4);
    }

    // 2. Check for Credit Card evidence
    final isCreditCard = lower.contains('credit card') ||
        lower.contains('sbicard') ||
        RegExp(r'\bcc\s*(?:ending|no\.?|xx+|\*+|\#)', caseSensitive: false).hasMatch(body);

    if (isCreditCard) {
      final cardLast4 = _extractCardLast4(body, isCredit: true);
      return (method: PaymentMethod.credit_card, cardLast4: cardLast4);
    }

    // 3. Check for UPI structured evidence
    final isUpi = RegExp(
      r'(?:upi\s*ref(?:\s*no\.?)?|upi[/\\]|vpa\b|upi\s*txn|via\s+upi|using\s+upi|paid\s+via\s+upi|upi\s*transaction|\bupi-|\bupi:)',
      caseSensitive: false,
    ).hasMatch(body);

    if (isUpi) {
      return (method: PaymentMethod.upi, cardLast4: null);
    }

    // 4. Check for Cash structured evidence
    final isCash = RegExp(
      r'(?:cash\s+withdrawal|paid\s+in\s+cash|paid\s+by\s+cash)',
      caseSensitive: false,
    ).hasMatch(body);

    if (isCash) {
      return (method: PaymentMethod.cash, cardLast4: null);
    }

    // 5. No structured evidence found -> unknown (do NOT guess from merchant/sourceApp)
    return (method: PaymentMethod.unknown, cardLast4: null);
  }

  String? _extractCardLast4(String body, {bool isDebit = false, bool isCredit = false}) {
    // Look specifically for card numbers (avoid matching A/c or Account numbers)
    final patterns = [
      // "debit card ending 1234", "credit card ending in 1234", "debit card no. 1234", "card ending 1234"
      RegExp(r'(?:debit\s+card|credit\s+card|sbicard|card|dc|cc)\s*(?:ending(?:\s+(?:with|in|at))?|no\.?|number|xx+|\*+|\#)?\s*(\d{4})\b', caseSensitive: false),
      // "ending with 1234" / "ending 1234" (when preceded by card)
      RegExp(r'(?:card|dc|cc)[^\d]*?(?:xx+|\*+|\#|\bno\.?\s*|\bending\s*)\s*(\d{4})\b', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final digits = match.group(1);
        if (digits != null && digits.length == 4) {
          return digits;
        }
      }
    }

    return null;
  }

  String? _extractAccountLast4(String body) {
    // Look specifically for bank account patterns (e.g. A/c *1234, A/c XX5678, Acct ending 1234, Account No 1234)
    // Avoid matching card numbers
    final patterns = [
      RegExp(r'(?:a/c|acct|account|ac)\s*(?:no\.?|number|ending(?:\s+(?:with|in|at))?|xx+|\*+|\#|\.+)?\s*(\d{3,4})\b', caseSensitive: false),
      RegExp(r'(?:a/c|acct|account)\s+[*xX#]*(\d{3,4})\b', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final digits = match.group(1);
        if (digits != null && (digits.length == 3 || digits.length == 4)) {
          return digits;
        }
      }
    }

    return null;
  }

  String? _extractTransactionRef(String body) {
    // Extract UTR, RRN, Reference numbers, UPI transaction IDs before merchant cleanup
    final patterns = [
      RegExp(r'(?:upi\s*ref(?:\s*no\.?)?|ref(?:\s*no\.?)?|utr(?:\s*no\.?)?|rrn(?:\s*no\.?)?|txn\s*(?:id|no\.?)?|transaction\s*(?:id|no\.?)?)[:\s]+([a-zA-Z0-9]{6,25})\b', caseSensitive: false),
      RegExp(r'upi[/\\](?:[a-zA-Z0-9]+[/\\])?([a-zA-Z0-9]{8,25})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final ref = match.group(1)?.trim();
        if (ref != null && ref.isNotEmpty) {
          return ref;
        }
      }
    }

    return null;
  }
}
