import 'package:drift/drift.dart';
import '../petiveti_database.dart';
import '../tables/promo_content_table.dart';

part 'promo_dao.g.dart';

@DriftAccessor(tables: [PromoContent])
class PromoDao extends DatabaseAccessor<PetivetiDatabase> with _$PromoDaoMixin {
  PromoDao(super.db);

  /// Get all active promo content
  Future<List<PromoContentEntry>> getActivePromos() {
    final now = DateTime.now();
    return (select(promoContent)
      ..where((tbl) => 
        tbl.isActive.equals(true) &
        tbl.isDeleted.equals(false) &
        (tbl.expiryDate.isNull() | tbl.expiryDate.isBiggerOrEqualValue(now)))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
  }

  /// Watch active promos
  Stream<List<PromoContentEntry>> watchActivePromos() {
    final now = DateTime.now();
    return (select(promoContent)
      ..where((tbl) => 
        tbl.isActive.equals(true) &
        tbl.isDeleted.equals(false) &
        (tbl.expiryDate.isNull() | tbl.expiryDate.isBiggerOrEqualValue(now)))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();
  }

  /// Get promo by ID
  Future<PromoContentEntry?> getPromoById(int id) {
    return (select(promoContent)
      ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
      .getSingleOrNull();
  }

  /// Create promo
  Future<int> createPromo(PromoContentCompanion promo) {
    return into(promoContent).insert(promo);
  }

  /// Update promo
  Future<bool> updatePromo(int id, PromoContentCompanion promo) async {
    final count = await (update(promoContent)..where((tbl) => tbl.id.equals(id))).write(promo);
    return count > 0;
  }

  /// Delete promo
  Future<bool> deletePromo(int id) async {
    final count = await (update(promoContent)..where((tbl) => tbl.id.equals(id)))
      .write(const PromoContentCompanion(isDeleted: Value(true)));
    return count > 0;
  }
}
