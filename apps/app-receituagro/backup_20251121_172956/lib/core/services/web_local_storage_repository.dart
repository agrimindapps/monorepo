import 'package:core/core.dart' hide Column;
import 'package:core/src/domain/repositories/i_local_storage_repository.dart'
    as storage;

/// Minimal web-compatible implementation of ILocalStorageRepository
/// Web storage implementation
/// All operations succeed but don't actually store data
class WebLocalStorageRepository implements ILocalStorageRepository {
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
    return const Right(null);
  }

  @override
  Future<Either<Failure, T?>> get<T>({required String key, String? box}) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> remove({
    required String key,
    String? box,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clear({String? box}) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> contains({
    required String key,
    String? box,
  }) async {
    return const Right(false);
  }

  @override
  Future<Either<Failure, List<String>>> getKeys({String? box}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<T>>> getValues<T>({String? box}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, int>> length({String? box}) async {
    return const Right(0);
  }

  @override
  Future<Either<Failure, void>> saveList<T>({
    required String key,
    required List<T> data,
    String? box,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<T>>> getList<T>({
    required String key,
    String? box,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> addToList<T>({
    required String key,
    required T item,
    String? box,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeFromList<T>({
    required String key,
    required T item,
    String? box,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveWithTTL<T>({
    required String key,
    required T data,
    required Duration ttl,
    String? box,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, T?>> getWithTTL<T>({
    required String key,
    String? box,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> cleanExpiredData({String? box}) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveUserSetting({
    required String key,
    required dynamic value,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, T?>> getUserSetting<T>({
    required String key,
    T? defaultValue,
  }) async {
    return Right(defaultValue);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAllUserSettings() async {
    return const Right({});
  }

  @override
  Future<Either<Failure, void>> saveOfflineData<T>({
    required String key,
    required T data,
    DateTime? lastSync,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, storage.OfflineData<T>?>> getOfflineData<T>({
    required String key,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> markAsSynced({required String key}) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<String>>> getUnsyncedKeys() async {
    return const Right([]);
  }
}
