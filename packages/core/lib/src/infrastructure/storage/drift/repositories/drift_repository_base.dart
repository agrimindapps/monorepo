import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../../shared/utils/failure.dart';
import '../interfaces/i_drift_repository.dart';

/// Repositório base para operações Drift
/// Fornece implementação padrão para CRUD operations
///
/// Equivalente Drift do BaseHiveRepository
abstract class DriftRepositoryBase<T extends DataClass, TTable extends Table>
    implements IQueryableDriftRepository<T, TTable> {
  @override
  final GeneratedDatabase database;

  @override
  final String tableName;

  /// Referência à tabela Drift
  final TableInfo<TTable, T> table;

  /// Cache opcional (implementar se necessário)
  final Map<dynamic, T> _cache = {};
  final bool _cacheEnabled;

  DriftRepositoryBase({
    required this.database,
    required this.table,
    bool enableCache = false,
  }) : tableName = table.actualTableName,
       _cacheEnabled = enableCache;

  @override
  bool get isInitialized => true;

  /// Helper para obter a coluna ID (deve ser implementado pelas subclasses)
  GeneratedColumn get idColumn;

  @override
  Future<Either<Failure, int>> insert(Insertable<T> item) async {
    try {
      final id = await database.into(table).insert(item);

      if (_cacheEnabled && id > 0) {
        // Invalidar cache após inserção
        _cache.clear();
      }

      debugPrint('$tableName: Inserted item with id: $id');
      return Right(id);
    } catch (e) {
      debugPrint('$tableName: Failed to insert - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, List<int>>> insertAll(
    List<Insertable<T>> items,
  ) async {
    try {
      final ids = <int>[];

      await database.batch((batch) {
        for (final item in items) {
          batch.insert(table, item);
        }
      });

      if (_cacheEnabled) {
        _cache.clear();
      }

      debugPrint('$tableName: Inserted ${items.length} items');
      return Right(ids);
    } catch (e) {
      debugPrint('$tableName: Failed to insert all - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, int>> update(Insertable<T> item) async {
    try {
      final updated = await database.update(table).replace(item);

      if (_cacheEnabled && updated) {
        _cache.clear();
      }

      debugPrint('$tableName: Updated item');
      return Right(updated ? 1 : 0);
    } catch (e) {
      debugPrint('$tableName: Failed to update - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, int>> updateAll(List<Insertable<T>> items) async {
    try {
      int totalUpdated = 0;

      await database.batch((batch) {
        for (final item in items) {
          batch.update(table, item);
        }
      });

      if (_cacheEnabled) {
        _cache.clear();
      }

      debugPrint('$tableName: Updated ${items.length} items');
      return Right(totalUpdated);
    } catch (e) {
      debugPrint('$tableName: Failed to update all - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, bool>> delete(dynamic id) async {
    try {
      final deleted = await (database.delete(
        table,
      )..where((tbl) => idColumn.equals(id as Object))).go();

      if (_cacheEnabled && deleted > 0) {
        _cache.remove(id);
      }

      debugPrint('$tableName: Deleted item with id: $id');
      return Right(deleted > 0);
    } catch (e) {
      debugPrint('$tableName: Failed to delete - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteAll(List<dynamic> ids) async {
    try {
      final deleted = await (database.delete(
        table,
      )..where((tbl) => idColumn.isIn(ids.cast<Object>()))).go();

      if (_cacheEnabled && deleted > 0) {
        for (final id in ids) {
          _cache.remove(id);
        }
      }

      debugPrint('$tableName: Deleted $deleted items');
      return Right(deleted);
    } catch (e) {
      debugPrint('$tableName: Failed to delete all - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, int>> clear() async {
    try {
      final deleted = await database.delete(table).go();

      if (_cacheEnabled) {
        _cache.clear();
      }

      debugPrint('$tableName: Cleared all items ($deleted deleted)');
      return Right(deleted);
    } catch (e) {
      debugPrint('$tableName: Failed to clear - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, T?>> getById(dynamic id) async {
    try {
      // Check cache first
      if (_cacheEnabled && _cache.containsKey(id)) {
        return Right(_cache[id]);
      }

      final item = await (database.select(
        table,
      )..where((tbl) => idColumn.equals(id as Object))).getSingleOrNull();

      if (_cacheEnabled && item != null) {
        _cache[id] = item;
      }

      return Right(item);
    } catch (e) {
      debugPrint('$tableName: Failed to get by id - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, List<T>>> getAll() async {
    try {
      final items = await database.select(table).get();
      return Right(items);
    } catch (e) {
      debugPrint('$tableName: Failed to get all - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, List<T>>> getPage({
    required int page,
    required int pageSize,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final items = await (database.select(
        table,
      )..limit(pageSize, offset: offset)).get();

      return Right(items);
    } catch (e) {
      debugPrint('$tableName: Failed to get page - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, int>> count() async {
    try {
      final countQuery = database.selectOnly(table)
        ..addColumns([table.$columns.first.count()]);

      final result = await countQuery.getSingle();
      final count = result.read(table.$columns.first.count()) ?? 0;

      return Right(count);
    } catch (e) {
      debugPrint('$tableName: Failed to count - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, bool>> exists(dynamic id) async {
    try {
      final item = await (database.select(
        table,
      )..where((tbl) => idColumn.equals(id as Object))).getSingleOrNull();

      return Right(item != null);
    } catch (e) {
      debugPrint('$tableName: Failed to check exists - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Stream<List<T>> watchAll() {
    return database.select(table).watch();
  }

  @override
  Stream<T?> watchById(dynamic id) {
    return (database.select(
      table,
    )..where((tbl) => idColumn.equals(id as Object))).watchSingleOrNull();
  }

  @override
  Future<Either<Failure, R>> transaction<R>(Future<R> Function() action) async {
    try {
      final result = await database.transaction(() => action());
      return Right(result);
    } catch (e) {
      debugPrint('$tableName: Transaction failed - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
    debugPrint('$tableName: Cache cleared');
  }

  @override
  Future<Either<Failure, List<T>>> query(
    String where, {
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      // Nota: Drift usa typed queries, então este método é mais limitado
      // Prefira usar queries tipadas diretamente
      debugPrint(
        '$tableName: Raw query not fully supported, use typed queries instead',
      );
      return const Left(ServerFailure('Operation failed: \$e'));
    } catch (e) {
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Stream<List<T>> watchQuery(
    String where, {
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) {
    // Retorna stream vazio - use typed queries ao invés
    return const Stream.empty();
  }

  @override
  Future<Either<Failure, int>> countWhere(
    String where, {
    List<dynamic>? whereArgs,
  }) async {
    // Não suportado - use typed queries
    return const Left(ServerFailure('Operation failed: \$e'));
  }

  @override
  Future<Either<Failure, int>> deleteWhere(
    String where, {
    List<dynamic>? whereArgs,
  }) async {
    // Não suportado - use typed queries
    return const Left(ServerFailure('Operation failed: \$e'));
  }

  @override
  Future<Either<Failure, bool>> isEmpty() async {
    try {
      final countResult = await count();
      return countResult.fold(
        (failure) => Left(failure),
        (count) => Right(count == 0),
      );
    } catch (e) {
      debugPrint('$tableName: Failed to check isEmpty - $e');
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getAllIds() async {
    try {
      final query = database.selectOnly(table)..addColumns([idColumn]);

      final results = await query.get();
      final ids = results.map((row) => row.read(idColumn)).toList();

      debugPrint('$tableName: Retrieved ${ids.length} IDs');
      return Right(ids);
    } catch (e) {
      debugPrint('$tableName: Failed to get all IDs - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStatistics() async {
    try {
      final countResult = await count();
      final isEmptyResult = await isEmpty();

      return countResult.fold(
        (failure) => Left(failure),
        (totalItems) => isEmptyResult.fold(
          (failure) => Left(failure),
          (isEmpty) => Right({
            'tableName': tableName,
            'totalItems': totalItems,
            'isEmpty': isEmpty,
            'cacheEnabled': _cacheEnabled,
            'cacheSize': _cache.length,
            'databaseInfo': database.toString(),
          }),
        ),
      );
    } catch (e) {
      debugPrint('$tableName: Failed to get statistics - $e');
      return Left(ServerFailure('Operation failed: $e'));
    }
  }

  @override
  Future<int> countAsync() async {
    try {
      final countResult = await count();
      return countResult.fold((failure) => 0, (count) => count);
    } catch (e) {
      debugPrint('$tableName: Error in countAsync - $e');
      return 0;
    }
  }

  // ==================== Métodos Adicionais (Convenientes) ====================

  @override
  Future<Either<Failure, List<T>>> getByIds(List<dynamic> ids) async {
    try {
      if (ids.isEmpty) {
        return const Right([]);
      }

      final items = await (database.select(
        table,
      )..where((tbl) => idColumn.isIn(ids.cast<Object>()))).get();

      debugPrint(
        '$tableName: Retrieved ${items.length}/${ids.length} items by IDs',
      );
      return Right(items);
    } catch (e) {
      debugPrint('$tableName: Failed to get items by IDs - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, List<T>>> findBy(bool Function(T) predicate) async {
    try {
      final allResult = await getAll();
      return allResult.fold((failure) => Left(failure), (allItems) {
        final filteredItems = allItems.where(predicate).toList();
        debugPrint(
          '$tableName: Found ${filteredItems.length} items matching predicate',
        );
        return Right(filteredItems);
      });
    } catch (e) {
      debugPrint('$tableName: Failed to findBy - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, T?>> findFirst(bool Function(T) predicate) async {
    try {
      final findResult = await findBy(predicate);
      return findResult.fold((failure) => Left(failure), (items) {
        final firstItem = items.isNotEmpty ? items.first : null;
        debugPrint('$tableName: Found first item: ${firstItem != null}');
        return Right(firstItem);
      });
    } catch (e) {
      debugPrint('$tableName: Failed to findFirst - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, int>> upsert(Insertable<T> item) async {
    try {
      // Drift tem insertOnConflictUpdate nativo, mas vamos usar mode
      final id = await database.into(table).insertOnConflictUpdate(item);

      if (_cacheEnabled) {
        _cache.clear();
      }

      debugPrint('$tableName: Upserted item with id: $id');
      return Right(id);
    } catch (e) {
      debugPrint('$tableName: Failed to upsert - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, List<int>>> upsertAll(
    List<Insertable<T>> items,
  ) async {
    try {
      final ids = <int>[];

      await database.batch((batch) {
        for (final item in items) {
          batch.insert(table, item, mode: InsertMode.insertOrReplace);
        }
      });

      if (_cacheEnabled) {
        _cache.clear();
      }

      debugPrint('$tableName: Upserted ${items.length} items');
      return Right(ids);
    } catch (e) {
      debugPrint('$tableName: Failed to upsert all - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, T?>> getByKey(dynamic key) => getById(key);

  @override
  Future<Either<Failure, bool>> containsKey(dynamic key) => exists(key);

  @override
  Future<Either<Failure, int>> countBy(bool Function(T) predicate) async {
    try {
      final findResult = await findBy(predicate);
      return findResult.fold(
        (failure) => Left(failure),
        (items) => Right(items.length),
      );
    } catch (e) {
      debugPrint('$tableName: Failed to countBy - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, List<T>>> findWhere(
    Expression<bool> Function(TTable) where,
  ) async {
    try {
      final query = database.select(table)..where((tbl) => where(tbl));

      final items = await query.get();

      debugPrint('$tableName: Found ${items.length} items with typed where');
      return Right(items);
    } catch (e) {
      debugPrint('$tableName: Failed to findWhere - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }

  @override
  Future<Either<Failure, int>> updateWhere(
    Expression<bool> Function(TTable) where,
    Insertable<T> update,
  ) async {
    try {
      final updated = await (database.update(
        table,
      )..where((tbl) => where(tbl))).write(update);

      if (_cacheEnabled && updated > 0) {
        _cache.clear();
      }

      debugPrint('$tableName: Updated $updated items with typed where');
      return Right(updated);
    } catch (e) {
      debugPrint('$tableName: Failed to updateWhere - $e');
      return const Left(ServerFailure('Operation failed: \$e'));
    }
  }
}
