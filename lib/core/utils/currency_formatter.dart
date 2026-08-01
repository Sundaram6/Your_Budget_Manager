import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _formatter.format(amount);
  }

  static String formatCompact(num amount) {
    return _compactFormatter.format(amount);
  }

  static String formatSigned(num amount) {
    if (amount > 0) {
      return '+${format(amount)}';
    }
    return format(amount); // Negatives already have a minus sign
  }
}
