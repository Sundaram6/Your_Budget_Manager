import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/engines/sms/data/merchant_patterns.dart';

void main() {
  group('MerchantPattern Tests', () {
    test('detects Swiggy', () {
      final pattern = kIndianMerchantPatterns.firstWhere((p) => p.name == 'Swiggy');
      expect(pattern.regex.hasMatch('Rs. 500 paid on Swiggy'), isTrue);
      expect(pattern.regex.hasMatch('SWIGGY'), isTrue);
    });

    test('detects Amazon', () {
      final pattern = kIndianMerchantPatterns.firstWhere((p) => p.name == 'Amazon');
      expect(pattern.regex.hasMatch('Paid to Amazon Pay'), isTrue);
    });

    test('detects Zomato', () {
      final pattern = kIndianMerchantPatterns.firstWhere((p) => p.name == 'Zomato');
      expect(pattern.regex.hasMatch('Zomato order'), isTrue);
    });
  });
}
