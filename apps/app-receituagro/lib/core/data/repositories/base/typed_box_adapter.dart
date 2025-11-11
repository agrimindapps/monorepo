import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

/// Adapter que transforma Box<dynamic> em acesso type-safe
///
/// Este adapter resolve o problema de boxes abertas como dynamic pelo
/// BoxRegistryService mas que precisam ser acessadas de forma type-safe.
///
/// **Uso:**
/// ```dart
/// final adapter = TypedBoxAdapter<ComentarioHive>(dynamicBox);
/// final items = adapter.values.toList(); // Type-safe List<ComentarioHive>
/// ```
///
/// **Por que isso é necessário:**
/// - BoxRegistryService abre boxes persistent como Box<dynamic>
/// - Hive não permite reabrir com tipo diferente
/// - Sem adapter, precisaríamos de cast manual em todo lugar
class TypedBoxAdapter<T extends HiveObject> {
  final Box<dynamic> _dynamicBox;

  TypedBoxAdapter(this._dynamicBox);

  /// Retorna valores filtrados por tipo T
  /// Apenas items que são instância de T são retornados
  Iterable<T> get values {
    return _dynamicBox.values.whereType<T>();
  }

  /// Retorna todas as chaves que contém valores do tipo T
  Iterable<dynamic> get keys {
    final typedKeys = <dynamic>[];
    for (final entry in _dynamicBox.toMap().entries) {
      if (entry.value is T) {
        typedKeys.add(entry.key);
      }
    }
    return typedKeys;
  }

  /// Retorna mapa apenas com entries do tipo T
  Map<dynamic, T> toMap() {
    final map = <dynamic, T>{};
    for (final entry in _dynamicBox.toMap().entries) {
      if (entry.value is T) {
        map[entry.key] = entry.value as T;
      }
    }
    return map;
  }

  /// Get type-safe - retorna null se não for do tipo T
  T? get(dynamic key) {
    final value = _dynamicBox.get(key);
    return value is T ? value : null;
  }

  /// Get com default value
  T getOrDefault(dynamic key, T defaultValue) {
    final value = get(key);
    return value ?? defaultValue;
  }

  /// Put com validação de tipo em compile-time
  Future<void> put(dynamic key, T value) async {
    await _dynamicBox.put(key, value);
  }

  /// Put all - batch operation
  Future<void> putAll(Map<dynamic, T> entries) async {
    await _dynamicBox.putAll(entries);
  }

  /// Delete
  Future<void> delete(dynamic key) async {
    await _dynamicBox.delete(key);
  }

  /// Delete all by keys
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    await _dynamicBox.deleteAll(keys);
  }

  /// Add value (auto-increment key)
  Future<int> add(T value) async {
    return await _dynamicBox.add(value);
  }

  /// Length filtrado - apenas items do tipo T
  int get length {
    return values.length;
  }

  /// Check if contains key with typed value
  bool containsKey(dynamic key) {
    return get(key) != null;
  }

  /// Check if empty (considerando apenas tipo T)
  bool get isEmpty => length == 0;

  /// Check if not empty
  bool get isNotEmpty => length > 0;

  /// Clear apenas items do tipo T
  /// Retorna quantidade de items deletados
  Future<int> clear() async {
    final keysToDelete = keys.toList();
    await _dynamicBox.deleteAll(keysToDelete);
    return keysToDelete.length;
  }

  /// Compact database
  Future<void> compact() async {
    await _dynamicBox.compact();
  }

  /// Flush changes to disk
  Future<void> flush() async {
    await _dynamicBox.flush();
  }

  /// Check if box is open
  bool get isOpen => _dynamicBox.isOpen;

  /// Get box name
  String get name => _dynamicBox.name;

  /// Watch changes (apenas para tipo T)
  Stream<BoxEvent> watch({dynamic key}) {
    return _dynamicBox.watch(key: key).where((event) {
      return event.value is T || event.deleted;
    });
  }

  /// Close box
  Future<void> close() async {
    await _dynamicBox.close();
  }

  /// Debug info
  void logDebugInfo() {
    if (kDebugMode) {
      print('TypedBoxAdapter<$T>:');
      print('  Box name: $name');
      print('  Total items in box: ${_dynamicBox.length}');
      print('  Typed items ($T): $length');
      print('  Is open: $isOpen');
    }
  }
}

