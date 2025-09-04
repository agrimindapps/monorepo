import 'dart:async';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/entities/base_sync_entity.dart';
import '../domain/repositories/i_sync_repository.dart';
import '../shared/utils/failure.dart';
import '../infrastructure/services/sync_firebase_service.dart';
import 'entity_sync_registration.dart';
import 'app_sync_config.dart';

/// Gerenciador central de sincronização para todo o monorepo
/// Coordena sync de múltiplas entidades across diferentes apps
class UnifiedSyncManager {
  static final UnifiedSyncManager _instance = UnifiedSyncManager._internal();
  static UnifiedSyncManager get instance => _instance;
  
  UnifiedSyncManager._internal();

  // Registros por app
  final Map<String, AppSyncConfig> _appConfigs = {};
  final Map<String, Map<Type, EntitySyncRegistration>> _entityRegistrations = {};
  final Map<String, Map<Type, ISyncRepository>> _syncRepositories = {};
  
  // Estado global
  bool _isInitialized = false;
  String? _currentUserId;
  final Map<String, SyncStatus> _appSyncStatus = {};
  
  // Streams de status
  final StreamController<Map<String, SyncStatus>> _globalStatusController = 
      StreamController<Map<String, SyncStatus>>.broadcast();
  final StreamController<AppSyncEvent> _eventController = 
      StreamController<AppSyncEvent>.broadcast();
  
  // Listeners
  StreamSubscription<User?>? _authSubscription;
  final Map<String, Timer> _syncTimers = {};

  /// Inicializa o sync manager para um app específico
  Future<Either<Failure, void>> initializeApp({
    required String appName,
    required AppSyncConfig config,
    required List<EntitySyncRegistration> entities,
  }) async {
    try {
      developer.log('Initializing unified sync for app: $appName', name: 'UnifiedSync');
      
      // Registrar configuração do app
      _appConfigs[appName] = config;
      _entityRegistrations[appName] = {};
      _syncRepositories[appName] = {};
      
      // Registrar entidades
      for (final registration in entities) {
        await _registerEntity(appName, registration);
      }
      
      // Configurar listeners de auth (apenas uma vez)
      if (!_isInitialized) {
        _setupAuthListener();
        _isInitialized = true;
      }
      
      // Configurar sync automático
      _setupAutoSyncForApp(appName);
      
      // Inicializar status
      _appSyncStatus[appName] = SyncStatus.offline;
      await _updateAppSyncStatus(appName);
      
      developer.log('App $appName initialized with ${entities.length} entities', name: 'UnifiedSync');
      
      return const Right(null);
    } catch (e) {
      developer.log('Error initializing app $appName: $e', name: 'UnifiedSync');
      return Left(InitializationFailure('Failed to initialize app $appName: $e'));
    }
  }

  /// Registra uma entidade específica para um app
  Future<void> _registerEntity(String appName, EntitySyncRegistration registration) async {
    final entityType = registration.entityType;
    _entityRegistrations[appName]![entityType] = registration;
    
    // Criar e inicializar repositório de sync
    final syncRepo = SyncFirebaseService.getInstance(
      registration.collectionName,
      registration.fromMap,
      registration.toMap,
      config: registration.toSyncConfig(),
    );
    
    await syncRepo.initialize();
    _syncRepositories[appName]![entityType] = syncRepo;
    
    developer.log('Entity ${entityType.toString()} registered for $appName', name: 'UnifiedSync');
  }

  /// Obtém repositório de sync para um tipo específico
  ISyncRepository<T>? _getSyncRepository<T extends BaseSyncEntity>(String appName) {
    return _syncRepositories[appName]?[T] as ISyncRepository<T>?;
  }

