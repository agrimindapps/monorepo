import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../../shared/utils/app_error.dart';
import '../../../../shared/utils/result.dart';
import '../exceptions/drift_exceptions.dart';
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
  Future<Result<int>> insert(Insertable<T> item) async {
    try {
      final id = await database.into(table).insert(item);

      if (_cacheEnabled && id > 0) {
        // Invalidar cache após inserção
        _cache.clear();
      }

      debugPrint('$tableName: Inserted item with id: $id');
      return Result.success(id);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to insert - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to insert item',
            tableName,
            databaseName: database.toString(),
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<int>>> insertAll(List<Insertable<T>> items) async {
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
      return Result.success(ids);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to insert all - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to insert multiple items',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<int>> update(Insertable<T> item) async {
    try {
      final updated = await database.update(table).replace(item);

      if (_cacheEnabled && updated) {
        _cache.clear();
      }

      debugPrint('$tableName: Updated item');
      return Result.success(updated ? 1 : 0);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to update - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to update item',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<int>> updateAll(List<Insertable<T>> items) async {
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
      return Result.success(totalUpdated);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to update all - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to update multiple items',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> delete(dynamic id) async {
    try {
      final deleted = await (database.delete(
        table,
      )..where((tbl) => idColumn.equals(id as Object))).go();

      if (_cacheEnabled && deleted > 0) {
        _cache.remove(id);
      }

      debugPrint('$tableName: Deleted item with id: $id');
      return Result.success(deleted > 0);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to delete - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to delete item',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<int>> deleteAll(List<dynamic> ids) async {
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
      return Result.success(deleted);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to delete all - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to delete multiple items',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<int>> clear() async {
    try {
      final deleted = await database.delete(table).go();

      if (_cacheEnabled) {
        _cache.clear();
      }

      debugPrint('$tableName: Cleared all items ($deleted deleted)');
      return Result.success(deleted);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to clear - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to clear table',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<T?>> getById(dynamic id) async {
    try {
      // Check cache first
      if (_cacheEnabled && _cache.containsKey(id)) {
        return Result.success(_cache[id]);
      }

      final item = await (database.select(
        table,
      )..where((tbl) => idColumn.equals(id as Object))).getSingleOrNull();

      if (_cacheEnabled && item != null) {
        _cache[id] = item;
      }

      return Result.success(item);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to get by id - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to get item by id',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<T>>> getAll() async {
    try {
      final items = await database.select(table).get();
      return Result.success(items);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to get all - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to get all items',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<T>>> getPage({
    required int page,
    required int pageSize,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final items = await (database.select(
        table,
      )..limit(pageSize, offset: offset)).get();

      return Result.success(items);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to get page - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to get page',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<int>> count() async {
    try {
      final countQuery = database.selectOnly(table)
        ..addColumns([table.$columns.first.count()]);

      final result = await countQuery.getSingle();
      final count = result.read(table.$columns.first.count()) ?? 0;

      return Result.success(count);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to count - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to count items',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> exists(dynamic id) async {
    try {
      final item = await (database.select(
        table,
      )..where((tbl) => idColumn.equals(id as Object))).getSingleOrNull();

      return Result.success(item != null);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to check exists - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to check if item exists',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
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
  Future<Result<R>> transaction<R>(Future<R> Function() action) async {
    try {
      final result = await database.transaction(() => action());
      return Result.success(result);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Transaction failed - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTransactionException(
            'Transaction failed',
            databaseName: database.toString(),
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
    debugPrint('$tableName: Cache cleared');
  }

  @override
  Future<Result<List<T>>> query(
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
      return Result.error(
        AppErrorFactory.fromException(
          DriftQueryException(
            'Raw queries not supported, use typed Drift queries',
            query: where,
            tableName: tableName,
          ),
          null,
        ),
      );
    } catch (e, stackTrace) {
      return Result.error(
        AppErrorFactory.fromException(
          DriftQueryException(
            'Query failed',
            query: where,
            tableName: tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
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
  Future<Result<int>> countWhere(
    String where, {
    List<dynamic>? whereArgs,
  }) async {
    // Não suportado - use typed queries
    return Result.error(
      AppErrorFactory.fromException(
        DriftQueryException(
          'Raw count queries not supported, use typed Drift queries',
          query: where,
          tableName: tableName,
        ),
        null,
      ),
    );
  }

  @override
  Future<Result<int>> deleteWhere(
    String where, {
    List<dynamic>? whereArgs,
  }) async {
    // Não suportado - use typed queries
    return Result.error(
      AppErrorFactory.fromException(
        DriftQueryException(
          'Raw delete queries not supported, use typed Drift queries',
          query: where,
          tableName: tableName,
        ),
        null,
      ),
    );
  }

  @override
  Future<Result<bool>> isEmpty() async {
    try {
      final countResult = await count();
      if (countResult.isError) return Result.error(countResult.error!);

      return Result.success(countResult.data! == 0);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to check isEmpty - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to check if table is empty',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<dynamic>>> getAllIds() async {
    try {
      final query = database.selectOnly(table)..addColumns([idColumn]);

      final results = await query.get();
      final ids = results.map((row) => row.read(idColumn)).toList();

      debugPrint('$tableName: Retrieved ${ids.length} IDs');
      return Result.success(ids);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to get all IDs - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to get all IDs',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getStatistics() async {
    try {
      final countResult = await count();
      if (countResult.isError) return Result.error(countResult.error!);

      final isEmptyResult = await isEmpty();
      if (isEmptyResult.isError) return Result.error(isEmptyResult.error!);

      final stats = {
        'tableName': tableName,
        'totalItems': countResult.data!,
        'isEmpty': isEmptyResult.data!,
        'cacheEnabled': _cacheEnabled,
        'cacheSize': _cache.length,
        'databaseInfo': database.toString(),
      };

      return Result.success(stats);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to get statistics - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to get statistics',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<int> countAsync() async {
    try {
      final countResult = await count();
      return countResult.isSuccess ? countResult.data! : 0;
    } catch (e) {
      debugPrint('$tableName: Error in countAsync - $e');
      return 0;
    }
  }

  // ==================== Métodos Adicionais (Convenientes) ====================

  @override
  Future<Result<List<T>>> getByIds(List<dynamic> ids) async {
    try {
      if (ids.isEmpty) {
        return Result.success([]);
      }

      final items = await (database.select(
        table,
      )..where((tbl) => idColumn.isIn(ids.cast<Object>()))).get();

      debugPrint(
        '$tableName: Retrieved ${items.length}/${ids.length} items by IDs',
      );
      return Result.success(items);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to get items by IDs - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to get items by IDs',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<T>>> findBy(bool Function(T) predicate) async {
    try {
      final allResult = await getAll();
      if (allResult.isError) return allResult;

      final filteredItems = allResult.data!.where(predicate).toList();

      debugPrint(
        '$tableName: Found ${filteredItems.length} items matching predicate',
      );
      return Result.success(filteredItems);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to findBy - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to find items by predicate',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<T?>> findFirst(bool Function(T) predicate) async {
    try {
      final findResult = await findBy(predicate);
      if (findResult.isError) return Result.error(findResult.error!);

      final items = findResult.data!;
      final firstItem = items.isNotEmpty ? items.first : null;

      debugPrint('$tableName: Found first item: ${firstItem != null}');
      return Result.success(firstItem);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to findFirst - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to find first item by predicate',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<int>> upsert(Insertable<T> item) async {
    try {
      // Drift tem insertOnConflictUpdate nativo, mas vamos usar mode
      final id = await database.into(table).insertOnConflictUpdate(item);

      if (_cacheEnabled) {
        _cache.clear();
      }

      debugPrint('$tableName: Upserted item with id: $id');
      return Result.success(id);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to upsert - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to upsert item',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<int>>> upsertAll(List<Insertable<T>> items) async {
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
      return Result.success(ids);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to upsert all - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to upsert multiple items',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<T?>> getByKey(dynamic key) => getById(key);

  @override
  Future<Result<bool>> containsKey(dynamic key) => exists(key);

  @override
  Future<Result<int>> countBy(bool Function(T) predicate) async {
    try {
      final findResult = await findBy(predicate);
      if (findResult.isError) return Result.error(findResult.error!);

      return Result.success(findResult.data!.length);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to countBy - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to count items by predicate',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<T>>> findWhere(
    Expression<bool> Function(TTable) where,
  ) async {
    try {
      final query = database.select(table)..where((tbl) => where(tbl));

      final items = await query.get();

      debugPrint('$tableName: Found ${items.length} items with typed where');
      return Result.success(items);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to findWhere - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to find items with typed where clause',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<int>> updateWhere(
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
      return Result.success(updated);
    } catch (e, stackTrace) {
      debugPrint('$tableName: Failed to updateWhere - $e');
      return Result.error(
        AppErrorFactory.fromException(
          DriftTableException(
            'Failed to update items with typed where clause',
            tableName,
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }
}
