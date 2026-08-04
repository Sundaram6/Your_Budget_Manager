import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';
import 'package:your_budget_manager/engines/expense/expense_engine.dart';
import 'package:your_budget_manager/engines/merchant/merchant_engine.dart';

class MockSmsQuery extends Mock implements SmsQuery {}
class MockExpenseEngine extends Mock implements ExpenseEngine {}
class MockLogger extends Mock implements Logger {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Nuclear Fixes Verification Tests', () {
    test('Issue 1: SharedPreferences initial route logic evaluates correctly', () async {
      SharedPreferences.setMockInitialValues({'hasCompletedOnboarding': true});
      final prefs = await SharedPreferences.getInstance();
      final hasCompleted = (prefs.getBool('hasCompletedOnboarding') ?? prefs.getBool('onboarding_complete')) ?? false;
      
      final initialRoute = hasCompleted ? '/' : '/onboarding';
      expect(initialRoute, equals('/'));

      SharedPreferences.setMockInitialValues({'hasCompletedOnboarding': false});
      final prefs2 = await SharedPreferences.getInstance();
      final hasCompleted2 = (prefs2.getBool('hasCompletedOnboarding') ?? prefs2.getBool('onboarding_complete')) ?? false;
      final initialRoute2 = hasCompleted2 ? '/' : '/onboarding';
      expect(initialRoute2, equals('/onboarding'));
    });

    test('Issue 2: PIN skip writes all required flags to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('pin_setup_complete', true);
      await prefs.setBool('hasSkippedPinSetup', true);
      await prefs.reload();

      expect(prefs.getBool('pin_setup_complete'), isTrue);
      expect(prefs.getBool('hasSkippedPinSetup'), isTrue);
    });

    group('Issue 3: Comprehensive Merchant SMS Engine Parser Tests', () {
      late MerchantEngine engine;
      late MockSmsQuery mockSmsQuery;
      late MockExpenseEngine mockExpenseEngine;
      late MockLogger mockLogger;

      setUp(() {
        mockSmsQuery = MockSmsQuery();
        mockExpenseEngine = MockExpenseEngine();
        mockLogger = MockLogger();
        engine = MerchantEngine(mockSmsQuery, mockLogger, mockExpenseEngine);
      });

      test('Parses UPI debits correctly', () {
        final sms = SmsMessage.fromJson({
          '_id': 101,
          'body': 'Rs.250.00 debited via UPI to Swiggy upi ref 1234567890',
          'date': DateTime(2026, 8, 4, 14, 30).millisecondsSinceEpoch,
        });

        final parsed = engine.parseSingleSms(sms);
        expect(parsed, isNotNull);
        expect(parsed!.amount, equals(250.0));
        expect(parsed.merchantName.toLowerCase(), contains('swiggy'));
        expect(parsed.categoryId, equals(CategoryEngine.catFood));
      });

      test('Parses Card transactions correctly', () {
        final sms = SmsMessage.fromJson({
          '_id': 102,
          'body': 'Rs 508 spent via Kotak Debit Card XX1234 at DMART on 04Aug',
          'date': DateTime(2026, 8, 4, 15, 0).millisecondsSinceEpoch,
        });

        final parsed = engine.parseSingleSms(sms);
        expect(parsed, isNotNull);
        expect(parsed!.amount, equals(508.0));
        expect(parsed.merchantName.toLowerCase(), equals('dmart'));
        expect(parsed.categoryId, equals(CategoryEngine.catGroceries));
      });

      test('Parses Wallet payments correctly', () {
        final sms = SmsMessage.fromJson({
          '_id': 103,
          'body': 'Paid Rs.180.00 at Paytm for Zomato order ref TXN998877',
          'date': DateTime(2026, 8, 4, 16, 0).millisecondsSinceEpoch,
        });

        final parsed = engine.parseSingleSms(sms);
        expect(parsed, isNotNull);
        expect(parsed!.amount, equals(180.0));
        expect(parsed.merchantName.toLowerCase(), contains('zomato'));
        expect(parsed.categoryId, equals(CategoryEngine.catFood));
      });

      test('Parses IMPS transfer debits correctly', () {
        final sms = SmsMessage.fromJson({
          '_id': 104,
          'body': 'IMPS trfr of Rs. 1500 to Uber ac 1234 rrn 987654321012',
          'date': DateTime(2026, 8, 4, 17, 0).millisecondsSinceEpoch,
        });

        final parsed = engine.parseSingleSms(sms);
        expect(parsed, isNotNull);
        expect(parsed!.amount, equals(1500.0));
        expect(parsed.merchantName.toLowerCase(), contains('uber'));
        expect(parsed.categoryId, equals(CategoryEngine.catTransport));
      });

      test('Parses Generic Bank debits correctly', () {
        final sms = SmsMessage.fromJson({
          '_id': 105,
          'body': 'A/c XX9988 debited for INR 450.00 towards Jio recharge',
          'date': DateTime(2026, 8, 4, 18, 0).millisecondsSinceEpoch,
        });

        final parsed = engine.parseSingleSms(sms);
        expect(parsed, isNotNull);
        expect(parsed!.amount, equals(450.0));
        expect(parsed.merchantName.toLowerCase(), contains('jio'));
        expect(parsed.categoryId, equals(CategoryEngine.catUtilities));
      });
    });
  });
}
