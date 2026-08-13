import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:your_budget_manager/core/errors/app_exception.dart';
import 'package:your_budget_manager/core/security/encryption_service.dart';
import 'package:your_budget_manager/core/widgets/fatal_security_error_app.dart';
import 'package:your_budget_manager/database/app_database.dart';
import 'package:your_budget_manager/database/encryption_migration.dart';
import 'package:your_budget_manager/engines/backup/backup_engine.dart';
import 'package:your_budget_manager/engines/category/category_engine.dart';

class MockSqliteDatabase extends Mock implements sqlite.Database {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late BackupEngine backupEngine;
  const passphrase = 'test_secure_passphrase_123';

  setUpAll(() {
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    backupEngine = BackupEngine(db);

    // Seed existing DB with baseline data to verify it remains untouched on failed restores
    await db.into(db.categoriesTable).insert(
          Category(
            id: CategoryEngine.catFood,
            name: 'Food & Dining',
            icon: 'restaurant',
            color: '#FF5722',
            isDefault: true,
            sortOrder: 0,
            createdAt: 1000,
            updatedAt: 1000,
          ),
          mode: drift.InsertMode.insertOrIgnore,
        );

    await db.into(db.transactionsTable).insert(
          TransactionsTableCompanion.insert(
            id: 'baseline_tx_1',
            amount: 50000,
            type: 'expense',
            categoryId: CategoryEngine.catFood,
            date: 1786000000000,
            note: const drift.Value('Baseline Grocery'),
            createdAt: 1000,
            updatedAt: 1000,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 9: Backup v2 Completeness & Schema Validation', () {
    test('Restore aborts with ValidationException when savings_goals section is missing in v2, leaving DB untouched', () async {
      final incompleteData = {
        'categories': [
          {'id': 'c1', 'name': 'Cat 1', 'icon': 'icon', 'color': '#000', 'isDefault': true, 'sortOrder': 0, 'createdAt': 1000, 'updatedAt': 1000}
        ],
        'merchants': [],
        'budgets': [],
        'recurringTransactions': [],
        // 'savingsGoals' IS MISSING!
        'transactions': [],
      };

      final payload = {
        'formatVersion': 2,
        'appVersion': '1.0.0',
        'exportedAt': DateTime.now().millisecondsSinceEpoch,
        'data': incompleteData,
      };

      final encrypted = EncryptionService.encryptWithPassphrase(jsonEncode(payload), passphrase);

      expect(
        () => backupEngine.importData(encrypted, passphrase),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('missing expected section "savingsGoals" in v2 backup'),
          ),
        ),
      );

      // Verify baseline DB is 100% untouched
      final baselineTxs = await db.select(db.transactionsTable).get();
      expect(baselineTxs.length, equals(1));
      expect(baselineTxs.first.id, equals('baseline_tx_1'));
    });

    test('Restore aborts when categories, budgets, or transactions sections are missing in v2', () async {
      for (final missingSection in ['categories', 'merchants', 'budgets', 'recurringTransactions', 'transactions']) {
        final data = {
          'categories': [],
          'merchants': [],
          'budgets': [],
          'recurringTransactions': [],
          'savingsGoals': [],
          'transactions': [],
        }..remove(missingSection);

        final payload = {
          'formatVersion': 2,
          'appVersion': '1.0.0',
          'exportedAt': DateTime.now().millisecondsSinceEpoch,
          'data': data,
        };

        final encrypted = EncryptionService.encryptWithPassphrase(jsonEncode(payload), passphrase);

        expect(
          () => backupEngine.importData(encrypted, passphrase),
          throwsA(isA<ValidationException>()),
          reason: 'Missing section "$missingSection" must reject restore',
        );

        // Verify baseline DB remains untouched
        final baselineTxs = await db.select(db.transactionsTable).get();
        expect(baselineTxs.length, equals(1));
      }
    });

    test('Restore aborts when any item in a section is structurally malformed', () async {
      final malformedData = {
        'categories': [
          {'id': 'c1', 'name': 'Cat 1', 'icon': 'icon', 'color': '#000', 'isDefault': true, 'sortOrder': 0, 'createdAt': 1000, 'updatedAt': 1000}
        ],
        'merchants': [],
        'budgets': [],
        'recurringTransactions': [],
        'savingsGoals': [],
        'transactions': [
          // Malformed: missing amount, date, and categoryId!
          {'id': 'corrupt_tx_99', 'note': 'Broken transaction'}
        ],
      };

      final payload = {
        'formatVersion': 2,
        'appVersion': '1.0.0',
        'exportedAt': DateTime.now().millisecondsSinceEpoch,
        'data': malformedData,
      };

      final encrypted = EncryptionService.encryptWithPassphrase(jsonEncode(payload), passphrase);

      expect(
        () => backupEngine.importData(encrypted, passphrase),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('schema validation failed'),
          ),
        ),
      );

      // Verify baseline DB remains untouched
      final baselineTxs = await db.select(db.transactionsTable).get();
      expect(baselineTxs.length, equals(1));
    });

