import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/engines/sms/data/merchant_patterns.dart';

void main() {
  group('MerchantPattern Tests', () {
    test('detects Swiggy with cat_food', () {
      final pattern = kIndianMerchantPatterns.firstWhere((p) => p.name == 'Swiggy');
      expect(pattern.regex.hasMatch('Rs. 500 paid on Swiggy'), isTrue);
      expect(pattern.categoryId, CategoryEngine.catFood);
    });

    test('detects Zepto & Blinkit with cat_groceries', () {
      final zepto = kIndianMerchantPatterns.firstWhere((p) => p.name == 'Zepto');
      expect(zepto.regex.hasMatch('Paid Rs 250 at Zepto'), isTrue);
      expect(zepto.categoryId, CategoryEngine.catGroceries);

      final blinkit = kIndianMerchantPatterns.firstWhere((p) => p.name == 'Blinkit');
      expect(blinkit.regex.hasMatch('Blinkit order confirmed'), isTrue);
      expect(blinkit.categoryId, CategoryEngine.catGroceries);
    });

    test('detects HDFC, ICICI, SBI, Axis Bank SMS', () {
      final hdfc = kIndianMerchantPatterns.firstWhere((p) => p.name == 'HDFC Bank');
      expect(hdfc.regex.hasMatch('Rs 1200 debited from HDFC Bank A/c'), isTrue);

      final icici = kIndianMerchantPatterns.firstWhere((p) => p.name == 'ICICI Bank');
      expect(icici.regex.hasMatch('ICICI Bank Acct XX123 debited for INR 450'), isTrue);

      final sbi = kIndianMerchantPatterns.firstWhere((p) => p.name == 'SBI Bank');
      expect(sbi.regex.hasMatch('Spent Rs 890 using SBI card'), isTrue);

      final axis = kIndianMerchantPatterns.firstWhere((p) => p.name == 'Axis Bank');
      expect(axis.regex.hasMatch('Axis Bank: INR 350 debited'), isTrue);
    });

    test('detects Paytm, PhonePe, Google Pay UPI SMS', () {
      final paytm = kIndianMerchantPatterns.firstWhere((p) => p.name == 'Paytm');
      expect(paytm.regex.hasMatch('Paid Rs 100 via Paytm'), isTrue);

      final phonepe = kIndianMerchantPatterns.firstWhere((p) => p.name == 'PhonePe');
      expect(phonepe.regex.hasMatch('PhonePe: Sent Rs 500'), isTrue);

      final gpay = kIndianMerchantPatterns.firstWhere((p) => p.name == 'Google Pay');
      expect(gpay.regex.hasMatch('Paid using GPay'), isTrue);
    });
  });
}
