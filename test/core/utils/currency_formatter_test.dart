import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats correctly with Indian grouping', () {
      expect(CurrencyFormatter.format(123456.78), '₹1,23,456.78');
    });

    test('formats zero correctly', () {
      expect(CurrencyFormatter.format(0), '₹0.00');
    });

    test('formats large amounts correctly', () {
      expect(CurrencyFormatter.format(123456789.12), '₹12,34,56,789.12');
    });

    test('formats negative amounts correctly', () {
      final result = CurrencyFormatter.format(-1234.56);
      expect(result.contains('1,234.56'), true);
      expect(result.contains('-'), true);
    });

    test('formatSigned adds plus for positive amounts', () {
      expect(CurrencyFormatter.formatSigned(1234.56), '+₹1,234.56');
    });
  });
}
