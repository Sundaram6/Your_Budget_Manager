import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettingsTable])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<AppSetting?> getValue(String key) {
    return (select(appSettingsTable)..where((t) => t.key.equals(key))).getSingleOrNull();
  }

  Stream<AppSetting?> watchValue(String key) {
    return (select(appSettingsTable)..where((t) => t.key.equals(key))).watchSingleOrNull();
  }

  Future<int> setValue(String key, String value) {
    return into(appSettingsTable).insert(
      AppSettingsTableCompanion(key: Value(key), value: Value(value)),
      mode: InsertMode.insertOrReplace,
    );
  }
}