/// Repository base que usa TypedBoxAdapter
///
/// Esta classe fornece uma camada type-safe sobre Box<dynamic>,
/// mantendo a mesma interface de BaseHiveRepository mas com
/// compatibilidade para boxes abertas como dynamic.
///
/// **Uso:**
/// ```dart
/// class ComentariosLegacyRepository
///     extends TypedDynamicBoxRepository<ComentarioHive> {
///
///   ComentariosLegacyRepository() : super(
///     hiveManager: GetIt.instance<IHiveManager>(),
///     boxName: 'comentarios',
///   );
///
///   // Métodos específicos...
/// }
/// ```
abstract class TypedDynamicBoxRepository<T extends HiveObject> {
  final IHiveManager hiveManager;
  final String boxName;

  TypedBoxAdapter<T>? _adapter;

  TypedDynamicBoxRepository({required this.hiveManager, required this.boxName});

  /// Obtém adapter type-safe
  Future<TypedBoxAdapter<T>> _getAdapter() async {
    if (_adapter != null && _adapter!.isOpen) {
      return _adapter!;
    }

    final result = await hiveManager.getBox<dynamic>(boxName);
    if (result.isError) {
      throw Exception(
        'Failed to open box "$boxName": ${result.error!.message}',
      );
    }

    _adapter = TypedBoxAdapter<T>(result.data!);

    if (kDebugMode) {
      debugPrint(
        '✅ TypedDynamicBoxRepository<$T>: Adapter criado para box "$boxName"',
      );
    }

    return _adapter!;
  }

