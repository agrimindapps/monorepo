import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../nebulalist_database.dart';

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
  Future<Either<Failure, int>> insert(ListsCompanion list) async {
    try {
      final rowsAffected = await _db.into(_db.lists).insert(list);
      return Right(rowsAffected);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Upsert (insert or update)
  Future<Either<Failure, int>> upsert(ListsCompanion list) async {
    try {
      final rowsAffected =
          await _db.into(_db.lists).insertOnConflictUpdate(list);
      return Right(rowsAffected);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  // ==================== READ ====================

  /// Busca lista por ID
  Future<Either<Failure, ListRecord?>> getById(String id) async {
    try {
      final result = await (_db.select(_db.lists)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Right(result);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Busca todas as listas
  Future<Either<Failure, List<ListRecord>>> getAll() async {
    try {
      final results = await _db.select(_db.lists).get();
      return Right(results);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Busca listas do usuário
  Future<Either<Failure, List<ListRecord>>> getByOwner(String ownerId) async {
    try {
      final results = await (_db.select(_db.lists)
            ..where((t) => t.ownerId.equals(ownerId))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();
      return Right(results);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Busca listas ativas (não arquivadas)
  Future<Either<Failure, List<ListRecord>>> getActiveLists(String ownerId) async {
    try {
      final results = await (_db.select(_db.lists)
            ..where(
              (t) => t.ownerId.equals(ownerId) & t.isArchived.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();
      return Right(results);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Busca listas favoritas
  Future<Either<Failure, List<ListRecord>>> getFavoriteLists(String ownerId) async {
    try {
      final results = await (_db.select(_db.lists)
            ..where(
              (t) => t.ownerId.equals(ownerId) & t.isFavorite.equals(true),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();
      return Right(results);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Busca listas arquivadas
  Future<Either<Failure, List<ListRecord>>> getArchivedLists(String ownerId) async {
    try {
      final results = await (_db.select(_db.lists)
            ..where(
              (t) => t.ownerId.equals(ownerId) & t.isArchived.equals(true),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.archivedAt)]))
          .get();
      return Right(results);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
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
  Future<Either<Failure, int>> update(String id, ListsCompanion list) async {
    try {
      final updated = await (_db.update(_db.lists)
            ..where((t) => t.id.equals(id)))
          .write(list);
      return Right(updated);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Toggle favorito
  Future<Either<Failure, int>> toggleFavorite(String id, bool isFavorite) async {
    try {
      final updated = await (_db.update(_db.lists)
            ..where((t) => t.id.equals(id)))
          .write(
        ListsCompanion(
          isFavorite: Value(isFavorite),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Right(updated);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Arquivar lista
  Future<Either<Failure, int>> archive(String id) async {
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
      return Right(updated);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Desarquivar lista
  Future<Either<Failure, int>> unarchive(String id) async {
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
      return Right(updated);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Atualiza contadores de itens
  Future<Either<Failure, int>> updateItemCounts(
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
      return Right(updated);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  // ==================== DELETE ====================

  /// Deleta lista
  Future<Either<Failure, int>> delete(String id) async {
    try {
      final deleted =
          await (_db.delete(_db.lists)..where((t) => t.id.equals(id))).go();
      return Right(deleted);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Deleta todas as listas do usuário
  Future<Either<Failure, int>> deleteAllByOwner(String ownerId) async {
    try {
      final deleted = await (_db.delete(_db.lists)
            ..where((t) => t.ownerId.equals(ownerId)))
          .go();
      return Right(deleted);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Limpa todas as listas
  Future<Either<Failure, int>> clear() async {
    try {
      final deleted = await _db.delete(_db.lists).go();
      return Right(deleted);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  // ==================== CONTADORES ====================

  /// Conta listas do usuário
  Future<Either<Failure, int>> countByOwner(String ownerId) async {
    try {
      final count = _db.lists.id.count();
      final query = _db.selectOnly(_db.lists)
        ..addColumns([count])
        ..where(_db.lists.ownerId.equals(ownerId));

      final result = await query.getSingle();
      return Right(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Conta listas ativas
  Future<Either<Failure, int>> countActiveLists(String ownerId) async {
    try {
      final count = _db.lists.id.count();
      final query = _db.selectOnly(_db.lists)
        ..addColumns([count])
        ..where(
          _db.lists.ownerId.equals(ownerId) &
              _db.lists.isArchived.equals(false),
        );

      final result = await query.getSingle();
      return Right(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }
}
