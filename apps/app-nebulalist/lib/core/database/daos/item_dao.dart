import 'package:drift/drift.dart';
import '../nebulalist_database.dart';
import '../tables/items_table.dart';

part 'item_dao.g.dart';

/// DAO para operações de itens
@DriftAccessor(tables: [Items])
class ItemDao extends DatabaseAccessor<NebulalistDatabase> with _$ItemDaoMixin {
  ItemDao(NebulalistDatabase db) : super(db);

  /// Buscar todos os itens de uma lista
  Future<List<ItemRecord>> getItemsByListId(String listId) =>
      (select(items)..where((tbl) => tbl.listId.equals(listId))).get();

  /// Buscar item por ID
  Future<ItemRecord?> getItemById(String id) =>
      (select(items)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// Buscar itens completados de uma lista
  Future<List<ItemRecord>> getCompletedItems(String listId) => (select(items)
        ..where((tbl) => tbl.listId.equals(listId) & tbl.isCompleted.equals(true)))
      .get();

  /// Buscar itens pendentes de uma lista
  Future<List<ItemRecord>> getPendingItems(String listId) => (select(items)
        ..where((tbl) => tbl.listId.equals(listId) & tbl.isCompleted.equals(false)))
      .get();

  /// Inserir ou atualizar item
  Future<int> upsertItem(ItemsCompanion item) =>
      into(items).insertOnConflictUpdate(item);

  /// Deletar item
  Future<int> deleteItem(String id) =>
      (delete(items)..where((tbl) => tbl.id.equals(id))).go();

  /// Deletar todos os itens de uma lista
  Future<int> deleteItemsByListId(String listId) =>
      (delete(items)..where((tbl) => tbl.listId.equals(listId))).go();

  /// Marcar item como completado
  Future<int> markAsCompleted(String id, bool completed) =>
      (update(items)..where((tbl) => tbl.id.equals(id))).write(
        ItemsCompanion(
          isCompleted: Value(completed),
          completedAt: Value(completed ? DateTime.now() : null),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Stream de itens de uma lista
  Stream<List<ItemRecord>> watchItemsByListId(String listId) =>
      (select(items)..where((tbl) => tbl.listId.equals(listId))).watch();
}
