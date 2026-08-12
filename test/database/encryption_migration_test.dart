import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:your_budget_manager/database/encryption_migration.dart';

void main() {
  late Directory tempDir;
  late File plaintextFile;
  late File encryptedFile;
  const testKey = 'test_encryption_key_32_bytes_len!';

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ybm_enc_test_');
    plaintextFile = File(p.join(tempDir.path, 'ybm_data.sqlite'));
    encryptedFile = File(p.join(tempDir.path, 'ybm_data_enc.sqlite'));
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  /// Helper to populate a sample plaintext database with typical tables and data.
  void createSamplePlaintextDb(File file) {
    final db = sqlite3.open(file.path);
    db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT,
        icon TEXT,
        color TEXT,
        is_default INTEGER,
        sort_order INTEGER,
        created_at INTEGER,
        updated_at INTEGER
      );
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount INTEGER,
        type TEXT,
        category_id TEXT,
        date INTEGER,
        note TEXT,
        merchant_name TEXT,
        is_recurring INTEGER,
        recurring_id TEXT,
        is_auto_captured INTEGER,
        source_app TEXT,
        created_at INTEGER,
        updated_at INTEGER
      );
      INSERT INTO categories (id, name, icon, color, is_default, sort_order, created_at, updated_at)
      VALUES ('cat_food', 'Food & Dining', 'utensils', '#FF5722', 1, 0, 1000, 1000),
             ('cat_bills', 'Bills & Utilities', 'receipt', '#2196F3', 1, 1, 1000, 1000);
      INSERT INTO transactions (id, amount, type, category_id, date, note, merchant_name, is_recurring, is_auto_captured, source_app, created_at, updated_at)
      VALUES ('tx_1', 45000, 'expense', 'cat_food', 1700000000, 'Lunch', 'Swiggy', 0, 1, 'sms:hdfc', 1700000000, 1700000000),
             ('tx_2', 120000, 'expense', 'cat_bills', 1700001000, 'Electricity', 'Tata Power', 0, 0, 'manual', 1700001000, 1700001000);
    ''');
    db.dispose();
  }

  group('EncryptionMigration', () {
    test('fresh install: does nothing when plaintext file does not exist', () async {
      expect(await plaintextFile.exists(), isFalse);
      expect(await encryptedFile.exists(), isFalse);

      await EncryptionMigration.encryptExistingDatabaseIfNeeded(
        plaintextFile: plaintextFile,
        encryptedFile: encryptedFile,
        key: testKey,
      );

      expect(await encryptedFile.exists(), isFalse);
      expect(await plaintextFile.exists(), isFalse);
    });

    test('already migrated: does nothing when encrypted file already exists', () async {
      await encryptedFile.writeAsString('dummy encrypted content');
      await plaintextFile.writeAsString('dummy plain content');

      await EncryptionMigration.encryptExistingDatabaseIfNeeded(
        plaintextFile: plaintextFile,
        encryptedFile: encryptedFile,
        key: testKey,
      );

      // Plaintext file remains untouched because migration was already flagged as done
      expect(await encryptedFile.exists(), isTrue);
      expect(await plaintextFile.exists(), isTrue);
    });

    test('end-to-end migration: encrypts plaintext DB, preserves rows, deletes original', () async {
      createSamplePlaintextDb(plaintextFile);
      expect(await plaintextFile.exists(), isTrue);
      expect(await encryptedFile.exists(), isFalse);

      await EncryptionMigration.encryptExistingDatabaseIfNeeded(
        plaintextFile: plaintextFile,
        encryptedFile: encryptedFile,
        key: testKey,
      );

      // Plaintext should be deleted, encrypted created
      expect(await plaintextFile.exists(), isFalse);
      expect(await encryptedFile.exists(), isTrue);

      // Open with correct key and verify data
      final db = sqlite3.open(encryptedFile.path);
      db.execute("PRAGMA key = '${EncryptionMigration.escapeSqlString(testKey)}';");

      final catRows = db.select('SELECT * FROM categories ORDER BY id ASC;');
      expect(catRows.length, equals(2));
      expect(catRows[0]['id'], equals('cat_bills'));
      expect(catRows[1]['id'], equals('cat_food'));

      final txRows = db.select('SELECT * FROM transactions ORDER BY id ASC;');
      expect(txRows.length, equals(2));
      expect(txRows[0]['id'], equals('tx_1'));
      expect(txRows[0]['amount'], equals(45000));
      expect(txRows[0]['source_app'], equals('sms:hdfc'));
      expect(txRows[1]['id'], equals('tx_2'));
      expect(txRows[1]['amount'], equals(120000));

      db.dispose();
    });

    test('unkeyed plain SQLite connection CANNOT read the encrypted database file', () async {
      createSamplePlaintextDb(plaintextFile);

      await EncryptionMigration.encryptExistingDatabaseIfNeeded(
        plaintextFile: plaintextFile,
        encryptedFile: encryptedFile,
        key: testKey,
      );

      expect(await encryptedFile.exists(), isTrue);

      // Open encrypted file directly with plain SQLite without setting PRAGMA key
      final unkeyedDb = sqlite3.open(encryptedFile.path);
      try {
        expect(
          () => unkeyedDb.select('SELECT * FROM categories;'),
          throwsA(isA<SqliteException>()),
          reason: 'Plain unkeyed SQLite must fail to read encrypted database pages',
        );
      } finally {
        unkeyedDb.dispose();
      }
    });

    test('mid-migration interruption: cleans up stale .tmp file and successfully migrates on retry', () async {
      createSamplePlaintextDb(plaintextFile);

      // Simulate a previous interrupted attempt by leaving a corrupted .tmp file
      final staleTmp = File('${encryptedFile.path}.tmp');
      await staleTmp.writeAsString('corrupted half-written database snapshot from prior crash');
      expect(await staleTmp.exists(), isTrue);

      await EncryptionMigration.encryptExistingDatabaseIfNeeded(
        plaintextFile: plaintextFile,
        encryptedFile: encryptedFile,
        key: testKey,
      );

      // Stale tmp should have been deleted, plaintext deleted, encrypted successfully created
      expect(await staleTmp.exists(), isFalse);
      expect(await plaintextFile.exists(), isFalse);
      expect(await encryptedFile.exists(), isTrue);

      // Verify data readability with correct key
      final db = sqlite3.open(encryptedFile.path);
      db.execute("PRAGMA key = '${EncryptionMigration.escapeSqlString(testKey)}';");
      final catRows = db.select('SELECT * FROM categories;');
      expect(catRows.length, equals(2));
      db.dispose();
    });
  });
}
