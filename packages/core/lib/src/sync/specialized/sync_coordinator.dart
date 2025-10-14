import 'dart:async';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';

import '../../domain/entities/base_sync_entity.dart';
import '../../domain/repositories/i_sync_repository.dart';
import '../../infrastructure/services/sync_firebase_service.dart';
import '../../shared/utils/failure.dart';
import '../app_sync_config.dart';
import '../entity_sync_registration.dart';

/// Coordenador de sincronização multi-app
///
/// Responsabilidades:
/// - Registro de apps e suas configurações
/// - Registro de entidades por app
/// - Gerenciamento de repositórios tipados
/// - Lookup de repositórios por tipo
class SyncCoordinator {
  final Map<String, AppSyncConfig> _appConfigs = {};
  final Map<String, Map<String, EntitySyncRegistration>> _entityRegistrations = {};
  final Map<String, Map<String, ISyncRepository<BaseSyncEntity>>> _syncRepositories = {};
  bool _isInitialized = false;

  /// Registra um app com suas configurações
  Future<Either<Failure, void>> registerApp({
    required String appName,
    required AppSyncConfig config,
  }) async {
    try {
      developer.log('Registering app: $appName', name: 'SyncCoordinator');

      _appConfigs[appName] = config;
      _entityRegistrations[appName] = {};
      _syncRepositories[appName] = {};

      _isInitialized = true;

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to register app $appName: $e'));
    }
  }

  /// Registra uma entidade para um app
  Future<Either<Failure, void>> registerEntity({
    required String appName,
    required EntitySyncRegistration registration,
  }) async {
    try {
      if (!_appConfigs.containsKey(appName)) {
        return Left(NotFoundFailure('App $appName not registered'));
      }

      final entityTypeKey = registration.entityType.toString();

      developer.log(
        'Registering entity: $entityTypeKey for app: $appName',
        name: 'SyncCoordinator',
      );

      _entityRegistrations[appName]![entityTypeKey] = registration;

      // Create typed repository
      final repository = await _createRepository(registration);
      _syncRepositories[appName]![entityTypeKey] = repository;

      developer.log(
        'Entity $entityTypeKey registered successfully',
        name: 'SyncCoordinator',
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to register entity: $e'));
    }
  }

  /// Cria um repositório tipado para a entidade
  Future<ISyncRepository<BaseSyncEntity>> _createRepository(
    EntitySyncRegistration registration,
  ) async {
    final service = SyncFirebaseService<BaseSyncEntity>.getInstance(
      registration.collectionName,
      registration.fromMap,
      (entity) => entity.toFirebaseMap(),
      config: registration.toSyncConfig(),
    );

    await service.initialize();
    return service;
  }

  /// Obtém repositório tipado por tipo de entidade
  ISyncRepository<T>? getRepository<T extends BaseSyncEntity>(String appName) {
    final entityTypeKey = T.toString();
    final repo = _syncRepositories[appName]?[entityTypeKey];

    if (repo == null) {
      developer.log(
        'Repository not found for $entityTypeKey in $appName',
        name: 'SyncCoordinator',
      );
      return null;
    }

    return _RepositoryWrapper<T>(repo);
  }

  /// Obtém todos os repositórios de um app
  Map<String, ISyncRepository<BaseSyncEntity>>? getAppRepositories(String appName) {
    return _syncRepositories[appName];
  }

  /// Obtém configuração de um app
  AppSyncConfig? getAppConfig(String appName) {
    return _appConfigs[appName];
  }

  /// Obtém todas as entidades registradas de um app
  Map<String, EntitySyncRegistration>? getAppEntities(String appName) {
    return _entityRegistrations[appName];
  }

  /// Lista todos os apps registrados
  List<String> get registeredApps => _appConfigs.keys.toList();

  /// Verifica se um app está registrado
  bool isAppRegistered(String appName) => _appConfigs.containsKey(appName);

  /// Remove um app e seus repositórios
  Future<Either<Failure, void>> unregisterApp(String appName) async {
    try {
      // Dispose repositories
      final repositories = _syncRepositories[appName];
      if (repositories != null) {
        for (final repo in repositories.values) {
          if (repo is SyncFirebaseService) {
            await repo.dispose();
          }
        }
      }

      _appConfigs.remove(appName);
      _entityRegistrations.remove(appName);
      _syncRepositories.remove(appName);

      developer.log('App $appName unregistered', name: 'SyncCoordinator');
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to unregister app: $e'));
    }
  }

  /// Obtém informações de debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'is_initialized': _isInitialized,
      'registered_apps': _appConfigs.keys.toList(),
      'total_entities': _syncRepositories.values
          .map((repos) => repos.length)
          .fold<int>(0, (sum, count) => sum + count),
      'apps_detail': _appConfigs.map((appName, config) => MapEntry(
            appName,
            {
              'entity_count': _syncRepositories[appName]?.length ?? 0,
              'entities': _syncRepositories[appName]?.keys.toList() ?? [],
            },
          )),
    };
  }

  /// Limpa todos os dados
  Future<void> clear() async {
    for (final appName in _appConfigs.keys.toList()) {
      await unregisterApp(appName);
    }
    _isInitialized = false;
  }
}

