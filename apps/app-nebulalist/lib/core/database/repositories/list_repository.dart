import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../nebulalist_database.dart';
import '../tables/lists_table.dart';

/// ============================================================================
/// LIST REPOSITORY - Padrão DriftRepositoryBase (String ID)
/// ============================================================================
///
/// Repository de Lists usando padrão do core.
/// NOTA: Este app usa Text ID (UUID) ao invés de Integer ID.
///
/// **CARACTERÍSTICAS:**
/// - CRUD completo com Result para error handling
/// - Streams reativos
/// - Queries tipadas type-safe
/// - ID é string (UUID)
/// ============================================================================

class ListRepository {
  ListRepository(this._db);

  final NebulalistDatabase _db;

  String get tableName => 'lists';

  // ==================== CREATE ====================

  /// Insere uma nova lista
  Future<Result<int>> insert(ListsCompanion list) async {
    try {
      final rowsAffected = await _db.into(_db.lists).insert(list);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Upsert (insert or update)
  Future<Result<int>> upsert(ListsCompanion list) async {
    try {
      final rowsAffected =
          await _db.into(_db.lists).insertOnConflictUpdate(list);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== READ ====================

  /// Busca lista por ID
  Future<Result<ListRecord?>> getById(String id) async {
    try {
      final result = await (_db.select(_db.lists)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca todas as listas
  Future<Result<List<ListRecord>>> getAll() async {
    try {
      final results = await _db.select(_db.lists).get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca listas do usuário
  Future<Result<List<ListRecord>>> getByOwner(String ownerId) async {
    try {
      final results = await (_db.select(_db.lists)
            ..where((t) => t.ownerId.equals(ownerId))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca listas ativas (não arquivadas)
  Future<Result<List<ListRecord>>> getActiveLists(String ownerId) async {
    try {
      final results = await (_db.select(_db.lists)
            ..where(
              (t) => t.ownerId.equals(ownerId) & t.isArchived.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca listas favoritas
  Future<Result<List<ListRecord>>> getFavoriteLists(String ownerId) async {
    try {
      final results = await (_db.select(_db.lists)
            ..where(
              (t) => t.ownerId.equals(ownerId) & t.isFavorite.equals(true),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca listas arquivadas
  Future<Result<List<ListRecord>>> getArchivedLists(String ownerId) async {
    try {
      final results = await (_db.select(_db.lists)
            ..where(
              (t) => t.ownerId.equals(ownerId) & t.isArchived.equals(true),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.archivedAt)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== STREAMS ====================

  /// Stream de todas as listas do usuário
  Stream<List<ListRecord>> watchByOwner(String ownerId) {
    return (_db.select(_db.lists)
          ..where((t) => t.ownerId.equals(ownerId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Stream de listas ativas
  Stream<List<ListRecord>> watchActiveLists(String ownerId) {
    return (_db.select(_db.lists)
          ..where(
            (t) => t.ownerId.equals(ownerId) & t.isArchived.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Stream de listas favoritas
  Stream<List<ListRecord>> watchFavoriteLists(String ownerId) {
    return (_db.select(_db.lists)
          ..where(
            (t) => t.ownerId.equals(ownerId) & t.isFavorite.equals(true),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Stream de uma lista específica
  Stream<ListRecord?> watchById(String id) {
    return (_db.select(_db.lists)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  // ==================== UPDATE ====================

  /// Atualiza lista
  Future<Result<int>> update(String id, ListsCompanion list) async {
    try {
      final updated = await (_db.update(_db.lists)
            ..where((t) => t.id.equals(id)))
          .write(list);
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Toggle favorito
  Future<Result<int>> toggleFavorite(String id, bool isFavorite) async {
    try {
      final updated = await (_db.update(_db.lists)
            ..where((t) => t.id.equals(id)))
          .write(
        ListsCompanion(
          isFavorite: Value(isFavorite),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Arquivar lista
  Future<Result<int>> archive(String id) async {
    try {
      final updated = await (_db.update(_db.lists)
            ..where((t) => t.id.equals(id)))
          .write(
        ListsCompanion(
          isArchived: const Value(true),
          archivedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Desarquivar lista
  Future<Result<int>> unarchive(String id) async {
    try {
      final updated = await (_db.update(_db.lists)
            ..where((t) => t.id.equals(id)))
          .write(
        ListsCompanion(
          isArchived: const Value(false),
          archivedAt: const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Atualiza contadores de itens
  Future<Result<int>> updateItemCounts(
    String id,
    int itemCount,
    int completedCount,
  ) async {
    try {
      final updated = await (_db.update(_db.lists)
            ..where((t) => t.id.equals(id)))
          .write(
        ListsCompanion(
          itemCount: Value(itemCount),
          completedCount: Value(completedCount),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== DELETE ====================

  /// Deleta lista
  Future<Result<int>> delete(String id) async {
    try {
      final deleted =
          await (_db.delete(_db.lists)..where((t) => t.id.equals(id))).go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Deleta todas as listas do usuário
  Future<Result<int>> deleteAllByOwner(String ownerId) async {
    try {
      final deleted = await (_db.delete(_db.lists)
            ..where((t) => t.ownerId.equals(ownerId)))
          .go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Limpa todas as listas
  Future<Result<int>> clear() async {
    try {
      final deleted = await _db.delete(_db.lists).go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== CONTADORES ====================

  /// Conta listas do usuário
  Future<Result<int>> countByOwner(String ownerId) async {
    try {
      final count = _db.lists.id.count();
      final query = _db.selectOnly(_db.lists)
        ..addColumns([count])
        ..where(_db.lists.ownerId.equals(ownerId));

      final result = await query.getSingle();
      return Result.success(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Conta listas ativas
  Future<Result<int>> countActiveLists(String ownerId) async {
    try {
      final count = _db.lists.id.count();
      final query = _db.selectOnly(_db.lists)
        ..addColumns([count])
        ..where(
          _db.lists.ownerId.equals(ownerId) &
              _db.lists.isArchived.equals(false),
        );

      final result = await query.getSingle();
      return Result.success(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }
}
