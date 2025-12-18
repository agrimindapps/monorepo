import 'package:drift/drift.dart';
import '../nebulalist_database.dart';
import '../tables/item_masters_table.dart';

part 'item_master_dao.g.dart';

/// DAO para operações de ItemMasters
@DriftAccessor(tables: [ItemMasters])
class ItemMasterDao extends DatabaseAccessor<NebulalistDatabase>
    with _$ItemMasterDaoMixin {
  ItemMasterDao(super.db);

  /// Buscar todos os item masters
  Future<List<ItemMasterRecord>> getAllItemMasters() =>
      select(itemMasters).get();

  /// Buscar item masters por owner
  Future<List<ItemMasterRecord>> getItemMastersByOwner(String ownerId) =>
      (select(itemMasters)..where((tbl) => tbl.ownerId.equals(ownerId))).get();

  /// Buscar item master por ID
  Future<ItemMasterRecord?> getItemMasterById(String id) =>
      (select(itemMasters)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// Buscar item masters por categoria
  Future<List<ItemMasterRecord>> getItemMastersByCategory(
    String ownerId,
    String category,
  ) =>
      (select(itemMasters)
            ..where(
              (tbl) =>
                  tbl.ownerId.equals(ownerId) & tbl.category.equals(category),
            ))
          .get();

  /// Inserir ou atualizar item master
  Future<int> upsertItemMaster(ItemMastersCompanion itemMaster) =>
      into(itemMasters).insertOnConflictUpdate(itemMaster);

  /// Deletar item master
  Future<int> deleteItemMaster(String id) =>
      (delete(itemMasters)..where((tbl) => tbl.id.equals(id))).go();

  /// Atualizar contador de uso
  Future<int> incrementUsageCount(String id) async {
    final item = await getItemMasterById(id);
    if (item == null) return 0;

    return (update(itemMasters)..where((tbl) => tbl.id.equals(id))).write(
      ItemMastersCompanion(
        usageCount: Value(item.usageCount + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Stream de todos os item masters de um owner
  Stream<List<ItemMasterRecord>> watchItemMastersByOwner(String ownerId) =>
      (select(itemMasters)..where((tbl) => tbl.ownerId.equals(ownerId))).watch();

  /// Contar item masters de um owner
  Future<int> countItemMastersByOwner(String ownerId) async {
    final count = itemMasters.id.count();
    final query = selectOnly(itemMasters)
      ..addColumns([count])
      ..where(itemMasters.ownerId.equals(ownerId));

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Pesquisar item masters por nome
  Future<List<ItemMasterRecord>> searchItemMasters(
    String ownerId,
    String query,
  ) =>
      (select(itemMasters)
            ..where(
              (tbl) =>
                  tbl.ownerId.equals(ownerId) &
                  tbl.name.lower().like('%${query.toLowerCase()}%'),
            ))
          .get();

  /// Deletar todos os item masters de um owner
  Future<int> deleteItemMastersByOwner(String ownerId) =>
      (delete(itemMasters)..where((tbl) => tbl.ownerId.equals(ownerId))).go();
}
