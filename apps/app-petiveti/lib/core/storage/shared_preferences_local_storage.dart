import 'dart:convert';

import 'package:core/core.dart';

/// Adapter for SharedPreferences to implement ILocalStorageRepository
class PetivetiSharedPreferencesLocalStorage implements ILocalStorageRepository {
  final SharedPreferences _prefs;

  PetivetiSharedPreferencesLocalStorage(this._prefs);

  @override
  Future<Either<Failure, void>> initialize() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> save<T>({
    required String key,
    required T data,
    String? box,
  }) async {
    try {
      if (data is String) {
        await _prefs.setString(key, data);
      } else if (data is bool) {
        await _prefs.setBool(key, data);
      } else if (data is int) {
        await _prefs.setInt(key, data);
      } else if (data is double) {
        await _prefs.setDouble(key, data);
      } else if (data is List<String>) {
        await _prefs.setStringList(key, data);
      } else {
        // Try JSON encoding for other types
        try {
          await _prefs.setString(key, jsonEncode(data));
        } catch (e) {
          return Left(CacheFailure('Unsupported type for key $key: ${data.runtimeType}'));
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, T?>> get<T>({
    required String key,
    String? box,
  }) async {
    try {
      final value = _prefs.get(key);
      if (value == null) return const Right(null);
      
      if (value is T) return Right(value as T);
      
      // Try JSON decoding if we expect a Map or List but got String
      if (value is String && (T.toString().contains('Map') || T.toString().contains('List'))) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is T) return Right(decoded);
        } catch (_) {
          // Ignore json decode error, maybe it's just a string
        }
      }

      return Left(CacheFailure('Type mismatch for key $key. Expected $T but got ${value.runtimeType}'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> remove({
    required String key,
    String? box,
  }) async {
    try {
      await _prefs.remove(key);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clear({
    String? box,
  }) async {
    try {
      await _prefs.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> contains({
    required String key,
    String? box,
  }) async {
    try {
      return Right(_prefs.containsKey(key));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getKeys({
    String? box,
  }) async {
    try {
      return Right(_prefs.getKeys().toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<T>>> getValues<T>({
    String? box,
  }) async {
    // Not efficiently supported by SharedPreferences
    return const Left(CacheFailure('getValues not supported by SharedPreferences adapter'));
  }

  @override
  Future<Either<Failure, int>> length({
    String? box,
  }) async {
    try {
      return Right(_prefs.getKeys().length);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveList<T>({
    required String key,
    required List<T> data,
    String? box,
  }) async {
    try {
      if (data is List<String>) {
        await _prefs.setStringList(key, data as List<String>);
        return const Right(null);
      }
      // Encode as JSON string
      await _prefs.setString(key, jsonEncode(data));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<T>>> getList<T>({
    required String key,
    String? box,
  }) async {
    try {
      if (T == String) {
        final list = _prefs.getStringList(key);
        if (list != null) return Right(list as List<T>);
      }
      
      final value = _prefs.getString(key);
      if (value == null) return const Right([]);
      
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return Right(decoded.cast<T>());
      }
      
      return const Right([]);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToList<T>({
    required String key,
    required T item,
    String? box,
  }) async {
    try {
      if (item is String) {
        final list = _prefs.getStringList(key) ?? [];
        list.add(item);
        await _prefs.setStringList(key, list);
        return const Right(null);
      }
      
      // For other types, read, decode, add, encode, save
      final value = _prefs.getString(key);
      List<dynamic> list = [];
      if (value != null) {
        try {
          list = jsonDecode(value) as List<dynamic>;
        } catch (_) {}
      }
      list.add(item);
      await _prefs.setString(key, jsonEncode(list));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromList<T>({
    required String key,
    required T item,
    String? box,
  }) async {
    try {
      if (item is String) {
        final list = _prefs.getStringList(key) ?? [];
        list.remove(item);
        await _prefs.setStringList(key, list);
        return const Right(null);
      }
      
      final value = _prefs.getString(key);
      if (value == null) return const Right(null);
      
      List<dynamic> list = [];
      try {
        list = jsonDecode(value) as List<dynamic>;
      } catch (_) {
        return const Right(null);
      }
      
      list.remove(item);
      await _prefs.setString(key, jsonEncode(list));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveWithTTL<T>({
    required String key,
    required T data,
    required Duration ttl,
    String? box,
  }) async {
    // TTL not supported in this simple adapter, just save
    return save(key: key, data: data, box: box);
  }

  @override
  Future<Either<Failure, T?>> getWithTTL<T>({
    required String key,
    String? box,
  }) async {
    // TTL not supported, just get
    return get(key: key, box: box);
  }

  @override
  Future<Either<Failure, void>> cleanExpiredData({
    String? box,
  }) async {
    // No-op
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveUserSetting({
    required String key,
    required dynamic value,
  }) async {
    return save(key: key, data: value);
  }

  @override
  Future<Either<Failure, T?>> getUserSetting<T>({
    required String key,
    T? defaultValue,
  }) async {
    final result = await get<T>(key: key);
    return result.fold(
      (failure) => Right(defaultValue),
      (value) => Right(value ?? defaultValue),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAllUserSettings() async {
    try {
      final keys = _prefs.getKeys();
      final map = <String, dynamic>{};
      for (final key in keys) {
        map[key] = _prefs.get(key);
      }
      return Right(map);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveOfflineData<T>({
    required String key,
    required T data,
    DateTime? lastSync,
  }) async {
    // Simple save, ignoring sync metadata for now
    return save(key: key, data: data);
  }

  @override
  Future<Either<Failure, OfflineData<T>?>> getOfflineData<T>({
    required String key,
  }) async {
    // Not fully supported
    final result = await get<T>(key: key);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data == null) return const Right(null);
        return Right(OfflineData<T>(
          data: data,
          createdAt: DateTime.now(),
          isSynced: true,
        ));
      },
    );
  }

  @override
  Future<Either<Failure, void>> markAsSynced({
    required String key,
  }) async {
    // No-op
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<String>>> getUnsyncedKeys() async {
    return const Right([]);
  }
}
