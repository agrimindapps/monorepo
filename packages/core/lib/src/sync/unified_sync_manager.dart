import 'dart:async';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/entities/base_sync_entity.dart';
import '../domain/repositories/i_sync_repository.dart';
import '../infrastructure/services/sync_firebase_service.dart';
import '../shared/utils/failure.dart';
import 'app_sync_config.dart';
import 'entity_sync_registration.dart';

// TODO(refactoring): PRIORITY MEDIUM - This file is 997 lines and violates SRP
// Plan: Extract to specialized services (see REFACTORING_PLAN.md)
// - SyncCoordinator (multi-app coordination)
// - SyncStateMachine (state management)
// - OfflineSyncHandler (offline handling)
// - SyncErrorHandler (error handling)
// Keep this class as Orchestrator facade
// Estimated effort: 6-8 hours | Risk: High | ROI: Medium-High

/// Coordena sync de múltiplas entidades across diferentes apps
class UnifiedSyncManager {
  static final UnifiedSyncManager _instance = UnifiedSyncManager._internal();
  static UnifiedSyncManager get instance => _instance;

  UnifiedSyncManager._internal();
  final Map<String, AppSyncConfig> _appConfigs = {};
  final Map<String, Map<String, EntitySyncRegistration>> _entityRegistrations =
      {};
  final Map<String, Map<String, dynamic>> _syncRepositories =
      {}; // dynamic para permitir qualquer ISyncRepository<T>
  bool _isInitialized = false;
  String? _currentUserId;
  final Map<String, SyncStatus> _appSyncStatus = {};
  final StreamController<Map<String, SyncStatus>> _globalStatusController =
      StreamController<Map<String, SyncStatus>>.broadcast();
  final StreamController<AppSyncEvent> _eventController =
      StreamController<AppSyncEvent>.broadcast();
  StreamSubscription<User?>? _authSubscription;
  final Map<String, Timer> _syncTimers = {};

  /// Inicializa o sync manager para um app específico
  Future<Either<Failure, void>> initializeApp({
    required String appName,
    required AppSyncConfig config,
    required List<EntitySyncRegistration> entities,
  }) async {
    try {
      developer.log(
        'Initializing unified sync for app: $appName',
        name: 'UnifiedSync',
      );
      _appConfigs[appName] = config;
      _entityRegistrations[appName] = {};
      _syncRepositories[appName] = {};
      for (final registration in entities) {
        await _registerEntity(appName, registration);
      }
      if (!_isInitialized) {
        _setupAuthListener();
        _isInitialized = true;
      }
      _setupAutoSyncForApp(appName);
      _appSyncStatus[appName] = SyncStatus.offline;
      await _updateAppSyncStatus(appName);

      developer.log(
        'App $appName initialized with ${entities.length} entities',
        name: 'UnifiedSync',
      );

      return const Right(null);
    } catch (e) {
      developer.log('Error initializing app $appName: $e', name: 'UnifiedSync');
      return Left(
        InitializationFailure('Failed to initialize app $appName: $e'),
      );
    }
  }

  /// Registra uma entidade específica para um app
  Future<void> _registerEntity(
    String appName,
    EntitySyncRegistration registration,
  ) async {
    final entityTypeKey = registration.entityType.toString();

    developer.log(
      '📝 Registering entity:\n'
      '   Type Key: $entityTypeKey\n'
      '   App: $appName\n'
      '   Collection: ${registration.collectionName}',
      name: 'UnifiedSync',
    );

    _entityRegistrations[appName]![entityTypeKey] = registration;
    final syncRepo = _createTypedRepository(registration);

    await syncRepo.initialize();
    _syncRepositories[appName]![entityTypeKey] = syncRepo;

    developer.log(
      '✅ Entity $entityTypeKey registered successfully for $appName',
      name: 'UnifiedSync',
    );
  }

  /// Cria repositório tipado corretamente
  dynamic _createTypedRepository(EntitySyncRegistration registration) {
    return _createSyncServiceDynamic(
      registration.collectionName,
      registration.fromMap,
      registration.toMap,
      registration.toSyncConfig(),
    );
  }

