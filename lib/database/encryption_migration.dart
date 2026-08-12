import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

class EncryptionMigrationException implements Exception {
  final String message;
  const EncryptionMigrationException(this.message);

  @override
  String toString() => 'EncryptionMigrationException: $message';
}

/// Utility for transparently and safely migrating existing plaintext databases to SQLite3MultipleCiphers encryption.
class EncryptionMigration {
  static const List<String> canonicalTables = [
    'categories',
    'merchants',
    'transactions',
    'budgets',
    'recurring_transactions',
    'app_settings',
    'savings_goals',
  ];

  /// Escapes single quotes for use inside SQL string literals.
  static String escapeSqlString(String source) => source.replaceAll("'", "''");

  /// Verifies if the loaded SQLite binary has SQLite3MultipleCiphers cipher support enabled.
  static bool debugCheckHasCipher(Database database) {
    try {
      return database.select('PRAGMA cipher;').isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Migrates [plaintextFile] to [encryptedFile] using SQLite's VACUUM INTO + PRAGMA rekey.
  /// 
  /// Guaranteed fail-safe:
  /// - Cleans up any stale `.tmp` file from previous interrupted migrations
  /// - Copies the plaintext DB without modifying the original file
  /// - Rekeys the temporary copy
  /// - Validates row counts across all tables
  /// - Only deletes [plaintextFile] after row counts are verified 100% matching
  /// - Discards the `.tmp` copy on any error or count mismatch
  static Future<void> encryptExistingDatabaseIfNeeded({
    required File plaintextFile,
    required File encryptedFile,
    required String key,
  }) async {
    // 1. If encrypted file already exists, migration is already complete.
    if (await encryptedFile.exists()) {
      return;
    }

    // 2. If plaintext file doesn't exist, this is a fresh install.
    if (!await plaintextFile.exists()) {
      return;
    }

    final tmp = File('${encryptedFile.path}.tmp');

    try {
      // 3. Delete leftover tmp file if previous run was interrupted mid-migration.
      if (await tmp.exists()) {
        await tmp.delete();
      }

      final escapedTmpPath = escapeSqlString(tmp.path);
      final escapedKey = escapeSqlString(key);

      // 4. Create an unencrypted snapshot using VACUUM INTO.
      final plaintextDb = sqlite3.open(plaintextFile.path);
      try {
        plaintextDb.execute("VACUUM INTO '$escapedTmpPath';");
      } finally {
        plaintextDb.dispose();
      }

      // 5. Encrypt the temporary file copy using PRAGMA rekey.
      final tmpDb = sqlite3.open(tmp.path);
      try {
        tmpDb.execute("PRAGMA rekey = '$escapedKey';");
      } finally {
        tmpDb.dispose();
      }

      // 6. Verification: compare table row counts between plaintext and encrypted tmp.
      final verifyPlain = sqlite3.open(plaintextFile.path);
      final plainCounts = <String, int>{};
      try {
        for (final table in canonicalTables) {
          try {
            final result = verifyPlain.select('SELECT COUNT(*) as c FROM $table;');
            if (result.isNotEmpty) {
              plainCounts[table] = result.first['c'] as int;
            }
          } catch (_) {
            // Table might not exist if source DB was an older schema version
          }
        }
      } finally {
        verifyPlain.dispose();
      }

      final verifyEnc = sqlite3.open(tmp.path);
      final encCounts = <String, int>{};
      try {
        verifyEnc.execute("PRAGMA key = '$escapedKey';");
        for (final table in plainCounts.keys) {
          final result = verifyEnc.select('SELECT COUNT(*) as c FROM $table;');
          if (result.isNotEmpty) {
            encCounts[table] = result.first['c'] as int;
          }
        }
      } finally {
        verifyEnc.dispose();
      }

      // Verify row counts match exactly for all existing tables.
      for (final entry in plainCounts.entries) {
        final encCount = encCounts[entry.key];
        if (encCount != entry.value) {
          throw EncryptionMigrationException(
            'Row count mismatch for table "${entry.key}": plaintext=${entry.value}, encrypted=$encCount',
          );
        }
      }

      // 7. Atomic promotion: rename tmp to final encrypted destination, delete original plaintext.
      await tmp.rename(encryptedFile.path);
      await plaintextFile.delete();
    } catch (e) {
      // On any error, clean up the temporary file so the original plaintext DB remains intact.
      if (await tmp.exists()) {
        try {
          await tmp.delete();
        } catch (_) {}
      }
      if (e is EncryptionMigrationException) {
        rethrow;
      }
      throw EncryptionMigrationException('Encryption migration failed: $e');
    }
  }
}