  /// Cria uma nova entidade
  Future<Either<Failure, String>> create<T extends BaseSyncEntity>(
    String appName, 
    T entity,
  ) async {
    try {
      final repository = _getSyncRepository<T>(appName);
      if (repository == null) {
        return Left(NotFoundFailure('No sync repository found for ${T.toString()} in $appName'));
      }

      // Adicionar metadados do app
      final entityWithMetadata = entity.copyWith(
        userId: _currentUserId,
        moduleName: appName,
      ) as T;

      final result = await repository.create(entityWithMetadata);
      
      if (result.isRight()) {
        _emitEvent(AppSyncEvent(
          appName: appName,
          entityType: T,
          action: SyncAction.create,
          entityId: result.getOrElse(() => ''),
        ));
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
        return Left(NotFoundFailure('No sync repository found for ${T.toString()} in $appName'));
      }

      final entityWithMetadata = entity.copyWith(
        userId: _currentUserId,
        moduleName: appName,
        updatedAt: DateTime.now(),
      ) as T;

      final result = await repository.update(id, entityWithMetadata);
      
      if (result.isRight()) {
        _emitEvent(AppSyncEvent(
          appName: appName,
          entityType: T,
          action: SyncAction.update,
          entityId: id,
        ));
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
        return Left(NotFoundFailure('No sync repository found for ${T.toString()} in $appName'));
      }

      final result = await repository.delete(id);
      
      if (result.isRight()) {
        _emitEvent(AppSyncEvent(
          appName: appName,
          entityType: T,
          action: SyncAction.delete,
          entityId: id,
        ));
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
        return Left(NotFoundFailure('No sync repository found for ${T.toString()} in $appName'));
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
        return Left(NotFoundFailure('No sync repository found for ${T.toString()} in $appName'));
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
        return Left(NotFoundFailure('No sync repository found for ${T.toString()} in $appName'));
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

      final futures = repositories.values.map((repo) => repo.forceSync());
      final results = await Future.wait(futures);
      
      // Verificar se houve algum erro
      for (final result in results) {
        if (result.isLeft()) {
          return result;
        }
      }
      
      await _updateAppSyncStatus(appName);
      
      developer.log('Force sync completed for app $appName', name: 'UnifiedSync');
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
        return Left(NotFoundFailure('No sync repository found for ${T.toString()} in $appName'));
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

    // Debug info de cada entidade
    for (final entry in repositories.entries) {
      final entityType = entry.key.toString();
      final repository = entry.value;
      debugInfo['entities'][entityType] = repository.getDebugInfo();
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

      final futures = repositories.values.map((repo) => repo.clearLocalData());
      final results = await Future.wait(futures);
      
      // Verificar se houve algum erro
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

  // Métodos privados

  void _setupAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) async {
        final oldUserId = _currentUserId;
        _currentUserId = user?.uid;
        
        if (_currentUserId != oldUserId) {
          developer.log('Auth state changed: ${_currentUserId ?? 'null'}', name: 'UnifiedSync');
          
          // Atualizar status de todos os apps
          for (final appName in _appConfigs.keys) {
            await _updateAppSyncStatus(appName);
          }
          
          // Disparar sync automático se necessário
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
    
    developer.log('Auto sync enabled for $appName (${config.syncInterval})', name: 'UnifiedSync');
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
        // Verificar status das entidades
        final entityStatuses = <SyncStatus>[];
        for (final repo in repositories.values) {
          final debugInfo = repo.getDebugInfo();
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
        
        // Determinar status geral
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
        
        developer.log('Sync status for $appName: ${newStatus.name}', name: 'UnifiedSync');
      }
    } catch (e) {
      developer.log('Error updating sync status for $appName: $e', name: 'UnifiedSync');
    }
  }

  void _emitEvent(AppSyncEvent event) {
    _eventController.add(event);
  }

  /// Cleanup de recursos
  Future<void> dispose() async {
    try {
      // Cancel timers
      for (final timer in _syncTimers.values) {
        timer.cancel();
      }
      _syncTimers.clear();
      
      // Cancel auth subscription
      await _authSubscription?.cancel();
      
      // Close stream controllers
      await _globalStatusController.close();
      await _eventController.close();
      
      // Dispose repositories
      for (final repositories in _syncRepositories.values) {
        for (final repository in repositories.values) {
          if (repository is SyncFirebaseService) {
            await repository.dispose();
          }
        }
      }
      
      // Clear state
      _appConfigs.clear();
      _entityRegistrations.clear();
      _syncRepositories.clear();
      _appSyncStatus.clear();
      _isInitialized = false;
      
      developer.log('UnifiedSyncManager disposed', name: 'UnifiedSync');
    } catch (e) {
      developer.log('Error disposing UnifiedSyncManager: $e', name: 'UnifiedSync');
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
enum SyncAction {
  create,
  update,
  delete,
  sync,
  conflict,
  error,
}

/// Falha de inicialização
class InitializationFailure extends Failure {
  const InitializationFailure(String message) : super(message: message);
}