  /// Cria SyncFirebaseService usando reflection para contornar problemas de tipos
  dynamic _createSyncServiceDynamic(
    String collectionName,
    dynamic fromMapFunction,
    dynamic toMapFunction,
    SyncConfig config,
  ) {
    developer.log(
      'Creating sync service for collection: $collectionName',
      name: 'UnifiedSync',
    );

    try {
      final service = _createSyncServiceReflection(
        collectionName,
        fromMapFunction,
        toMapFunction,
        config,
      );

      developer.log(
        'Sync service created successfully for $collectionName',
        name: 'UnifiedSync',
      );
      return service;
    } catch (e) {
      developer.log(
        'Error creating sync service for $collectionName: $e',
        name: 'UnifiedSync',
      );
      rethrow;
    }
  }

  /// Cria service usando uma abordagem de reflection para evitar conflitos de tipo
  dynamic _createSyncServiceReflection(
    String collectionName,
    dynamic fromMapFunction,
    dynamic toMapFunction,
    SyncConfig config,
  ) {
    final service = _DynamicSyncService(
      collectionName: collectionName,
      fromMapFunction: fromMapFunction,
      toMapFunction: toMapFunction,
      config: config,
    );

    return service;
  }

  /// Obtém repositório de sync para um tipo específico
  /// CORREÇÃO P0: Usar T.toString() para fazer lookup consistente
  ISyncRepository<T>? _getSyncRepository<T extends BaseSyncEntity>(
    String appName,
  ) {
    final entityTypeKey = T.toString();
    final repo = _syncRepositories[appName]?[entityTypeKey];
    if (repo == null) return null;
    return _RepositoryWrapper<T>(repo as dynamic);
  }

  /// Cria uma nova entidade
  Future<Either<Failure, String>> create<T extends BaseSyncEntity>(
    String appName,
    T entity,
  ) async {
    try {
      final entityTypeKey = T.toString();
      developer.log(
        '🔍 CREATE - Looking for repository:\n'
        '   Type: $entityTypeKey\n'
        '   App: $appName\n'
        '   Available repos: ${_syncRepositories[appName]?.keys.toList()}',
        name: 'UnifiedSync',
      );

      final repository = _getSyncRepository<T>(appName);
      if (repository == null) {
        developer.log(
          '❌ Repository not found!\n'
          '   Requested: $entityTypeKey\n'
          '   Available: ${_syncRepositories[appName]?.keys.join(", ")}',
          name: 'UnifiedSync',
        );
        return Left(
          NotFoundFailure(
            'No sync repository found for ${T.toString()} in $appName',
          ),
        );
      }
      final entityWithMetadata =
          entity.copyWith(userId: _currentUserId, moduleName: appName) as T;

      final result = await repository.create(entityWithMetadata);

      if (result.isRight()) {
        _emitEvent(
          AppSyncEvent(
            appName: appName,
            entityType: T,
            action: SyncAction.create,
            entityId: result.getOrElse(() => ''),
          ),
        );
        developer.log(
          '✅ UNIFIED_SYNC: Entity created successfully - type: ${T.toString()}, id: ${result.getOrElse(() => '')}',
          name: 'UnifiedSync',
        );
      } else {
        developer.log(
          '❌ UNIFIED_SYNC: Failed to create entity - type: ${T.toString()}, error: ${result.fold((f) => f.message, (_) => '')}',
          name: 'UnifiedSync',
        );
      }

      return result;
    } catch (e) {
      return Left(CacheFailure('Error creating entity: $e'));
    }
  }

