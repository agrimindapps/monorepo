import 'package:drift/drift.dart';
import '../nebulalist_database.dart';
import '../tables/lists_table.dart';

part 'list_dao.g.dart';

/// DAO para operações de listas
@DriftAccessor(tables: [Lists])
class ListDao extends DatabaseAccessor<NebulalistDatabase> with _$ListDaoMixin {
  ListDao(super.db);

  /// Buscar todas as listas
  Future<List<ListRecord>> getAllLists() => select(lists).get();

  /// Buscar lista por ID
  Future<ListRecord?> getListById(String id) =>
      (select(lists)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// Buscar listas favoritas
  Future<List<ListRecord>> getFavoriteLists() =>
      (select(lists)..where((tbl) => tbl.isFavorite.equals(true))).get();

  /// Buscar listas não arquivadas
  Future<List<ListRecord>> getActiveLists() =>
      (select(lists)..where((tbl) => tbl.isArchived.equals(false))).get();

  /// Inserir ou atualizar lista
  Future<int> upsertList(ListsCompanion list) =>
      into(lists).insertOnConflictUpdate(list);

  /// Deletar lista
  Future<int> deleteList(String id) =>
      (delete(lists)..where((tbl) => tbl.id.equals(id))).go();

  /// Atualizar contador de itens
  Future<int> updateItemCount(String id, int count, int completedCount) =>
      (update(lists)..where((tbl) => tbl.id.equals(id))).write(
        ListsCompanion(
          itemCount: Value(count),
          completedCount: Value(completedCount),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Stream de todas as listas
  Stream<List<ListRecord>> watchAllLists() => select(lists).watch();

  /// Stream de listas favoritas
  Stream<List<ListRecord>> watchFavoriteLists() =>
      (select(lists)..where((tbl) => tbl.isFavorite.equals(true))).watch();
}
