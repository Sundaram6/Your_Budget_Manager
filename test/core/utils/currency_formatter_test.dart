import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/extensions/number_extensions.dart';
import 'package:your_budget_manager/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter - formatPaise', () {
    test('formats standard paise to Indian Rupee representation with decimals', () {
      expect(CurrencyFormatter.formatPaise(10050), '₹100.50');
      expect(CurrencyFormatter.formatPaise(123456789), '₹12,34,567.89');
      expect(CurrencyFormatter.formatPaise(0), '₹0.00');
      expect(CurrencyFormatter.formatPaise(5), '₹0.05');
      expect(CurrencyFormatter.formatPaise(99), '₹0.99');
      expect(CurrencyFormatter.formatPaise(100), '₹1.00');
    });

    test('formats paise without decimal digits', () {
      expect(CurrencyFormatter.formatPaiseNoDecimals(10050), '₹101');
      expect(CurrencyFormatter.formatPaiseNoDecimals(10000), '₹100');
      expect(CurrencyFormatter.formatPaiseNoDecimals(123456700), '₹12,34,567');
      expect(CurrencyFormatter.formatPaiseNoDecimals(0), '₹0');
    });

    test('formats paise in compact notation', () {
      expect(CurrencyFormatter.formatPaiseCompact(5000000), contains('50')); // ₹50K
      expect(CurrencyFormatter.formatPaiseCompact(100000000), contains('10')); // ₹10L / 1M
    });

    test('formats paise signed', () {
      expect(CurrencyFormatter.formatPaiseSigned(10050), '+₹100.50');
      expect(CurrencyFormatter.formatPaiseSigned(-10050), '-₹100.50');
      expect(CurrencyFormatter.formatPaiseSigned(0), '₹0.00');
    });
  });

  group('CurrencyFormatter - parseRupeesToPaise', () {
    test('parses plain whole rupee strings', () {
      expect(CurrencyFormatter.parseRupeesToPaise('100'), 10000);
      expect(CurrencyFormatter.parseRupeesToPaise('0'), 0);
      expect(CurrencyFormatter.parseRupeesToPaise('1500'), 150000);
    });

    test('parses rupee strings with decimals accurately without floating point error', () {
      expect(CurrencyFormatter.parseRupeesToPaise('19.99'), 1999);
      expect(CurrencyFormatter.parseRupeesToPaise('19.9'), 1990);
      expect(CurrencyFormatter.parseRupeesToPaise('0.05'), 5);
      expect(CurrencyFormatter.parseRupeesToPaise('0.5'), 50);
      expect(CurrencyFormatter.parseRupeesToPaise('.75'), 75);
    });

    test('parses rupee strings with commas and rupee symbol', () {
      expect(CurrencyFormatter.parseRupeesToPaise('₹1,234.50'), 123450);
      expect(CurrencyFormatter.parseRupeesToPaise('₹ 20,000'), 2000000);
      expect(CurrencyFormatter.parseRupeesToPaise('  1,00,000.00  '), 10000000);
    });

    test('handles negative amounts', () {
      expect(CurrencyFormatter.parseRupeesToPaise('-50.25'), -5025);
    });

    test('returns null for invalid inputs', () {
      expect(CurrencyFormatter.parseRupeesToPaise(null), isNull);
      expect(CurrencyFormatter.parseRupeesToPaise(''), isNull);
      expect(CurrencyFormatter.parseRupeesToPaise('   '), isNull);
      expect(CurrencyFormatter.parseRupeesToPaise('.'), isNull);
      expect(CurrencyFormatter.parseRupeesToPaise('abc'), isNull);
      expect(CurrencyFormatter.parseRupeesToPaise('12.345'), isNull); // > 2 decimal places
      expect(CurrencyFormatter.parseRupeesToPaise('12.3.4'), isNull);
    });
  });

  group('IntegerCurrencyExtensions', () {
    test('extension methods work directly on int paise', () {
      expect(10050.toCurrency(), '₹100.50');
      expect(10000.toCurrencyNoDecimals(), '₹100');
      expect(10050.toCurrencySigned(), '+₹100.50');
      expect(10050.toRupees(), 100.50);
    });
  });
}