  /// Atualiza uma entidade existente
  Future<Either<Failure, void>> update<T extends BaseSyncEntity>(
    String appName,
    String id,
    T entity,
  ) async {
    try {
      final repository = _getSyncRepository<T>(appName);
      if (repository == null) {
        return Left(
          NotFoundFailure(
            'No sync repository found for ${T.toString()} in $appName',
          ),
        );
      }

      final entityWithMetadata =
          entity.copyWith(
                userId: _currentUserId,
                moduleName: appName,
                updatedAt: DateTime.now(),
              )
              as T;

      final result = await repository.update(id, entityWithMetadata);

      if (result.isRight()) {
        _emitEvent(
          AppSyncEvent(
            appName: appName,
            entityType: T,
            action: SyncAction.update,
            entityId: id,
          ),
        );
      }

      return result;
    } catch (e) {
      return Left(CacheFailure('Error updating entity: $e'));
    }
  }

  /// Remove uma entidade (soft delete)
  Future<Either<Failure, void>> delete<T extends BaseSyncEntity>(
    String appName,
    String id,
  ) async {
    try {
      final repository = _getSyncRepository<T>(appName);
      if (repository == null) {
        return Left(
          NotFoundFailure(
            'No sync repository found for ${T.toString()} in $appName',
          ),
        );
      }

      final result = await repository.delete(id);

      if (result.isRight()) {
        _emitEvent(
          AppSyncEvent(
            appName: appName,
            entityType: T,
            action: SyncAction.delete,
            entityId: id,
          ),
        );
      }

      return result;
    } catch (e) {
      return Left(CacheFailure('Error deleting entity: $e'));
    }
  }

  /// Busca uma entidade por ID
  Future<Either<Failure, T?>> findById<T extends BaseSyncEntity>(
    String appName,
    String id,
  ) async {
    try {
      final repository = _getSyncRepository<T>(appName);
      if (repository == null) {
        return Left(
          NotFoundFailure(
            'No sync repository found for ${T.toString()} in $appName',
          ),
        );
      }

      return await repository.findById(id);
    } catch (e) {
      return Left(CacheFailure('Error finding entity by ID: $e'));
    }
  }

  /// Busca todas as entidades de um tipo
  Future<Either<Failure, List<T>>> findAll<T extends BaseSyncEntity>(
    String appName,
  ) async {
    try {
      final repository = _getSyncRepository<T>(appName);
      if (repository == null) {
        return Left(
          NotFoundFailure(
            'No sync repository found for ${T.toString()} in $appName',
          ),
        );
      }

      return await repository.findAll();
    } catch (e) {
      return Left(CacheFailure('Error finding all entities: $e'));
    }
  }

  /// Busca entidades com filtros
  Future<Either<Failure, List<T>>> findWhere<T extends BaseSyncEntity>(
    String appName,
    Map<String, dynamic> filters,
  ) async {
    try {
      final repository = _getSyncRepository<T>(appName);
      if (repository == null) {
        return Left(
          NotFoundFailure(
            'No sync repository found for ${T.toString()} in $appName',
          ),
        );
      }

      return await repository.findWhere(filters);
    } catch (e) {
      return Left(CacheFailure('Error finding entities with filters: $e'));
    }
  }

  /// Stream de dados para uma entidade específica
  Stream<List<T>>? streamAll<T extends BaseSyncEntity>(String appName) {
    final repository = _getSyncRepository<T>(appName);
    return repository?.dataStream;
  }

  /// Força sincronização de todas as entidades de um app
  Future<Either<Failure, void>> forceSyncApp(String appName) async {
    try {
      final repositories = _syncRepositories[appName];
      if (repositories == null || repositories.isEmpty) {
        return Left(NotFoundFailure('No repositories found for app $appName'));
      }

      final futures = repositories.values.map(
        (repo) =>
            (repo as dynamic).forceSync() as Future<Either<Failure, void>>,
      );
      final results = await Future.wait(futures);
      for (final result in results) {
        if (result.isLeft()) {
          return result;
        }
      }

      await _updateAppSyncStatus(appName);

      developer.log(
        'Force sync completed for app $appName',
        name: 'UnifiedSync',
      );
      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Error during force sync: $e'));
    }
  }

