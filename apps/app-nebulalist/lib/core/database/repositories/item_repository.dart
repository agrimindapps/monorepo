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
  Future<Result<int>> insert(ItemsCompanion item) async {
    try {
      final rowsAffected = await _db.into(_db.items).insert(item);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Upsert (insert or update)
  Future<Result<int>> upsert(ItemsCompanion item) async {
    try {
      final rowsAffected =
          await _db.into(_db.items).insertOnConflictUpdate(item);
      return Result.success(rowsAffected);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Insere múltiplos itens
  Future<Result<void>> insertAll(List<ItemsCompanion> items) async {
    try {
      await _db.batch((batch) {
        batch.insertAll(_db.items, items);
      });
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== READ ====================

  /// Busca item por ID
  Future<Result<ItemRecord?>> getById(String id) async {
    try {
      final result = await (_db.select(_db.items)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca todos os itens de uma lista
  Future<Result<List<ItemRecord>>> getByListId(String listId) async {
    try {
      final results = await (_db.select(_db.items)
            ..where((t) => t.listId.equals(listId))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca itens não completados de uma lista
  Future<Result<List<ItemRecord>>> getPendingItems(String listId) async {
    try {
      final results = await (_db.select(_db.items)
            ..where(
              (t) => t.listId.equals(listId) & t.isCompleted.equals(false),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Busca itens completados de uma lista
  Future<Result<List<ItemRecord>>> getCompletedItems(String listId) async {
    try {
      final results = await (_db.select(_db.items)
            ..where(
              (t) => t.listId.equals(listId) & t.isCompleted.equals(true),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
          .get();
      return Result.success(results);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
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
          ..where(
            (t) => t.listId.equals(listId) & t.isCompleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .watch();
  }

  /// Stream de itens completados
  Stream<List<ItemRecord>> watchCompletedItems(String listId) {
    return (_db.select(_db.items)
          ..where(
            (t) => t.listId.equals(listId) & t.isCompleted.equals(true),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .watch();
  }

  /// Stream de um item específico
  Stream<ItemRecord?> watchById(String id) {
    return (_db.select(_db.items)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  // ==================== UPDATE ====================

  /// Atualiza item
  Future<Result<int>> update(String id, ItemsCompanion item) async {
    try {
      final updated = await (_db.update(_db.items)
            ..where((t) => t.id.equals(id)))
          .write(item);
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Toggle completado
  Future<Result<int>> toggleCompleted(String id, bool isCompleted) async {
    try {
      final updated = await (_db.update(_db.items)
            ..where((t) => t.id.equals(id)))
          .write(
        ItemsCompanion(
          isCompleted: Value(isCompleted),
          completedAt: isCompleted ? Value(DateTime.now()) : const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Atualiza posição do item
  Future<Result<int>> updatePosition(String id, int position) async {
    try {
      final updated = await (_db.update(_db.items)
            ..where((t) => t.id.equals(id)))
          .write(
        ItemsCompanion(
          position: Value(position),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Atualiza quantidade
  Future<Result<int>> updateQuantity(String id, int quantity) async {
    try {
      final updated = await (_db.update(_db.items)
            ..where((t) => t.id.equals(id)))
          .write(
        ItemsCompanion(
          quantity: Value(quantity),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Marca todos os itens de uma lista como completados
  Future<Result<int>> completeAllInList(String listId) async {
    try {
      final updated = await (_db.update(_db.items)
            ..where(
              (t) => t.listId.equals(listId) & t.isCompleted.equals(false),
            ))
          .write(
        ItemsCompanion(
          isCompleted: const Value(true),
          completedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Desmarca todos os itens de uma lista
  Future<Result<int>> uncompleteAllInList(String listId) async {
    try {
      final updated = await (_db.update(_db.items)
            ..where(
              (t) => t.listId.equals(listId) & t.isCompleted.equals(true),
            ))
          .write(
        ItemsCompanion(
          isCompleted: const Value(false),
          completedAt: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return Result.success(updated);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== DELETE ====================

  /// Deleta item
  Future<Result<int>> delete(String id) async {
    try {
      final deleted =
          await (_db.delete(_db.items)..where((t) => t.id.equals(id))).go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Deleta todos os itens de uma lista
  Future<Result<int>> deleteByListId(String listId) async {
    try {
      final deleted = await (_db.delete(_db.items)
            ..where((t) => t.listId.equals(listId)))
          .go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Deleta itens completados de uma lista
  Future<Result<int>> deleteCompletedInList(String listId) async {
    try {
      final deleted = await (_db.delete(_db.items)
            ..where(
              (t) => t.listId.equals(listId) & t.isCompleted.equals(true),
            ))
          .go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Limpa todos os itens
  Future<Result<int>> clear() async {
    try {
      final deleted = await _db.delete(_db.items).go();
      return Result.success(deleted);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  // ==================== CONTADORES ====================

  /// Conta itens de uma lista
  Future<Result<int>> countByListId(String listId) async {
    try {
      final count = _db.items.id.count();
      final query = _db.selectOnly(_db.items)
        ..addColumns([count])
        ..where(_db.items.listId.equals(listId));

      final result = await query.getSingle();
      return Result.success(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Conta itens completados de uma lista
  Future<Result<int>> countCompletedByListId(String listId) async {
    try {
      final count = _db.items.id.count();
      final query = _db.selectOnly(_db.items)
        ..addColumns([count])
        ..where(
          _db.items.listId.equals(listId) & _db.items.isCompleted.equals(true),
        );

      final result = await query.getSingle();
      return Result.success(result.read(count) ?? 0);
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }

  /// Retorna contagens para uma lista (total e completados)
  Future<Result<({int total, int completed})>> getCountsForList(
    String listId,
  ) async {
    try {
      final totalResult = await countByListId(listId);
      if (totalResult.isError) return Result.error(totalResult.error!);

      final completedResult = await countCompletedByListId(listId);
      if (completedResult.isError) return Result.error(completedResult.error!);

      return Result.success((
        total: totalResult.data!,
        completed: completedResult.data!,
      ));
    } catch (e, stackTrace) {
      return Result.error(AppErrorFactory.fromException(e, stackTrace));
    }
  }
}
