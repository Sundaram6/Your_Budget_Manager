import '../utils/currency_formatter.dart';

extension NumberExtensions on num {
  String toCurrency() => CurrencyFormatter.format(this);
  String toCurrencyCompact() => CurrencyFormatter.formatCompact(this);
  String toCurrencySigned() => CurrencyFormatter.formatSigned(this);
}