  /// Força sincronização de uma entidade específica
  Future<Either<Failure, void>> forceSyncEntity<T extends BaseSyncEntity>(
    String appName,
  ) async {
    try {
      final repository = _getSyncRepository<T>(appName);
      if (repository == null) {
        return Left(
          NotFoundFailure(
            'No sync repository found for ${T.toString()} in $appName',
          ),
        );
      }

      final result = await repository.forceSync();
      if (result.isRight()) {
        await _updateAppSyncStatus(appName);
      }

      return result;
    } catch (e) {
      return Left(SyncFailure('Error during entity force sync: $e'));
    }
  }

  /// Obtém status de sincronização de um app
  SyncStatus getAppSyncStatus(String appName) {
    return _appSyncStatus[appName] ?? SyncStatus.offline;
  }

  /// Stream de status global de sincronização
  Stream<Map<String, SyncStatus>> get globalSyncStatusStream =>
      _globalStatusController.stream;

  /// Stream de eventos de sincronização
  Stream<AppSyncEvent> get syncEventStream => _eventController.stream;

  /// Obtém informações de debug para um app
  Map<String, dynamic> getAppDebugInfo(String appName) {
    final config = _appConfigs[appName];
    final repositories = _syncRepositories[appName];

    if (config == null || repositories == null) {
      return {'error': 'App not found or not initialized'};
    }

    final debugInfo = <String, dynamic>{
      'app_name': appName,
      'sync_status': _appSyncStatus[appName]?.name,
      'current_user_id': _currentUserId,
      'entities_count': repositories.length,
      'config': config.toDebugMap(),
      'entities': <String, dynamic>{},
    };
    for (final entry in repositories.entries) {
      final entityTypeKey = entry.key; // já é string
      final repository = entry.value as dynamic;
      debugInfo['entities'][entityTypeKey] = repository.getDebugInfo();
    }

    return debugInfo;
  }

  /// Limpa dados locais de um app
  Future<Either<Failure, void>> clearAppData(String appName) async {
    try {
      final repositories = _syncRepositories[appName];
      if (repositories == null) {
        return Left(NotFoundFailure('App $appName not found'));
      }

      final futures = repositories.values.map(
        (repo) =>
            (repo as dynamic).clearLocalData() as Future<Either<Failure, void>>,
      );
      final results = await Future.wait(futures);
      for (final result in results) {
        if (result.isLeft()) {
          return result;
        }
      }

      developer.log('Local data cleared for app $appName', name: 'UnifiedSync');
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error clearing app data: $e'));
    }
  }

  void _setupAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        final oldUserId = _currentUserId;
        _currentUserId = user?.uid;