/// Wrapper para forçar tipo correto do repositório
class _RepositoryWrapper<T extends BaseSyncEntity> implements ISyncRepository<T> {
  final ISyncRepository<BaseSyncEntity> _repository;

  _RepositoryWrapper(this._repository);

  @override
  Future<Either<Failure, String>> create(T entity) async {
    return await _repository.create(entity);
  }

  @override
  Future<Either<Failure, void>> update(String id, T entity) async {
    return await _repository.update(id, entity);
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    return await _repository.delete(id);
  }

  @override
  Future<Either<Failure, T?>> findById(String id) async {
    final result = await _repository.findById(id);
    return result.fold(
      (failure) => Left(failure),
      (entity) => Right(entity as T?),
    );
  }

  @override
  Future<Either<Failure, List<T>>> findAll() async {
    final result = await _repository.findAll();
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.cast<T>()),
    );
  }

  @override
  Future<Either<Failure, List<T>>> findWhere(Map<String, dynamic> filters) async {
    final result = await _repository.findWhere(filters);
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.cast<T>()),
    );
  }

  @override
  Stream<List<T>> get dataStream =>
      _repository.dataStream.map((list) => list.cast<T>());

  @override
  Future<Either<Failure, void>> forceSync() => _repository.forceSync();

  @override
  Future<Either<Failure, void>> clearLocalData() => _repository.clearLocalData();

  @override
  Map<String, dynamic> getDebugInfo() => _repository.getDebugInfo();

  @override
  Future<Either<Failure, void>> initialize() => _repository.initialize();

  @override
  Stream<bool> get connectivityStream => _repository.connectivityStream;

  @override
  Future<Either<Failure, List<String>>> createBatch(List<T> items) =>
      _repository.createBatch(items.cast<BaseSyncEntity>());

  @override
  Future<Either<Failure, void>> deleteBatch(List<String> ids) =>
      _repository.deleteBatch(ids);

  @override
  Future<Either<Failure, List<T>>> findRecent({int? limit, Duration? since}) async {
    final result = await _repository.findRecent(limit: limit, since: since);
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.cast<T>()),
    );
  }

  @override
  Future<Either<Failure, List<T>>> fullTextSearch(
    String query, {
    List<String>? searchFields,
  }) async {
    final result = await _repository.fullTextSearch(
      query,
      searchFields: searchFields,
    );
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.cast<T>()),
    );
  }

  @override
  Future<Either<Failure, List<T>>> getUnsyncedItems() async {
    final result = await _repository.getUnsyncedItems();
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.cast<T>()),
    );
  }

  @override
  Future<Either<Failure, List<T>>> getConflictedItems() async {
    final result = await _repository.getConflictedItems();
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.cast<T>()),
    );
  }

  @override
  Future<Either<Failure, void>> resolveConflict(String id, T resolution) =>
      _repository.resolveConflict(id, resolution);

  @override
  Stream<SyncStatus> get syncStatusStream => _repository.syncStatusStream;

  @override
  Future<Either<Failure, void>> updateBatch(Map<String, T> items) =>
      _repository.updateBatch(items.cast<String, BaseSyncEntity>());
}
