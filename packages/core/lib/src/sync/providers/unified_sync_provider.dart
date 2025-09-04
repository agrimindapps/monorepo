import 'dart:async';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/widgets.dart';

import '../../domain/entities/base_sync_entity.dart';
import '../../domain/repositories/i_sync_repository.dart';
import '../../shared/utils/failure.dart';
import '../unified_sync_manager.dart';

/// Provider unificado para sincronização que integra com Flutter
/// Fornece interface reativa para UI através de ChangeNotifier
class UnifiedSyncProvider extends ChangeNotifier {
  UnifiedSyncProvider._internal();
  
  static final UnifiedSyncProvider _instance = UnifiedSyncProvider._internal();
  static UnifiedSyncProvider get instance => _instance;

  // Estado do provider
  String? _currentAppName;
  bool _isInitialized = false;
  Map<String, SyncStatus> _appSyncStatuses = {};
  
  // Streams e subscriptions
  StreamSubscription<Map<String, SyncStatus>>? _globalStatusSubscription;
  StreamSubscription<AppSyncEvent>? _syncEventSubscription;
  
  // Cache de streams por entidade (para performance)
  final Map<String, StreamController<List<dynamic>>> _entityStreamControllers = {};
  final Map<String, StreamSubscription<List<dynamic>>> _entityStreamSubscriptions = {};
  final Map<String, List<dynamic>> _entityCaches = {};

  /// Inicializa o provider para um app específico
  Future<void> initializeForApp(String appName) async {
    if (_currentAppName == appName && _isInitialized) return;

    _currentAppName = appName;
    
    // Setup listeners globais (apenas uma vez)
    if (!_isInitialized) {
      _setupGlobalListeners();
      _isInitialized = true;
    }
    
    developer.log('UnifiedSyncProvider initialized for: $appName', name: 'SyncProvider');
    notifyListeners();
  }