        if (_currentUserId != oldUserId) {
          developer.log(
            'Auth state changed: ${_currentUserId ?? 'null'}',
            name: 'UnifiedSync',
          );
          for (final appName in _appConfigs.keys) {
            await _updateAppSyncStatus(appName);
          }
          if (_currentUserId != null) {
            for (final appName in _appConfigs.keys) {
              _triggerAutoSyncForApp(appName);
            }
          }
        }
      },
      onError: (Object error) {
        developer.log('Auth listener error: $error', name: 'UnifiedSync');
      },
    );
  }

  void _setupAutoSyncForApp(String appName) {
    final config = _appConfigs[appName];
    if (config == null || !config.enableAutoSync) return;

    _syncTimers[appName]?.cancel();
    _syncTimers[appName] = Timer.periodic(config.syncInterval, (timer) {
      if (_currentUserId != null && config.enableAutoSync) {
        _triggerAutoSyncForApp(appName);
      }
    });

    developer.log(
      'Auto sync enabled for $appName (${config.syncInterval})',
      name: 'UnifiedSync',
    );
  }

  void _triggerAutoSyncForApp(String appName) {
    Future.microtask(() async {
      try {
        await forceSyncApp(appName);
      } catch (e) {
        developer.log('Auto sync error for $appName: $e', name: 'UnifiedSync');
      }
    });
  }

  Future<void> _updateAppSyncStatus(String appName) async {
    try {
      final repositories = _syncRepositories[appName];
      if (repositories == null) return;

      SyncStatus newStatus;

      if (_currentUserId == null) {
        newStatus = SyncStatus.localOnly;
      } else {
        final entityStatuses = <SyncStatus>[];
        for (final repo in repositories.values) {
          final repository = repo as dynamic;
          final debugInfo = repository.getDebugInfo();
          final canSync = debugInfo['can_sync'] as bool? ?? false;
          final unsyncedCount = debugInfo['unsynced_items_count'] as int? ?? 0;

          if (!canSync) {
            entityStatuses.add(SyncStatus.offline);
          } else if (unsyncedCount > 0) {
            entityStatuses.add(SyncStatus.syncing);
          } else {
            entityStatuses.add(SyncStatus.synced);
          }
        }
        if (entityStatuses.contains(SyncStatus.offline)) {
          newStatus = SyncStatus.offline;
        } else if (entityStatuses.contains(SyncStatus.syncing)) {
          newStatus = SyncStatus.syncing;
        } else {
          newStatus = SyncStatus.synced;
        }
      }

      if (_appSyncStatus[appName] != newStatus) {
        _appSyncStatus[appName] = newStatus;
        _globalStatusController.add(Map.from(_appSyncStatus));

        developer.log(
          'Sync status for $appName: ${newStatus.name}',
          name: 'UnifiedSync',
        );
      }
    } catch (e) {
      developer.log(
        'Error updating sync status for $appName: $e',
        name: 'UnifiedSync',
      );
    }
  }

  void _emitEvent(AppSyncEvent event) {
    _eventController.add(event);
  }

  /// Cleanup de recursos
  Future<void> dispose() async {
    try {
      for (final timer in _syncTimers.values) {
        timer.cancel();
      }
      _syncTimers.clear();
      await _authSubscription?.cancel();
      await _globalStatusController.close();
      await _eventController.close();
      for (final repositories in _syncRepositories.values) {
        for (final repository in repositories.values) {
          final repo = repository as dynamic;
          if (repo is SyncFirebaseService) {
            await repo.dispose();
          }
        }
      }
      _appConfigs.clear();
      _entityRegistrations.clear();
      _syncRepositories.clear();
      _appSyncStatus.clear();
      _isInitialized = false;

      developer.log('UnifiedSyncManager disposed', name: 'UnifiedSync');
    } catch (e) {
      developer.log(
        'Error disposing UnifiedSyncManager: $e',
        name: 'UnifiedSync',
      );
    }
  }
}

/// Evento de sincronização
class AppSyncEvent {
  const AppSyncEvent({
    required this.appName,
    required this.entityType,
    required this.action,
    this.entityId,
    this.error,
    this.timestamp,
  });

  final String appName;
  final Type entityType;
  final SyncAction action;
  final String? entityId;
  final String? error;
  final DateTime? timestamp;

  @override
  String toString() {
    return 'AppSyncEvent(app: $appName, type: $entityType, action: $action, id: $entityId)';
  }
}

/// Ações de sincronização
enum SyncAction { create, update, delete, sync, conflict, error }

/// Falha de inicialização
class InitializationFailure extends Failure {
  const InitializationFailure(String message) : super(message: message);
}