  /// Get all items com type safety
  Future<Either<Failure, List<T>>> getAll() async {
    try {
      final adapter = await _getAdapter();
      final items = adapter.values.toList();

      if (kDebugMode) {
        debugPrint(
          'TypedDynamicBoxRepository<$T>.getAll(): Retrieved ${items.length} items',
        );
      }

      return Right(items);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.getAll(): Error - $e');
      }
      return Left(CacheFailure('Failed to get all items: $e'));
    }
  }

  /// Get item by key com type safety
  Future<Either<Failure, T?>> getByKey(dynamic key) async {
    try {
      final adapter = await _getAdapter();
      final item = adapter.get(key);

      if (kDebugMode) {
        debugPrint(
          'TypedDynamicBoxRepository<$T>.getByKey($key): ${item != null ? 'Found' : 'Not found'}',
        );
      }

      return Right(item);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.getByKey($key): Error - $e');
      }
      return Left(CacheFailure('Failed to get item by key: $e'));
    }
  }

  /// Get by multiple keys
  Future<Either<Failure, List<T>>> getByKeys(List<dynamic> keys) async {
    try {
      final adapter = await _getAdapter();
      final items = <T>[];

      for (final key in keys) {
        final item = adapter.get(key);
        if (item != null) {
          items.add(item);
        }
      }

      if (kDebugMode) {
        debugPrint(
          'TypedDynamicBoxRepository<$T>.getByKeys(): '
          'Found ${items.length}/${keys.length} items',
        );
      }

      return Right(items);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.getByKeys(): Error - $e');
      }
      return Left(CacheFailure('Failed to get items by keys: $e'));
    }
  }

  /// Find by predicate
  Future<Either<Failure, List<T>>> findBy(bool Function(T) predicate) async {
    try {
      final allResult = await getAll();

      return allResult.fold((failure) => Left(failure), (items) {
        final filteredItems = items.where(predicate).toList();

        if (kDebugMode) {
          debugPrint(
            'TypedDynamicBoxRepository<$T>.findBy(): '
            'Found ${filteredItems.length} items',
          );
        }

        return Right(filteredItems);
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.findBy(): Error - $e');
      }
      return Left(CacheFailure('Failed to find items: $e'));
    }
  }

  /// Find first by predicate
  Future<Either<Failure, T?>> findFirst(bool Function(T) predicate) async {
    try {
      final findResult = await findBy(predicate);

      return findResult.fold((failure) => Left(failure), (items) {
        final firstItem = items.isNotEmpty ? items.first : null;
        return Right(firstItem);
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.findFirst(): Error - $e');
      }
      return Left(CacheFailure('Failed to find first item: $e'));
    }
  }

  /// Save item
  Future<Either<Failure, void>> save(T item, {dynamic key}) async {
    try {
      final adapter = await _getAdapter();

      if (key != null) {
        await adapter.put(key, item);
      } else {
        // Para HiveObject, usar chave do próprio objeto
        await adapter.put(item.key, item);
      }

      if (kDebugMode) {
        debugPrint(
          'TypedDynamicBoxRepository<$T>.save(): '
          'Item saved with key: ${key ?? item.key}',
        );
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.save(): Error - $e');
      }
      return Left(CacheFailure('Failed to save item: $e'));
    }
  }

  /// Save all items
  Future<Either<Failure, void>> saveAll(Map<dynamic, T> items) async {
    try {
      final adapter = await _getAdapter();
      await adapter.putAll(items);

      if (kDebugMode) {
        debugPrint(
          'TypedDynamicBoxRepository<$T>.saveAll(): '
          'Saved ${items.length} items',
        );
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.saveAll(): Error - $e');
      }
      return Left(CacheFailure('Failed to save all items: $e'));
    }
  }

  /// Delete by key
  Future<Either<Failure, void>> delete(dynamic key) async {
    try {
      final adapter = await _getAdapter();
      await adapter.delete(key);

      if (kDebugMode) {
        debugPrint(
          'TypedDynamicBoxRepository<$T>.delete(): '
          'Item deleted with key: $key',
        );
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.delete($key): Error - $e');
      }
      return Left(CacheFailure('Failed to delete item: $e'));
    }
  }

  /// Delete all by keys
  Future<Either<Failure, void>> deleteAll(List<dynamic> keys) async {
    try {
      final adapter = await _getAdapter();
      await adapter.deleteAll(keys);

      if (kDebugMode) {
        debugPrint(
          'TypedDynamicBoxRepository<$T>.deleteAll(): '
          'Deleted ${keys.length} items',
        );
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.deleteAll(): Error - $e');
      }
      return Left(CacheFailure('Failed to delete all items: $e'));
    }
  }

  /// Clear all items of type T
  Future<Either<Failure, int>> clear() async {
    try {
      final adapter = await _getAdapter();
      final deletedCount = await adapter.clear();

      if (kDebugMode) {
        debugPrint(
          'TypedDynamicBoxRepository<$T>.clear(): '
          'Deleted $deletedCount items',
        );
      }

      return Right(deletedCount);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.clear(): Error - $e');
      }
      return Left(CacheFailure('Failed to clear items: $e'));
    }
  }

  /// Get count
  Future<Either<Failure, int>> count() async {
    try {
      final adapter = await _getAdapter();
      return Right(adapter.length);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.count(): Error - $e');
      }
      return Left(CacheFailure('Failed to count items: $e'));
    }
  }

  /// Check if exists
  Future<Either<Failure, bool>> exists(dynamic key) async {
    try {
      final adapter = await _getAdapter();
      return Right(adapter.containsKey(key));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.exists($key): Error - $e');
      }
      return Left(CacheFailure('Failed to check existence: $e'));
    }
  }

  /// Watch changes
  Stream<BoxEvent> watch({dynamic key}) async* {
    try {
      final adapter = await _getAdapter();
      yield* adapter.watch(key: key);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.watch(): Error - $e');
      }
      rethrow;
    }
  }

  /// Close box
  Future<Either<Failure, void>> close() async {
    try {
      if (_adapter != null && _adapter!.isOpen) {
        await _adapter!.close();
        _adapter = null;
      }
      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TypedDynamicBoxRepository<$T>.close(): Error - $e');
      }
      return Left(CacheFailure('Failed to close box: $e'));
    }
  }
}
