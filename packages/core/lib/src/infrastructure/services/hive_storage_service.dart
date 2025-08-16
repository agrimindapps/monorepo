import 'package:hive_flutter/hive_flutter.dart';
import 'package:dartz/dartz.dart';
import '../../domain/repositories/i_local_storage_repository.dart';
import '../../shared/utils/failure.dart';

/// Implementação concreta do repositório de storage local usando Hive
class HiveStorageService implements ILocalStorageRepository {
  final Map<String, Box> _openBoxes = {};
  bool _isInitialized = false;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) return const Right(null);

      await Hive.initFlutter();

      // Registrar adapters customizados se necessário
      _registerAdapters();

      // Abrir boxes principais
      await _openBox(HiveBoxes.settings);
      await _openBox(HiveBoxes.cache);
      await _openBox(HiveBoxes.offline);
      await _openBox(HiveBoxes.plantis);
      await _openBox(HiveBoxes.receituagro);

      _isInitialized = true;
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao inicializar storage local: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> save<T>({
    required String key,
    required T data,
    String? box,
  }) async {
    try {
      await _ensureInitialized();
      final targetBox = await _ensureBoxOpen(box ?? HiveBoxes.settings);

      await targetBox.put(key, data);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar dados: $e'));
    }
  }

  @override
  Future<Either<Failure, T?>> get<T>({required String key, String? box}) async {
    try {
      await _ensureInitialized();
      final targetBox = await _ensureBoxOpen(box ?? HiveBoxes.settings);

      final data = targetBox.get(key) as T?;
      return Right(data);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter dados: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> remove({
    required String key,
    String? box,
  }) async {
    try {
      await _ensureInitialized();
      final targetBox = await _ensureBoxOpen(box ?? HiveBoxes.settings);

      await targetBox.delete(key);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao remover dados: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clear({String? box}) async {
    try {
      await _ensureInitialized();
      final targetBox = await _ensureBoxOpen(box ?? HiveBoxes.settings);

      await targetBox.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar dados: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> contains({
    required String key,
    String? box,
  }) async {
    try {
      await _ensureInitialized();
      final targetBox = await _ensureBoxOpen(box ?? HiveBoxes.settings);

      final exists = targetBox.containsKey(key);
      return Right(exists);
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar existência: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getKeys({String? box}) async {
    try {
      await _ensureInitialized();
      final targetBox = await _ensureBoxOpen(box ?? HiveBoxes.settings);

      final keys = targetBox.keys.cast<String>().toList();
      return Right(keys);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter chaves: $e'));
    }
  }

  @override
  Future<Either<Failure, List<T>>> getValues<T>({String? box}) async {
    try {
      await _ensureInitialized();
      final targetBox = await _ensureBoxOpen(box ?? HiveBoxes.settings);

      final values = targetBox.values.cast<T>().toList();
      return Right(values);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter valores: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> length({String? box}) async {
    try {
      await _ensureInitialized();
      final targetBox = await _ensureBoxOpen(box ?? HiveBoxes.settings);

      return Right(targetBox.length);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter tamanho: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveList<T>({
    required String key,
    required List<T> data,
    String? box,
  }) async {
    return save<List<T>>(key: key, data: data, box: box);
  }

  @override
  Future<Either<Failure, List<T>>> getList<T>({
    required String key,
    String? box,
  }) async {
    try {
      final result = await get<List>(key: key, box: box);

      return result.fold((failure) => Left(failure), (data) {
        if (data == null) return const Right([]);
        return Right(data.cast<T>());
      });
    } catch (e) {
      return Left(CacheFailure('Erro ao obter lista: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addToList<T>({
    required String key,
    required T item,
    String? box,
  }) async {
    try {
      final listResult = await getList<T>(key: key, box: box);

      return listResult.fold((failure) => Left(failure), (currentList) async {
        final updatedList = [...currentList, item];
        return saveList<T>(key: key, data: updatedList, box: box);
      });
    } catch (e) {
      return Left(CacheFailure('Erro ao adicionar à lista: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromList<T>({
    required String key,
    required T item,
    String? box,
  }) async {
    try {
      final listResult = await getList<T>(key: key, box: box);

      return listResult.fold((failure) => Left(failure), (currentList) async {
        final updatedList =
            currentList.where((element) => element != item).toList();
        return saveList<T>(key: key, data: updatedList, box: box);
      });
    } catch (e) {
      return Left(CacheFailure('Erro ao remover da lista: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveWithTTL<T>({
    required String key,
    required T data,
    required Duration ttl,
    String? box,
  }) async {
    try {
      final ttlData = TTLData<T>(
        data: data,
        expiresAt: DateTime.now().add(ttl),
        createdAt: DateTime.now(),
      );

      return save<Map<String, dynamic>>(
        key: key,
        data: {
          'data': data,
          'expires_at': ttlData.expiresAt.millisecondsSinceEpoch,
          'created_at': ttlData.createdAt.millisecondsSinceEpoch,
        },
        box: box,
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar com TTL: $e'));
    }
  }

  @override
  Future<Either<Failure, T?>> getWithTTL<T>({
    required String key,
    String? box,
  }) async {
    try {
      final result = await get<Map<String, dynamic>>(key: key, box: box);

      return result.fold((failure) => Left(failure), (rawData) {
        if (rawData == null) return const Right(null);

        final expiresAt = DateTime.fromMillisecondsSinceEpoch(
          rawData['expires_at'] as int,
        );

        if (DateTime.now().isAfter(expiresAt)) {
          // Dados expirados, remover
          remove(key: key, box: box);
          return const Right(null);
        }

        return Right(rawData['data'] as T);
      });
    } catch (e) {
      return Left(CacheFailure('Erro ao obter dados com TTL: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cleanExpiredData({String? box}) async {
    try {
      await _ensureInitialized();
      final targetBox = await _ensureBoxOpen(box ?? HiveBoxes.cache);

      final keysToRemove = <String>[];
      final now = DateTime.now();

      for (final key in targetBox.keys) {
        final value = targetBox.get(key);

        if (value is Map<String, dynamic> && value.containsKey('expires_at')) {
          final expiresAt = DateTime.fromMillisecondsSinceEpoch(
            value['expires_at'] as int,
          );

          if (now.isAfter(expiresAt)) {
            keysToRemove.add(key.toString());
          }
        }
      }

      for (final key in keysToRemove) {
        await targetBox.delete(key);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar dados expirados: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserSetting({
    required String key,
    required dynamic value,
  }) async {
    return save<dynamic>(key: key, data: value, box: HiveBoxes.settings);
  }

  @override
  Future<Either<Failure, T?>> getUserSetting<T>({
    required String key,
    T? defaultValue,
  }) async {
    try {
      final result = await get<T>(key: key, box: HiveBoxes.settings);

      return result.fold(
        (failure) => Left(failure),
        (value) => Right(value ?? defaultValue),
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter configuração: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAllUserSettings() async {
    try {
      await _ensureInitialized();
      final settingsBox = await _ensureBoxOpen(HiveBoxes.settings);

      final settings = <String, dynamic>{};
      for (final key in settingsBox.keys) {
        settings[key.toString()] = settingsBox.get(key);
      }

      return Right(settings);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter todas as configurações: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveOfflineData<T>({
    required String key,
    required T data,
    DateTime? lastSync,
  }) async {
    try {
      final offlineData = {
        'data': data,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'last_sync': lastSync?.millisecondsSinceEpoch,
        'is_synced': lastSync != null,
      };

      return save<Map<String, dynamic>>(
        key: key,
        data: offlineData,
        box: HiveBoxes.offline,
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar dados offline: $e'));
    }
  }

  @override
  Future<Either<Failure, OfflineData<T>?>> getOfflineData<T>({
    required String key,
  }) async {
    try {
      final result = await get<Map<String, dynamic>>(
        key: key,
        box: HiveBoxes.offline,
      );

      return result.fold((failure) => Left(failure), (rawData) {
        if (rawData == null) return const Right(null);

        final createdAt = DateTime.fromMillisecondsSinceEpoch(
          rawData['created_at'] as int,
        );

        DateTime? lastSync;
        if (rawData['last_sync'] != null) {
          lastSync = DateTime.fromMillisecondsSinceEpoch(
            rawData['last_sync'] as int,
          );
        }

        final offlineData = OfflineData<T>(
          data: rawData['data'] as T,
          createdAt: createdAt,
          lastSync: lastSync,
          isSynced: rawData['is_synced'] as bool? ?? false,
        );

        return Right(offlineData);
      });
    } catch (e) {
      return Left(CacheFailure('Erro ao obter dados offline: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced({required String key}) async {
    try {
      final dataResult = await getOfflineData<dynamic>(key: key);

      return dataResult.fold((failure) => Left(failure), (offlineData) async {
        if (offlineData == null) {
          return Left(CacheFailure('Dados não encontrados para sincronizar'));
        }

        return saveOfflineData<dynamic>(
          key: key,
          data: offlineData.data,
          lastSync: DateTime.now(),
        );
      });
    } catch (e) {
      return Left(CacheFailure('Erro ao marcar como sincronizado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getUnsyncedKeys() async {
    try {
      await _ensureInitialized();
      final offlineBox = await _ensureBoxOpen(HiveBoxes.offline);

      final unsyncedKeys = <String>[];

      for (final key in offlineBox.keys) {
        final value = offlineBox.get(key);

        if (value is Map<String, dynamic>) {
          final isSynced = value['is_synced'] as bool? ?? false;
          if (!isSynced) {
            unsyncedKeys.add(key.toString());
          }
        }
      }

      return Right(unsyncedKeys);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter chaves não sincronizadas: $e'));
    }
  }

  /// Registra adapters customizados para tipos específicos
  void _registerAdapters() {
    // TODO: Registrar adapters para tipos customizados se necessário
    // Exemplo: Hive.registerAdapter(UserEntityAdapter());
  }

  /// Abre uma box específica
  Future<Box> _openBox(String boxName) async {
    if (_openBoxes.containsKey(boxName)) {
      return _openBoxes[boxName]!;
    }

    final box = await Hive.openBox(boxName);
    _openBoxes[boxName] = box;
    return box;
  }

  /// Garante que uma box está aberta
  Future<Box> _ensureBoxOpen(String boxName) async {
    if (_openBoxes.containsKey(boxName)) {
      return _openBoxes[boxName]!;
    }

    return _openBox(boxName);
  }

  /// Garante que o Hive está inicializado
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Fecha todas as boxes e limpa o cache
  Future<void> dispose() async {
    for (final box in _openBoxes.values) {
      await box.close();
    }
    _openBoxes.clear();
    _isInitialized = false;
  }
}
