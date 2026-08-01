import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/merchants_table.dart';

part 'merchant_dao.g.dart';

@DriftAccessor(tables: [MerchantsTable])
class MerchantDao extends DatabaseAccessor<AppDatabase> with _$MerchantDaoMixin {
  MerchantDao(super.db);

  Stream<List<Merchant>> watchAll() => select(merchantsTable).watch();

  Future<int> insert(Insertable<Merchant> merchant) => into(merchantsTable).insert(merchant);

  Future<bool> updateMerchant(Insertable<Merchant> merchant) => update(merchantsTable).replace(merchant);

  Future<int> deleteMerchant(Insertable<Merchant> merchant) => delete(merchantsTable).delete(merchant);
}