/// Wrapper para forçar tipo correto do repositório
/// CORREÇÃO P0: Resolve problema de cast entre SyncFirebaseService<BaseSyncEntity> e ISyncRepository<T>
class _RepositoryWrapper<T extends BaseSyncEntity>
    implements ISyncRepository<T> {
  final dynamic _repository;

  _RepositoryWrapper(this._repository);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return Function.apply(_repository.noSuchMethod, [invocation]);
  }

  @override
  Future<Either<Failure, String>> create(T entity) async {
    return await _repository.create(entity) as Either<Failure, String>;
  }

  @override
  Future<Either<Failure, void>> update(String id, T entity) async {
    return await _repository.update(id, entity) as Either<Failure, void>;
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    return await _repository.delete(id) as Either<Failure, void>;
  }

  @override
  Future<Either<Failure, T?>> findById(String id) async {
    final result = await _repository.findById(id) as Either<Failure, dynamic>;
    return result.fold(
      (Failure failure) => Left<Failure, T?>(failure),
      (dynamic entity) => Right<Failure, T?>(entity as T?),
    );
  }

  @override
  Future<Either<Failure, List<T>>> findAll() async {
    final result =
        await _repository.findAll() as Either<Failure, List<dynamic>>;
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.cast<T>()),
    );
  }

  @override
  Future<Either<Failure, List<T>>> findWhere(
    Map<String, dynamic> filters,
  ) async {
    final result =
        await _repository.findWhere(filters) as Either<Failure, List<dynamic>>;
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.cast<T>()),
    );
  }

  @override
  Stream<List<T>> get dataStream =>
      (_repository.dataStream as Stream<List<BaseSyncEntity>>).map(
        (List<BaseSyncEntity> list) => list.cast<T>(),
      );

  Stream<SyncStatus> get statusStream =>
      _repository.syncStatusStream as Stream<SyncStatus>;

  @override
  Future<Either<Failure, void>> forceSync() async {
    return await _repository.forceSync() as Either<Failure, void>;
  }

  @override
  Future<Either<Failure, void>> clearLocalData() async {
    return await _repository.clearLocalData() as Either<Failure, void>;
  }

  @override
  Map<String, dynamic> getDebugInfo() {
    return _repository.getDebugInfo() as Map<String, dynamic>;
  }

  @override
  Future<Either<Failure, void>> initialize() async {
    return await _repository.initialize() as Either<Failure, void>;
  }

  @override
  Stream<bool> get connectivityStream =>
      _repository.connectivityStream as Stream<bool>;

  @override
  Future<Either<Failure, List<String>>> createBatch(List<T> items) async {
    return await _repository.createBatch(items)
        as Either<Failure, List<String>>;
  }

  @override
  Future<Either<Failure, void>> deleteBatch(List<String> ids) async {
    return await _repository.deleteBatch(ids) as Either<Failure, void>;
  }

  @override
  Future<Either<Failure, List<T>>> findRecent({
    int? limit,
    Duration? since,
  }) async {
    final result =
        await _repository.findRecent(limit: limit, since: since)
            as Either<Failure, List<dynamic>>;
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.cast<T>()),
    );
  }

  @override
  Future<Either<Failure, List<T>>> fullTextSearch(
    String query, {
    List<String>? searchFields,
    int? limit,
  }) async {
    final result =
        await _repository.fullTextSearch(
              query,
              searchFields: searchFields,
              limit: limit,
            )
            as Either<Failure, List<dynamic>>;
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.cast<T>()),
    );
  }

  @override
  Future<Either<Failure, List<T>>> getUnsyncedItems() async {
    final result =
        await _repository.getUnsyncedItems() as Either<Failure, List<dynamic>>;
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.cast<T>()),
    );
  }

  @override
  Future<Either<Failure, List<T>>> getConflictedItems() async {
    final result =
        await _repository.getConflictedItems()
            as Either<Failure, List<dynamic>>;
    return result.fold(
      (failure) => Left(failure),
      (list) => Right(list.cast<T>()),
    );
  }

  @override
  Future<Either<Failure, void>> resolveConflict(String id, T resolution) async {
    return await _repository.resolveConflict(id, resolution)
        as Either<Failure, void>;
  }

  @override
  Stream<SyncStatus> get syncStatusStream =>
      _repository.syncStatusStream as Stream<SyncStatus>;

  @override
  Future<Either<Failure, void>> updateBatch(Map<String, T> items) async {
    return await _repository.updateBatch(items) as Either<Failure, void>;
  }
}

/// Service de sync dinâmico que contorna problemas de tipagem genérica
/// CORREÇÃO P0: Implementa ISyncRepository de forma dinâmica
class _DynamicSyncService implements ISyncRepository<BaseSyncEntity> {
  final String collectionName;
  final dynamic fromMapFunction;
  final dynamic toMapFunction;
  final SyncConfig config;

  late final SyncFirebaseService<BaseSyncEntity> _internalService;

  _DynamicSyncService({
    required this.collectionName,
    required this.fromMapFunction,
    required this.toMapFunction,
    required this.config,
  }) {
    _internalService = _createGenericService(config);
  }