    test('Valid v1 backup without savings_goals restores successfully against v1 schema shape', () async {
      final validV1Data = {
        'categories': [
          {'id': 'c_v1', 'name': 'Cat v1', 'icon': 'category', 'color': '#111', 'isDefault': true, 'sortOrder': 0, 'createdAt': 1000, 'updatedAt': 1000}
        ],
        'merchants': [],
        'budgets': [],
        'recurringTransactions': [],
        'transactions': [
          {
            'id': 'tx_v1',
            'amount': 25000,
            'type': 'expense',
            'categoryId': 'c_v1',
            'date': 1786000000000,
            'isRecurring': false,
            'isAutoCaptured': false,
            'createdAt': 1000,
            'updatedAt': 1000,
          }
        ],
        // No savingsGoals in v1 backup
      };

      final payload = {
        'formatVersion': 1,
        'appVersion': '0.9.0',
        'exportedAt': DateTime.now().millisecondsSinceEpoch,
        'data': validV1Data,
      };

      final encrypted = EncryptionService.encryptWithPassphrase(jsonEncode(payload), passphrase);

      // Must succeed without throwing
      await backupEngine.importData(encrypted, passphrase);

      final restoredTxs = await db.select(db.transactionsTable).get();
      expect(restoredTxs.length, equals(1));
      expect(restoredTxs.first.id, equals('tx_v1'));
      expect(restoredTxs.first.amount, equals(25000));
    });
  });

  group('Phase 9: Runtime Database Cipher Verification & Startup Safety', () {
    test('EncryptionMigration.verifyCipherSupport throws SecurityException when cipher is unavailable', () {
      final mockRawDb = MockSqliteDatabase();
      when(() => mockRawDb.select('PRAGMA cipher;')).thenThrow(Exception('no such pragma: cipher'));

      expect(
        () => EncryptionMigration.verifyCipherSupport(mockRawDb, context: 'test execution'),
        throwsA(
          isA<SecurityException>().having(
            (e) => e.message,
            'message',
            contains('SQLite3MultipleCiphers is not active'),
          ),
        ),
      );
    });

    test('EncryptionMigration.hasCipher returns true when PRAGMA cipher returns rows', () {
      final mockRawDb = MockSqliteDatabase();
      final dummyResultSet = sqlite.ResultSet(['cipher', 'version'], null, [
        ['aes256cbc', '1.8.0']
      ]);
      when(() => mockRawDb.select('PRAGMA cipher;')).thenReturn(dummyResultSet);

      expect(EncryptionMigration.hasCipher(mockRawDb), isTrue);
      expect(
        () => EncryptionMigration.verifyCipherSupport(mockRawDb),
        returnsNormally,
      );
    });

    testWidgets('FatalSecurityErrorApp renders blocking security alert and error details', (tester) async {
      await tester.pumpWidget(
        const FatalSecurityErrorApp(
          errorMessage: 'SecurityException: SQLite3MultipleCiphers cipher support is missing',
        ),
      );

      expect(find.text('Security Alert:\nEncryption Unavailable'), findsOneWidget);
      expect(find.textContaining('Your Budget Manager could not verify hardware/database encryption support'), findsOneWidget);
      expect(find.textContaining('SQLite3MultipleCiphers cipher support is missing'), findsOneWidget);
      expect(find.text('Exit Application'), findsOneWidget);
      expect(find.byIcon(Icons.gpp_bad_rounded), findsOneWidget);
    });
  });
}
