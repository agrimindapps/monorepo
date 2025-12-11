import 'package:core/core.dart' hide Column;
import '../core/data/models/comentario_model.dart';
import '../features/plants/domain/entities/plant.dart';
import '../features/tasks/domain/entities/task.dart' as task_entity;

// Funções de conversão para Plant
Plant _plantFromFirebaseMap(Map<String, dynamic> map) {
  // Usando chamada direta ao construtor estático
  return Plant.fromFirebaseMap(map);
}

// Funções de conversão para ComentarioModel
ComentarioModel _comentarioFromFirebaseMap(Map<String, dynamic> map) {
  return ComentarioModel.fromFirebaseMap(map);
}

// Funções de conversão para Task
task_entity.Task _taskFromFirebaseMap(Map<String, dynamic> map) {
  return task_entity.Task.fromFirebaseMap(map);
}

/// Configuração de sincronização específica do Plantis
/// Controle de plantas com sync otimizado para dados agrícolas
abstract final class PlantisSyncConfig {
  const PlantisSyncConfig._();

  /// Configura o sistema de sincronização para o Plantis
  /// Configuração específica para dados de plantas com sync moderado
  static Future<void> configure() async {
    await UnifiedSyncManager.instance.initializeApp(
      appName: 'plantis',
      localStorage: _NoOpLocalStorageRepository(),
      config: AppSyncConfig.simple(
        appName: 'plantis',
        syncInterval: const Duration(
          minutes: 15,
        ), // Sync moderado para dados agrícolas
        conflictStrategy: ConflictStrategy.timestamp,
      ),
      entities: [
        EntitySyncRegistration<Plant>.simple(
          entityType: Plant,
          collectionName: 'plants',
          fromMap: _plantFromFirebaseMap,
          toMap: (plant) => plant.toFirebaseMap(),
        ),
        EntitySyncRegistration<ComentarioModel>.simple(
          entityType: ComentarioModel,
          collectionName: 'comments',
          fromMap: _comentarioFromFirebaseMap,
          toMap: (comment) => comment.toFirebaseMap(),
        ),
        EntitySyncRegistration<task_entity.Task>.simple(
          entityType: task_entity.Task,
          collectionName: 'tasks',
          fromMap: _taskFromFirebaseMap,
          toMap: (task) => task.toFirebaseMap(),
        ),
      ],
    );
  }
}

/// Minimal no-op implementation for ILocalStorageRepository
class _NoOpLocalStorageRepository implements ILocalStorageRepository {
  @override
  Future<Either<Failure, void>> initialize() async => const Right(null);

  @override
  Future<Either<Failure, void>> save<T>({
    String? box,
    required T data,
    required String key,
  }) async => const Right(null);

  @override
  Future<Either<Failure, T?>> get<T>({
    String? box,
    required String key,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> remove({
    String? box,
    required String key,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> clear({String? box}) async => const Right(null);

  @override
  Future<Either<Failure, bool>> contains({
    String? box,
    required String key,
  }) async => const Right(false);

  @override
  Future<Either<Failure, void>> saveList<T>({
    String? box,
    required List<T> data,
    required String key,
  }) async => const Right(null);

  @override
  Future<Either<Failure, List<T>>> getList<T>({
    String? box,
    required String key,
  }) async => const Right([]);

  @override
  Future<Either<Failure, void>> addToList<T>({
    String? box,
    required T item,
    required String key,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> removeFromList<T>({
    String? box,
    required T item,
    required String key,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> cleanExpiredData({String? box}) async =>
      const Right(null);

  @override
  Future<Either<Failure, int>> length({String? box}) async => const Right(0);

  @override
  Future<Either<Failure, void>> saveWithTTL<T>({
    String? box,
    required T data,
    required Duration ttl,
    required String key,
  }) async => const Right(null);

  @override
  Future<Either<Failure, T?>> getWithTTL<T>({
    String? box,
    required String key,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> saveUserSetting({
    required String key,
    required dynamic value,
  }) async => const Right(null);

  @override
  Future<Either<Failure, T?>> getUserSetting<T>({
    required String key,
    T? defaultValue,
  }) async => Right(defaultValue);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAllUserSettings() async =>
      const Right({});

  @override
  Future<Either<Failure, List<String>>> getKeys({String? box}) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<T>>> getValues<T>({String? box}) async =>
      const Right([]);

  @override
  Future<Either<Failure, void>> saveOfflineData<T>({
    required String key,
    required T data,
    DateTime? lastSync,
  }) async => const Right(null);

  @override
  Future<Either<Failure, OfflineData<T>?>> getOfflineData<T>({
    required String key,
  }) async {
    return Future.value(const Right(null));
  }

  @override
  Future<Either<Failure, void>> markAsSynced({required String key}) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<String>>> getUnsyncedKeys() async =>
      const Right([]);
}