  /// Cria service genérico que evita conflitos de tipo usando runtime type checking
  SyncFirebaseService<BaseSyncEntity> _createGenericService(SyncConfig config) {
    return SyncFirebaseService<BaseSyncEntity>.getInstance(
      collectionName,
      (map) {
        try {
          final entity = fromMapFunction(map);
          if (entity is BaseSyncEntity) {
            return entity;
          } else {
            return entity as BaseSyncEntity;
          }
        } catch (e) {
          developer.log('Error in fromMap: $e', name: 'DynamicSync');
          rethrow;
        }
      },
      (entity) {
        try {
          return entity.toFirebaseMap();
        } catch (e) {
          try {
            final callable = toMapFunction as dynamic;
            final result = callable(entity);

            if (result is Map<String, dynamic>) {
              return result;
            } else if (result is Map) {
              return Map<String, dynamic>.from(result);
            } else {
              return <String, dynamic>{};
            }
          } catch (e2) {
            developer.log('Error in toMap fallback: $e2', name: 'DynamicSync');
            return <String, dynamic>{
              'error': 'Failed to convert entity to map',
            };
          }
        }
      },
      config: config,
    );
  }

  @override
  Future<Either<Failure, void>> initialize() => _internalService.initialize();

  @override
  Future<Either<Failure, String>> create(BaseSyncEntity entity) =>
      _internalService.create(entity);

  @override
  Future<Either<Failure, void>> update(String id, BaseSyncEntity entity) =>
      _internalService.update(id, entity);

  @override
  Future<Either<Failure, void>> delete(String id) =>
      _internalService.delete(id);

  @override
  Future<Either<Failure, BaseSyncEntity?>> findById(String id) =>
      _internalService.findById(id);

  @override
  Future<Either<Failure, List<BaseSyncEntity>>> findAll() =>
      _internalService.findAll();

  @override
  Future<Either<Failure, List<BaseSyncEntity>>> findWhere(
    Map<String, dynamic> filters,
  ) => _internalService.findWhere(filters);

  @override
  Stream<List<BaseSyncEntity>> get dataStream => _internalService.dataStream;

  Stream<SyncStatus> get statusStream => _internalService.syncStatusStream;

  @override
  Future<Either<Failure, void>> forceSync() => _internalService.forceSync();

  @override
  Future<Either<Failure, void>> clearLocalData() =>
      _internalService.clearLocalData();

  @override
  Map<String, dynamic> getDebugInfo() => _internalService.getDebugInfo();
  @override
  Stream<bool> get connectivityStream => _internalService.connectivityStream;

  @override
  Future<Either<Failure, List<String>>> createBatch(
    List<BaseSyncEntity> items,
  ) => _internalService.createBatch(items);

  @override
  Future<Either<Failure, void>> deleteBatch(List<String> ids) =>
      _internalService.deleteBatch(ids);

  @override
  Future<Either<Failure, List<BaseSyncEntity>>> findRecent({
    int? limit,
    Duration? since,
  }) => _internalService.findRecent(limit: limit, since: since);

  @override
  Future<Either<Failure, List<BaseSyncEntity>>> fullTextSearch(
    String query, {
    List<String>? searchFields,
    int? limit,
  }) => _internalService.fullTextSearch(query, searchFields: searchFields);

  @override
  Future<Either<Failure, List<BaseSyncEntity>>> getUnsyncedItems() =>
      _internalService.getUnsyncedItems();

  @override
  Future<Either<Failure, List<BaseSyncEntity>>> getConflictedItems() =>
      _internalService.getConflictedItems();

  @override
  Future<Either<Failure, void>> resolveConflict(
    String id,
    BaseSyncEntity resolution,
  ) => _internalService.resolveConflict(id, resolution);

  @override
  Stream<SyncStatus> get syncStatusStream => _internalService.syncStatusStream;

  @override
  Future<Either<Failure, void>> updateBatch(
    Map<String, BaseSyncEntity> items,
  ) => _internalService.updateBatch(items);
}
