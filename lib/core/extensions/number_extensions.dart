import '../utils/currency_formatter.dart';

extension IntegerCurrencyExtensions on int {
  /// Formats this integer (representing paise) as an Indian Rupee string (₹X,XX,XXX.XX).
  String toCurrency() => CurrencyFormatter.formatPaise(this);

  /// Formats this integer (representing paise) without decimal digits (₹X,XX,XXX).
  String toCurrencyNoDecimals() => CurrencyFormatter.formatPaiseNoDecimals(this);

  /// Formats this integer (representing paise) in compact notation (₹Xk / ₹XL).
  String toCurrencyCompact() => CurrencyFormatter.formatPaiseCompact(this);

  /// Formats this integer (representing paise) with signed notation (+₹X.XX / -₹X.XX).
  String toCurrencySigned() => CurrencyFormatter.formatPaiseSigned(this);

  /// Converts this integer (representing paise) to double rupees (for charting/sliders).
  double toRupees() => this / 100.0;
}

extension NumberExtensions on num {
  /// Formats this number (treated as rupees for backward compatibility) to currency.
  String toRupeesCurrency() => CurrencyFormatter.format(this);
}
