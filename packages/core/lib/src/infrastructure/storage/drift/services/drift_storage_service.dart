import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/i_local_storage_repository.dart';
import '../../shared/utils/failure.dart';

/// DriftStorageService - Implementação simplificada usando tabela key-value
/// 
/// NOTA: Esta é uma implementação de bridge/adapter que usa uma tabela
/// key-value genérica para manter compatibilidade com ILocalStorageRepository.
/// 
/// Para apps com Drift completo, use repositories Drift nativos ao invés
/// desta abstração genérica.
/// 
/// Equivalente Drift do HiveStorageService
class DriftStorageService implements ILocalStorageRepository {
  final GeneratedDatabase _database;
  bool _isInitialized = false;

  /// Nome da tabela key-value padrão
  static const String _defaultTableName = 'key_value_storage';

  DriftStorageService(this._database);

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) return const Right(null);

      // Validar que a database está disponível
      if (_database.executor == null) {
        return const Left(
          CacheFailure('Database executor not initialized'),
        );
      }

      _isInitialized = true;
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao inicializar storage Drift: $e'));
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

      // Serializar data para JSON
      final jsonData = _serializeData(data);

      // Usar customStatement para insert/replace na tabela key-value
      final tableName = box ?? _defaultTableName;

      await _database.customStatement(
        '''
        INSERT OR REPLACE INTO $tableName (key, value, type, updated_at) 
        VALUES (?, ?, ?, ?)
        ''',
        [
          key,
          jsonData,
          T.toString(),
          DateTime.now().millisecondsSinceEpoch,
        ],
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar dados: $e'));
    }
  }

  @override
  Future<Either<Failure, T?>> get<T>({
    required String key,
    String? box,
  }) async {
    try {
      await _ensureInitialized();

      final tableName = box ?? _defaultTableName;

      final result = await _database.customSelect(
        'SELECT value FROM $tableName WHERE key = ?',
        variables: [Variable<String>(key)],
        readsFrom: {}, // Especificar tabelas se necessário
      ).getSingleOrNull();

      if (result == null) return const Right(null);

      final jsonData = result.read<String>('value');
      final data = _deserializeData<T>(jsonData);

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

      final tableName = box ?? _defaultTableName;

      await _database.customStatement(
        'DELETE FROM $tableName WHERE key = ?',
        [key],
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao remover dados: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clear({String? box}) async {
    try {
      await _ensureInitialized();

      final tableName = box ?? _defaultTableName;

      await _database.customStatement('DELETE FROM $tableName');

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

      final tableName = box ?? _defaultTableName;

      final result = await _database.customSelect(
        'SELECT COUNT(*) as count FROM $tableName WHERE key = ?',
        variables: [Variable<String>(key)],
      ).getSingle();

      final count = result.read<int>('count');
      return Right(count > 0);
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar existência: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getKeys({String? box}) async {
    try {
      await _ensureInitialized();

      final tableName = box ?? _defaultTableName;

      final results = await _database.customSelect(
        'SELECT key FROM $tableName',
      ).get();

      final keys = results.map((r) => r.read<String>('key')).toList();
      return Right(keys);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter chaves: $e'));
    }
  }

  @override
  Future<Either<Failure, List<T>>> getValues<T>({String? box}) async {
    try {
      await _ensureInitialized();

      final tableName = box ?? _defaultTableName;

      final results = await _database.customSelect(
        'SELECT value FROM $tableName',
      ).get();

      final values = <T>[];
      for (final result in results) {
        try {
          final jsonData = result.read<String>('value');
          final value = _deserializeData<T>(jsonData);
          if (value != null) {
            values.add(value);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ [DriftStorage] Skipping invalid item: $e');
          }
        }
      }

      return Right(values);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter valores: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> length({String? box}) async {
    try {
      await _ensureInitialized();

      final tableName = box ?? _defaultTableName;

      final result = await _database.customSelect(
        'SELECT COUNT(*) as count FROM $tableName',
      ).getSingle();

      return Right(result.read<int>('count'));
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
      final result = await get<List<dynamic>>(key: key, box: box);

      return result.fold(
        (failure) => Left(failure),
        (data) {
          if (data == null) return const Right([]);
          return Right(data.cast<T>());
        },
      );
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

      return listResult.fold(
        (failure) => Left(failure),
        (currentList) async {
          final updatedList = [...currentList, item];
          return saveList<T>(key: key, data: updatedList, box: box);
        },
      );
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

      return listResult.fold(
        (failure) => Left(failure),
        (currentList) async {
          final updatedList =
              currentList.where((element) => element != item).toList();
          return saveList<T>(key: key, data: updatedList, box: box);
        },
      );
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
      final ttlData = {
        'data': data,
        'expires_at': DateTime.now().add(ttl).millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };

      return save<Map<String, dynamic>>(key: key, data: ttlData, box: box);
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

      return result.fold(
        (failure) => Left(failure),
        (rawData) {
          if (rawData == null) return const Right(null);

          final expiresAt = DateTime.fromMillisecondsSinceEpoch(
            rawData['expires_at'] as int,
          );

          if (DateTime.now().isAfter(expiresAt)) {
            remove(key: key, box: box);
            return const Right(null);
          }

          return Right(rawData['data'] as T);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter dados com TTL: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cleanExpiredData({String? box}) async {
    try {
      await _ensureInitialized();

      final tableName = box ?? _defaultTableName;

      // Obter todas as chaves
      final keysResult = await getKeys(box: box);

      return keysResult.fold(
        (failure) => Left(failure),
        (keys) async {
          for (final key in keys) {
            final result = await get<Map<String, dynamic>>(key: key, box: box);

            result.fold(
              (_) {},
              (data) {
                if (data != null && data.containsKey('expires_at')) {
                  final expiresAt = DateTime.fromMillisecondsSinceEpoch(
                    data['expires_at'] as int,
                  );

                  if (DateTime.now().isAfter(expiresAt)) {
                    remove(key: key, box: box);
                  }
                }
              },
            );
          }

          return const Right(null);
        },
      );
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

      final results = await _database.customSelect(
        'SELECT key, value FROM ${HiveBoxes.settings}',
      ).get();

      final settings = <String, dynamic>{};
      for (final result in results) {
        final key = result.read<String>('key');
        final jsonData = result.read<String>('value');
        settings[key] = _deserializeData<dynamic>(jsonData);
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

      return result.fold(
        (failure) => Left(failure),
        (rawData) {
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
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao obter dados offline: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsSynced({required String key}) async {
    try {
      final dataResult = await getOfflineData<dynamic>(key: key);

      return dataResult.fold(
        (failure) => Left(failure),
        (offlineData) async {
          if (offlineData == null) {
            return const Left(
              CacheFailure('Dados não encontrados para sincronizar'),
            );
          }

          return saveOfflineData<dynamic>(
            key: key,
            data: offlineData.data,
            lastSync: DateTime.now(),
          );
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao marcar como sincronizado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getUnsyncedKeys() async {
    try {
      await _ensureInitialized();

      final results = await _database.customSelect(
        '''
        SELECT key, value 
        FROM ${HiveBoxes.offline}
        ''',
      ).get();

      final unsyncedKeys = <String>[];

      for (final result in results) {
        final jsonData = result.read<String>('value');
        final data = jsonDecode(jsonData) as Map<String, dynamic>;

        final isSynced = data['is_synced'] as bool? ?? false;
        if (!isSynced) {
          unsyncedKeys.add(result.read<String>('key'));
        }
      }

      return Right(unsyncedKeys);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter chaves não sincronizadas: $e'));
    }
  }

  /// Serializa dados para JSON string
  String _serializeData<T>(T data) {
    if (data is String) return data;
    return jsonEncode(data);
  }

  /// Desserializa dados de JSON string
  T? _deserializeData<T>(String jsonData) {
    if (T == String) return jsonData as T;

    try {
      final decoded = jsonDecode(jsonData);

      // Se T é Map<String, dynamic>
      if (T.toString().startsWith('Map<String, dynamic>')) {
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded) as T;
        }
      }

      // Se T é List
      if (T.toString().startsWith('List')) {
        if (decoded is List) {
          return decoded as T;
        }
      }

      return decoded as T;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [DriftStorage] Failed to deserialize: $e');
      }
      return null;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Fecha recursos
  Future<void> dispose() async {
    // Database é gerenciada externamente, não fechar aqui
    _isInitialized = false;
  }
}
