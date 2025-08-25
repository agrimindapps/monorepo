import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../shared/utils/app_error.dart';
import '../../../../shared/utils/result.dart';
import '../exceptions/storage_exceptions.dart';
import '../interfaces/i_hive_manager.dart';
import '../interfaces/i_hive_repository.dart';

/// Implementação base para repositórios Hive
/// Fornece operações CRUD genéricas com error handling robusto
abstract class BaseHiveRepository<T extends HiveObject> implements IHiveRepository<T> {
  final IHiveManager hiveManager;
  
  @override
  final String boxName;

  BaseHiveRepository({
    required this.hiveManager,
    required this.boxName,
  });

  /// Obtém a box associada a este repositório
  Future<Result<Box<T>>> _getBox() async {
    return await hiveManager.getBox<T>(boxName);
  }

  @override
  Future<Result<List<T>>> getAll() async {
    try {
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      final items = box.values.toList();
      
      debugPrint('BaseHiveRepository ($boxName): Retrieved ${items.length} items');
      return Result.success(items);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in getAll - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to get all items from box: $boxName',
            'getAll',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<T?>> getByKey(dynamic key) async {
    try {
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      final item = box.get(key);
      
      debugPrint('BaseHiveRepository ($boxName): Retrieved item with key: $key');
      return Result.success(item);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in getByKey($key) - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to get item with key: $key',
            'getByKey',
            entityId: key?.toString(),
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<T>>> getByKeys(List<dynamic> keys) async {
    try {
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      final items = <T>[];
      
      for (final key in keys) {
        final item = box.get(key);
        if (item != null) {
          items.add(item);
        }
      }
      
      debugPrint('BaseHiveRepository ($boxName): Retrieved ${items.length}/${keys.length} items');
      return Result.success(items);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in getByKeys - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to get items by keys',
            'getByKeys',
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
      
      debugPrint('BaseHiveRepository ($boxName): Found ${filteredItems.length} items matching predicate');
      return Result.success(filteredItems);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in findBy - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to find items by predicate',
            'findBy',
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
      
      debugPrint('BaseHiveRepository ($boxName): Found first item: ${firstItem != null}');
      return Result.success(firstItem);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in findFirst - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to find first item by predicate',
            'findFirst',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> save(T item, {dynamic key}) async {
    try {
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      
      if (key != null) {
        await box.put(key, item);
      } else {
        await box.add(item);
      }
      
      debugPrint('BaseHiveRepository ($boxName): Saved item${key != null ? ' with key: $key' : ''}');
      return Result.success(null);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in save - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to save item',
            'save',
            entityId: key?.toString(),
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveAll(Map<dynamic, T> items) async {
    try {
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      await box.putAll(items);
      
      debugPrint('BaseHiveRepository ($boxName): Saved ${items.length} items');
      return Result.success(null);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in saveAll - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to save ${items.length} items',
            'saveAll',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteByKey(dynamic key) async {
    try {
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      await box.delete(key);
      
      debugPrint('BaseHiveRepository ($boxName): Deleted item with key: $key');
      return Result.success(null);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in deleteByKey($key) - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to delete item with key: $key',
            'deleteByKey',
            entityId: key?.toString(),
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteByKeys(List<dynamic> keys) async {
    try {
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      await box.deleteAll(keys);
      
      debugPrint('BaseHiveRepository ($boxName): Deleted ${keys.length} items');
      return Result.success(null);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in deleteByKeys - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to delete ${keys.length} items',
            'deleteByKeys',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<int>> deleteWhere(bool Function(T) predicate) async {
    try {
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      final keysToDelete = <dynamic>[];
      
      for (final key in box.keys) {
        final item = box.get(key);
        if (item != null && predicate(item)) {
          keysToDelete.add(key);
        }
      }
      
      await box.deleteAll(keysToDelete);
      
      debugPrint('BaseHiveRepository ($boxName): Deleted ${keysToDelete.length} items by predicate');
      return Result.success(keysToDelete.length);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in deleteWhere - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to delete items by predicate',
            'deleteWhere',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      final itemCount = box.length;
      await box.clear();
      
      debugPrint('BaseHiveRepository ($boxName): Cleared $itemCount items');
      return Result.success(null);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in clear - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to clear box: $boxName',
            'clear',
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
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      return Result.success(box.length);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in count - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to count items',
            'count',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<int>> countWhere(bool Function(T) predicate) async {
    try {
      final findResult = await findBy(predicate);
      if (findResult.isError) return Result.error(findResult.error!);

      return Result.success(findResult.data!.length);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in countWhere - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to count items by predicate',
            'countWhere',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<bool>> isEmpty() async {
    final countResult = await count();
    if (countResult.isError) return Result.error(countResult.error!);
    
    return Result.success(countResult.data! == 0);
  }

  @override
  Future<Result<bool>> containsKey(dynamic key) async {
    try {
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      return Result.success(box.containsKey(key));
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in containsKey - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to check if key exists: $key',
            'containsKey',
            entityId: key?.toString(),
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<List<dynamic>>> getAllKeys() async {
    try {
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      return Result.success(box.keys.toList());
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in getAllKeys - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to get all keys',
            'getAllKeys',
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
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      
      final stats = {
        'boxName': boxName,
        'totalItems': box.length,
        'isEmpty': box.isEmpty,
        'isOpen': box.isOpen,
        'path': box.path,
        'keys': box.keys.length,
      };
      
      return Result.success(stats);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in getStatistics - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to get statistics',
            'getStatistics',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> compact() async {
    try {
      final boxResult = await _getBox();
      if (boxResult.isError) return Result.error(boxResult.error!);

      final box = boxResult.data!;
      await box.compact();
      
      debugPrint('BaseHiveRepository ($boxName): Compacted box');
      return Result.success(null);
      
    } catch (e, stackTrace) {
      debugPrint('BaseHiveRepository ($boxName): Error in compact - $e');
      return Result.error(
        AppErrorFactory.fromException(
          HiveCrudException(
            'Failed to compact box: $boxName',
            'compact',
            originalError: e,
            stackTrace: stackTrace,
          ),
          stackTrace,
        ),
      );
    }
  }
}