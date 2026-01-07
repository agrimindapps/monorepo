import 'package:core/core.dart';
import 'package:drift/drift.dart';

import '../nebulalist_database.dart';

/// ============================================================================
/// ITEM REPOSITORY - Padrão Nebulalist (String ID)
/// ============================================================================
///
/// Repository de Items para listas.
/// NOTA: Este app usa Text ID (UUID) ao invés de Integer ID.
///
/// **CARACTERÍSTICAS:**
/// - CRUD completo com Result para error handling
/// - Streams reativos
/// - Queries por lista
/// - Ordenação por position
/// ============================================================================

class ItemRepository {
  ItemRepository(this._db);

  final NebulalistDatabase _db;

  String get tableName => 'items';

  // ==================== CREATE ====================

  /// Insere um novo item
  Future<Either<Failure, int>> insert(ItemsCompanion item) async {
    try {
      final rowsAffected = await _db.into(_db.items).insert(item);
      return Right(rowsAffected);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Upsert (insert or update)
  Future<Either<Failure, int>> upsert(ItemsCompanion item) async {
    try {
      final rowsAffected = await _db
          .into(_db.items)
          .insertOnConflictUpdate(item);
      return Right(rowsAffected);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Insere múltiplos itens
  Future<Either<Failure, void>> insertAll(List<ItemsCompanion> items) async {
    try {
      await _db.batch((batch) {
        batch.insertAll(_db.items, items);
      });
      return Right(null);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  // ==================== READ ====================

  /// Busca item por ID
  Future<Either<Failure, ItemRecord?>> getById(String id) async {
    try {
      final result = await (_db.select(
        _db.items,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      return Right(result);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Busca todos os itens de uma lista
  Future<Either<Failure, List<ItemRecord>>> getByListId(String listId) async {
    try {
      final results =
          await (_db.select(_db.items)
                ..where((t) => t.listId.equals(listId))
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get();
      return Right(results);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Busca itens não completados de uma lista
  Future<Either<Failure, List<ItemRecord>>> getPendingItems(
    String listId,
  ) async {
    try {
      final results =
          await (_db.select(_db.items)
                ..where(
                  (t) => t.listId.equals(listId) & t.isCompleted.equals(false),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get();
      return Right(results);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Busca itens completados de uma lista
  Future<Either<Failure, List<ItemRecord>>> getCompletedItems(
    String listId,
  ) async {
    try {
      final results =
          await (_db.select(_db.items)
                ..where(
                  (t) => t.listId.equals(listId) & t.isCompleted.equals(true),
                )
                ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
              .get();
      return Right(results);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  // ==================== STREAMS ====================

  /// Stream de todos os itens de uma lista
  Stream<List<ItemRecord>> watchByListId(String listId) {
    return (_db.select(_db.items)
          ..where((t) => t.listId.equals(listId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .watch();
  }

  /// Stream de itens pendentes
  Stream<List<ItemRecord>> watchPendingItems(String listId) {
    return (_db.select(_db.items)
          ..where((t) => t.listId.equals(listId) & t.isCompleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .watch();
  }

  /// Stream de itens completados
  Stream<List<ItemRecord>> watchCompletedItems(String listId) {
    return (_db.select(_db.items)
          ..where((t) => t.listId.equals(listId) & t.isCompleted.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .watch();
  }

  /// Stream de um item específico
  Stream<ItemRecord?> watchById(String id) {
    return (_db.select(
      _db.items,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  // ==================== UPDATE ====================

  /// Atualiza item
  Future<Either<Failure, int>> update(String id, ItemsCompanion item) async {
    try {
      final updated = await (_db.update(
        _db.items,
      )..where((t) => t.id.equals(id))).write(item);
      return Right(updated);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Toggle completado
  Future<Either<Failure, int>> toggleCompleted(
    String id,
    bool isCompleted,
  ) async {
    try {
      final updated =
          await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
            ItemsCompanion(
              isCompleted: Value(isCompleted),
              completedAt: isCompleted
                  ? Value(DateTime.now())
                  : const Value(null),
              updatedAt: Value(DateTime.now()),
            ),
          );
      return Right(updated);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Atualiza posição do item
  Future<Either<Failure, int>> updatePosition(String id, int position) async {
    try {
      final updated =
          await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
            ItemsCompanion(
              position: Value(position),
              updatedAt: Value(DateTime.now()),
            ),
          );
      return Right(updated);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Atualiza quantidade
  Future<Either<Failure, int>> updateQuantity(String id, int quantity) async {
    try {
      final updated =
          await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
            ItemsCompanion(
              quantity: Value(quantity),
              updatedAt: Value(DateTime.now()),
            ),
          );
      return Right(updated);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Marca todos os itens de uma lista como completados
  Future<Either<Failure, int>> completeAllInList(String listId) async {
    try {
      final updated =
          await (_db.update(_db.items)..where(
                (t) => t.listId.equals(listId) & t.isCompleted.equals(false),
              ))
              .write(
                ItemsCompanion(
                  isCompleted: const Value(true),
                  completedAt: Value(DateTime.now()),
                  updatedAt: Value(DateTime.now()),
                ),
              );
      return Right(updated);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Desmarca todos os itens de uma lista
  Future<Either<Failure, int>> uncompleteAllInList(String listId) async {
    try {
      final updated =
          await (_db.update(_db.items)..where(
                (t) => t.listId.equals(listId) & t.isCompleted.equals(true),
              ))
              .write(
                ItemsCompanion(
                  isCompleted: const Value(false),
                  completedAt: const Value(null),
                  updatedAt: Value(DateTime.now()),
                ),
              );
      return Right(updated);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  // ==================== DELETE ====================

  /// Deleta item
  Future<Either<Failure, int>> delete(String id) async {
    try {
      final deleted = await (_db.delete(
        _db.items,
      )..where((t) => t.id.equals(id))).go();
      return Right(deleted);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Deleta todos os itens de uma lista
  Future<Either<Failure, int>> deleteByListId(String listId) async {
    try {
      final deleted = await (_db.delete(
        _db.items,
      )..where((t) => t.listId.equals(listId))).go();
      return Right(deleted);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Deleta itens completados de uma lista
  Future<Either<Failure, int>> deleteCompletedInList(String listId) async {
    try {
      final deleted =
          await (_db.delete(_db.items)..where(
                (t) => t.listId.equals(listId) & t.isCompleted.equals(true),
              ))
              .go();
      return Right(deleted);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Limpa todos os itens
  Future<Either<Failure, int>> clear() async {
    try {
      final deleted = await _db.delete(_db.items).go();
      return Right(deleted);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  // ==================== CONTADORES ====================

  /// Conta itens de uma lista
  Future<Either<Failure, int>> countByListId(String listId) async {
    try {
      final count = _db.items.id.count();
      final query = _db.selectOnly(_db.items)
        ..addColumns([count])
        ..where(_db.items.listId.equals(listId));

      final result = await query.getSingle();
      return Right(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Conta itens completados de uma lista
  Future<Either<Failure, int>> countCompletedByListId(String listId) async {
    try {
      final count = _db.items.id.count();
      final query = _db.selectOnly(_db.items)
        ..addColumns([count])
        ..where(
          _db.items.listId.equals(listId) & _db.items.isCompleted.equals(true),
        );

      final result = await query.getSingle();
      return Right(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }

  /// Retorna contagens para uma lista (total e completados)
  Future<Either<Failure, ({int total, int completed})>> getCountsForList(
    String listId,
  ) async {
    try {
      final totalResult = await countByListId(listId);
      final completedResult = await countCompletedByListId(listId);

      return totalResult.fold(
        (failure) => Left(failure),
        (total) => completedResult.fold(
          (failure) => Left(failure),
          (completed) => Right((total: total, completed: completed)),
        ),
      );
    } catch (e, stackTrace) {
      return Left(AppErrorFactory.fromException(e, stackTrace).toFailure());
    }
  }
}
