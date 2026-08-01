import 'package:flutter_test/flutter_test.dart';
import 'package:your_budget_manager/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('required', () {
      test('returns error when null', () {
        expect(Validators.required(null), isNotNull);
      });
      test('returns error when empty', () {
        expect(Validators.required(''), isNotNull);
        expect(Validators.required('   '), isNotNull);
      });
      test('returns null when valid', () {
        expect(Validators.required('value'), isNull);
      });
    });

    group('amount', () {
      test('returns error when null or empty', () {
        expect(Validators.amount(null), isNotNull);
        expect(Validators.amount(''), isNotNull);
      });
      test('returns error when not a number', () {
        expect(Validators.amount('abc'), isNotNull);
      });
      test('returns error when <= 0', () {
        expect(Validators.amount('0'), isNotNull);
        expect(Validators.amount('-10'), isNotNull);
      });
      test('returns null when valid positive amount', () {
        expect(Validators.amount('10.5'), isNull);
        expect(Validators.amount('100'), isNull);
      });
    });

    group('pin', () {
      test('returns error when null or empty', () {
        expect(Validators.pin(null), isNotNull);
        expect(Validators.pin(''), isNotNull);
      });
      test('returns error when not 4 or 6 digits', () {
        expect(Validators.pin('123'), isNotNull);
        expect(Validators.pin('12345'), isNotNull);
        expect(Validators.pin('1234567'), isNotNull);
      });
      test('returns error when not numeric', () {
        expect(Validators.pin('12a4'), isNotNull);
      });
      test('returns null when valid', () {
        expect(Validators.pin('1234'), isNull);
        expect(Validators.pin('123456'), isNull);
      });
    });

    group('passphrase', () {
      test('returns error when null or empty', () {
        expect(Validators.passphrase(null), isNotNull);
        expect(Validators.passphrase(''), isNotNull);
      });
      test('returns error when length < 8', () {
        expect(Validators.passphrase('1234567'), isNotNull);
      });
      test('returns null when length >= 8', () {
        expect(Validators.passphrase('12345678'), isNull);
      });
    });
  });
}