  /// Cria uma nova entidade
  Future<Either<Failure, String>> create<T extends BaseSyncEntity>(T entity) async {
    if (_currentAppName == null) {
      return const Left(InitializationFailure('Provider not initialized with app name'));
    }

    try {
      final result = await UnifiedSyncManager.instance.create<T>(_currentAppName!, entity);
      
      if (result.isRight()) {
        // Atualizar cache local
        _invalidateEntityCache<T>();
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      developer.log('Error creating entity: $e', name: 'SyncProvider');
      return Left(CacheFailure('Error creating entity: $e'));
    }
  }

  /// Cria múltiplas entidades em lote
  Future<Either<Failure, List<String>>> createBatch<T extends BaseSyncEntity>(
    List<T> entities,
  ) async {
    if (_currentAppName == null || entities.isEmpty) {
      return const Left(InitializationFailure('Provider not initialized or empty entities'));
    }

    try {
      final futures = entities.map((entity) => create<T>(entity)).toList();
      final results = await Future.wait(futures);
      
      final ids = <String>[];
      for (final result in results) {
        result.fold(
          (failure) => throw Exception(failure.message),
          (id) => ids.add(id),
        );
      }
      
      return Right(ids);
    } catch (e) {
      developer.log('Error creating entities batch: $e', name: 'SyncProvider');
      return Left(CacheFailure('Error creating entities batch: $e'));
    }
  }

  /// Atualiza uma entidade existente
  Future<Either<Failure, void>> update<T extends BaseSyncEntity>(
    String id,
    T entity,
  ) async {
    if (_currentAppName == null) {
      return const Left(InitializationFailure('Provider not initialized with app name'));
    }

    try {
      final result = await UnifiedSyncManager.instance.update<T>(_currentAppName!, id, entity);
      
      if (result.isRight()) {
        _invalidateEntityCache<T>();
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      developer.log('Error updating entity: $e', name: 'SyncProvider');
      return Left(CacheFailure('Error updating entity: $e'));
    }
  }

  /// Remove uma entidade (soft delete)
  Future<Either<Failure, void>> delete<T extends BaseSyncEntity>(String id) async {
    if (_currentAppName == null) {
      return const Left(InitializationFailure('Provider not initialized with app name'));
    }

    try {
      final result = await UnifiedSyncManager.instance.delete<T>(_currentAppName!, id);
      
      if (result.isRight()) {
        _invalidateEntityCache<T>();
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      developer.log('Error deleting entity: $e', name: 'SyncProvider');
      return Left(CacheFailure('Error deleting entity: $e'));
    }
  }

  /// Busca uma entidade por ID
  Future<Either<Failure, T?>> findById<T extends BaseSyncEntity>(String id) async {
    if (_currentAppName == null) {
      return const Left(InitializationFailure('Provider not initialized with app name'));
    }

    try {
      return await UnifiedSyncManager.instance.findById<T>(_currentAppName!, id);
    } catch (e) {
      developer.log('Error finding entity by ID: $e', name: 'SyncProvider');
      return Left(CacheFailure('Error finding entity by ID: $e'));
    }
  }

  /// Busca todas as entidades de um tipo
  Future<Either<Failure, List<T>>> findAll<T extends BaseSyncEntity>() async {
    if (_currentAppName == null) {
      return const Left(InitializationFailure('Provider not initialized with app name'));
    }

    try {
      final result = await UnifiedSyncManager.instance.findAll<T>(_currentAppName!);
      
      // Atualizar cache
      result.fold(
        (failure) => null,
        (entities) => _updateEntityCache<T>(entities),
      );
      
      return result;
    } catch (e) {
      developer.log('Error finding all entities: $e', name: 'SyncProvider');
      return Left(CacheFailure('Error finding all entities: $e'));
    }
  }

  /// Busca entidades com filtros
  Future<Either<Failure, List<T>>> findWhere<T extends BaseSyncEntity>(
    Map<String, dynamic> filters,
  ) async {
    if (_currentAppName == null) {
      return const Left(InitializationFailure('Provider not initialized with app name'));
    }

    try {
      return await UnifiedSyncManager.instance.findWhere<T>(_currentAppName!, filters);
    } catch (e) {
      developer.log('Error finding entities with filters: $e', name: 'SyncProvider');
      return Left(CacheFailure('Error finding entities with filters: $e'));
    }
  }

  /// Stream reativo de entidades (para uso com StreamBuilder)
  Stream<List<T>> streamAll<T extends BaseSyncEntity>() {
    if (_currentAppName == null) {
      return Stream.error(const InitializationFailure('Provider not initialized'));
    }

    final entityKey = '${_currentAppName!}_${T.toString()}';
    
    // Reutilizar stream existente se já existe
    if (_entityStreamControllers.containsKey(entityKey)) {
      return _entityStreamControllers[entityKey]!.stream.cast<List<T>>();
    }

    return _createEntityStream<T>(entityKey);
  }

  /// Cria um novo stream para uma entidade específica
  Stream<List<T>> _createEntityStream<T extends BaseSyncEntity>(String entityKey) {
    // Criar novo stream controller (será fechado em dispose e cleanup)
    // ignore: close_sinks
    final controller = StreamController<List<dynamic>>.broadcast(
      onCancel: () {
        // Cleanup automático quando não há mais listeners
        _cleanupEntityStream(entityKey);
      },
    );
    
    _entityStreamControllers[entityKey] = controller;

    // Conectar ao stream do UnifiedSyncManager
    final managerStream = UnifiedSyncManager.instance.streamAll<T>(_currentAppName!);
    if (managerStream != null) {
      // Subscription será cancelada em dispose e cleanup
      // ignore: cancel_subscriptions  
      final subscription = managerStream.listen(
        (entities) {
          _updateEntityCache<T>(entities);
          if (!controller.isClosed) {
            controller.add(entities);
          }
        },
        onError: (Object error) {
          developer.log('Error in entity stream: $error', name: 'SyncProvider');
          if (!controller.isClosed) {
            controller.addError(error);
          }
        },
      );
      
      // Armazenar subscription para cleanup posterior
      _entityStreamSubscriptions[entityKey] = subscription;
    }

    return controller.stream.cast<List<T>>();
  }

  /// Limpa recursos de um stream específico
  void _cleanupEntityStream(String entityKey) {
    // Cancelar subscription
    final subscription = _entityStreamSubscriptions.remove(entityKey);
    subscription?.cancel();
    
    // Fechar e remover controller
    final controller = _entityStreamControllers.remove(entityKey);
    if (controller != null && !controller.isClosed) {
      controller.close();
    }
  }

  /// Força sincronização de todas as entidades do app atual
  Future<Either<Failure, void>> forceSync() async {
    if (_currentAppName == null) {
      return const Left(InitializationFailure('Provider not initialized with app name'));
    }

    try {
      final result = await UnifiedSyncManager.instance.forceSyncApp(_currentAppName!);
      
      if (result.isRight()) {
        // Invalidar todos os caches para forçar reload
        _invalidateAllCaches();
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      developer.log('Error forcing sync: $e', name: 'SyncProvider');
      return Left(SyncFailure('Error forcing sync: $e'));
    }
  }

  /// Força sincronização de um tipo específico de entidade
  Future<Either<Failure, void>> forceSyncEntity<T extends BaseSyncEntity>() async {
    if (_currentAppName == null) {
      return const Left(InitializationFailure('Provider not initialized with app name'));
    }

    try {
      final result = await UnifiedSyncManager.instance.forceSyncEntity<T>(_currentAppName!);
      
      if (result.isRight()) {
        _invalidateEntityCache<T>();
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      developer.log('Error forcing entity sync: $e', name: 'SyncProvider');
      return Left(SyncFailure('Error forcing entity sync: $e'));
    }
  }

  /// Status de sincronização do app atual
  SyncStatus get syncStatus {
    return _currentAppName != null 
        ? (_appSyncStatuses[_currentAppName!] ?? SyncStatus.offline)
        : SyncStatus.offline;
  }

  /// Status de sincronização de todos os apps
  Map<String, SyncStatus> get allAppSyncStatuses => Map.unmodifiable(_appSyncStatuses);

  /// Stream de status de sincronização
  Stream<SyncStatus> get syncStatusStream {
    if (_currentAppName == null) {
      return Stream.value(SyncStatus.offline);
    }
    
    return UnifiedSyncManager.instance.globalSyncStatusStream
        .map((statuses) => statuses[_currentAppName!] ?? SyncStatus.offline);
  }

  /// Stream de eventos de sincronização
  Stream<AppSyncEvent> get syncEventStream {
    if (_currentAppName == null) {
      return const Stream.empty();
    }
    
    return UnifiedSyncManager.instance.syncEventStream
        .where((event) => event.appName == _currentAppName!);
  }

  /// Obtém entidades do cache (não faz consulta ao banco)
  List<T>? getCachedEntities<T extends BaseSyncEntity>() {
    final entityKey = '${_currentAppName}_${T.toString()}';
    final cached = _entityCaches[entityKey];
    return cached?.cast<T>();
  }

  /// Verifica se uma entidade está no cache
  bool hasCache<T extends BaseSyncEntity>() {
    final entityKey = '${_currentAppName}_${T.toString()}';
    return _entityCaches.containsKey(entityKey);
  }

  /// Limpa cache de uma entidade específica
  void clearCache<T extends BaseSyncEntity>() {
    _invalidateEntityCache<T>();
  }

  /// Limpa todos os caches
  void clearAllCaches() {
    _invalidateAllCaches();
  }

  /// Informações de debug do app atual
  Map<String, dynamic> get debugInfo {
    if (_currentAppName == null) {
      return {'error': 'Provider not initialized'};
    }
    
    return {
      ...UnifiedSyncManager.instance.getAppDebugInfo(_currentAppName!),
      'provider_info': {
        'current_app': _currentAppName,
        'is_initialized': _isInitialized,
        'cached_entities': _entityCaches.keys.toList(),
        'active_streams': _entityStreamControllers.keys.toList(),
      },
    };
  }

  // Métodos privados

  void _setupGlobalListeners() {
    // Listener para status global
    _globalStatusSubscription = UnifiedSyncManager.instance.globalSyncStatusStream.listen(
      (statuses) {
        _appSyncStatuses = Map.from(statuses);
        notifyListeners();
      },
      onError: (Object error) {
        developer.log('Error in global status stream: $error', name: 'SyncProvider');
      },
    );

    // Listener para eventos de sync
    _syncEventSubscription = UnifiedSyncManager.instance.syncEventStream.listen(
      (event) {
        developer.log('Sync event: ${event.toString()}', name: 'SyncProvider');
        
        // Invalidar cache da entidade que foi alterada
        final entityKey = '${event.appName}_${event.entityType.toString()}';
        _entityCaches.remove(entityKey);
        
        notifyListeners();
      },
      onError: (Object error) {
        developer.log('Error in sync event stream: $error', name: 'SyncProvider');
      },
    );
  }

  void _updateEntityCache<T>(List<T> entities) {
    final entityKey = '${_currentAppName}_${T.toString()}';
    _entityCaches[entityKey] = entities;
  }

  void _invalidateEntityCache<T>() {
    final entityKey = '${_currentAppName}_${T.toString()}';
    _entityCaches.remove(entityKey);
    
    // Cancelar subscription se existir
    final subscription = _entityStreamSubscriptions[entityKey];
    if (subscription != null) {
      subscription.cancel();
      _entityStreamSubscriptions.remove(entityKey);
    }
    
    // Também fechar stream controller se existir
    final controller = _entityStreamControllers[entityKey];
    if (controller != null && !controller.isClosed) {
      controller.close();
      _entityStreamControllers.remove(entityKey);
    }
  }

  void _invalidateAllCaches() {
    _entityCaches.clear();
    
    // Cancelar todas as subscriptions
    for (final subscription in _entityStreamSubscriptions.values) {
      subscription.cancel();
    }
    _entityStreamSubscriptions.clear();
    
    // Fechar todos os stream controllers
    final futures = <Future<void>>[];
    for (final controller in _entityStreamControllers.values) {
      if (!controller.isClosed) {
        futures.add(controller.close());
      }
    }
    _entityStreamControllers.clear();
  }

  @override
  void dispose() {
    // Cancel global subscriptions
    _globalStatusSubscription?.cancel();
    _syncEventSubscription?.cancel();
    
    // Cancel entity subscriptions
    for (final subscription in _entityStreamSubscriptions.values) {
      subscription.cancel();
    }
    _entityStreamSubscriptions.clear();
    
    // Close all stream controllers
    for (final controller in _entityStreamControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    
    // Clear state
    _entityStreamControllers.clear();
    _entityCaches.clear();
    _appSyncStatuses.clear();
    _isInitialized = false;
    _currentAppName = null;
    
    super.dispose();
    
    developer.log('UnifiedSyncProvider disposed', name: 'SyncProvider');
  }
}

/// Extension para facilitar uso com Provider package
extension UnifiedSyncProviderContext on UnifiedSyncProvider {
  /// Configuração rápida para usar com Provider.of(context)
  static UnifiedSyncProvider of(BuildContext context) {
    try {
      // Se estiver usando o provider package, use Provider.of
      // return Provider.of<UnifiedSyncProvider>(context, listen: false);
      
      // Por enquanto, retornar instância singleton
      return UnifiedSyncProvider.instance;
    } catch (e) {
      developer.log('Provider not found in context, returning singleton: $e', name: 'SyncProvider');
      return UnifiedSyncProvider.instance;
    }
  }

  /// Configuração rápida para usar com Provider.of(context) que escuta mudanças
  static UnifiedSyncProvider watchOf(BuildContext context) {
    try {
      // Se estiver usando o provider package
      // return Provider.of<UnifiedSyncProvider>(context, listen: true);
      
      // Por enquanto, retornar instância singleton
      return UnifiedSyncProvider.instance;
    } catch (e) {
      developer.log('Provider not found in context, returning singleton: $e', name: 'SyncProvider');
      return UnifiedSyncProvider.instance;
    }
  }
}

/// Mixin para widgets que usam sync
mixin SyncProviderMixin<T extends StatefulWidget> on State<T> {
  UnifiedSyncProvider? _syncProvider;

  /// Getter para acessar o sync provider
  UnifiedSyncProvider get syncProvider {
    _syncProvider ??= UnifiedSyncProvider.instance;
    return _syncProvider!;
  }

  /// Inicializa sync provider para o app
  @protected
  Future<void> initializeSyncProvider(String appName) async {
    await syncProvider.initializeForApp(appName);
  }

  /// Shortcut para criar entidade
  @protected
  Future<Either<Failure, String>> createEntity<E extends BaseSyncEntity>(E entity) {
    return syncProvider.create<E>(entity);
  }

  /// Shortcut para atualizar entidade
  @protected
  Future<Either<Failure, void>> updateEntity<E extends BaseSyncEntity>(String id, E entity) {
    return syncProvider.update<E>(id, entity);
  }

  /// Shortcut para deletar entidade
  @protected
  Future<Either<Failure, void>> deleteEntity<E extends BaseSyncEntity>(String id) {
    return syncProvider.delete<E>(id);
  }

  /// Shortcut para stream de entidades
  @protected
  Stream<List<E>> streamEntities<E extends BaseSyncEntity>() {
    return syncProvider.streamAll<E>();
  }

  @override
  void dispose() {
    _syncProvider = null;
    super.dispose();
  }
}