// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_dao.dart';

// ignore_for_file: type=lint
mixin _$MerchantDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTableTable get categoriesTable => attachedDatabase.categoriesTable;
  $MerchantsTableTable get merchantsTable => attachedDatabase.merchantsTable;
  MerchantDaoManager get managers => MerchantDaoManager(this);
}

class MerchantDaoManager {
  final _$MerchantDaoMixin _db;
  MerchantDaoManager(this._db);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(
        _db.attachedDatabase,
        _db.categoriesTable,
      );
  $$MerchantsTableTableTableManager get merchantsTable =>
      $$MerchantsTableTableTableManager(
        _db.attachedDatabase,
        _db.merchantsTable,
      );
}
