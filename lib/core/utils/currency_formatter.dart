import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _noDecimalsFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Formats integer paise as ₹ Indian Rupee string (e.g. 10050 -> ₹100.50).
  static String formatPaise(int paise) {
    return _formatter.format(paise / 100.0);
  }

  /// Formats integer paise without decimal digits (e.g. 10000 -> ₹100).
  static String formatPaiseNoDecimals(int paise) {
    return _noDecimalsFormatter.format(paise / 100.0);
  }

  /// Formats integer paise in compact representation (e.g. 5000000 -> ₹50K).
  static String formatPaiseCompact(int paise) {
    return _compactFormatter.format(paise / 100.0);
  }

  /// Formats integer paise with explicit +/- sign.
  static String formatPaiseSigned(int paise) {
    if (paise > 0) {
      return '+${formatPaise(paise)}';
    }
    return formatPaise(paise);
  }

  /// Parses user-input rupee string to integer paise without floating-point inaccuracies.
  /// Examples:
  ///   '19.99' -> 1999
  ///   '1,234.50' -> 123450
  ///   '50' -> 5000
  ///   '0.05' -> 5
  /// Returns null if string is empty or invalid.
  static int? parseRupeesToPaise(String? input) {
    if (input == null) return null;
    var cleaned = input.replaceAll('₹', '').replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;

    final isNegative = cleaned.startsWith('-');
    if (isNegative) {
      cleaned = cleaned.substring(1).trim();
    }

    if (!RegExp(r'^\d*(\.\d{0,2})?$').hasMatch(cleaned) || cleaned == '.') {
      return null;
    }

    final parts = cleaned.split('.');
    final wholePart = parts[0].isEmpty ? 0 : int.tryParse(parts[0]);
    if (wholePart == null) return null;

    int fractionalPart = 0;
    if (parts.length > 1 && parts[1].isNotEmpty) {
      final fracStr = parts[1].padRight(2, '0').substring(0, 2);
      fractionalPart = int.tryParse(fracStr) ?? 0;
    }

    final paise = (wholePart * 100) + fractionalPart;
    return isNegative ? -paise : paise;
  }

  /// Deprecated bridge for old callers during migration. Formats rupees directly.
  static String format(num amountRupees) {
    return _formatter.format(amountRupees);
  }

  /// Deprecated bridge for old callers during migration.
  static String formatCompact(num amountRupees) {
    return _compactFormatter.format(amountRupees);
  }

  /// Deprecated bridge for old callers during migration.
  static String formatSigned(num amountRupees) {
    if (amountRupees > 0) {
      return '+${format(amountRupees)}';
    }
    return format(amountRupees);
  }
}
