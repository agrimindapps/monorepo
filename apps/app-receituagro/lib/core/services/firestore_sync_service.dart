import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

/// Serviço de sincronização bidirecional com Firestore
class FirestoreSyncService {
  FirestoreSyncService({
    required this.firestore,
    required this.functions,
    required this.storage,
    required this.deviceService,
    required this.analytics,
  });

  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;
  final HiveStorageService storage;
  final DeviceIdentityService deviceService;
  final AnalyticsService analytics;

  // Queue de operações offline
  final List<SyncOperation> _pendingOperations = [];
  
  // Controladores de stream
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  final _conflictsController = StreamController<List<SyncConflict>>.broadcast();
  
  // Estado interno
  bool _isOnline = false;
  bool _isSyncing = false;
  Timer? _periodicSyncTimer;
  Timer? _retryTimer;
  String? _deviceId;
  DateTime? _lastSyncTimestamp;

  // Configurações
  static const Duration _syncInterval = Duration(minutes: 5);
  static const Duration _retryDelay = Duration(seconds: 30);
  static const int _maxRetries = 3;
  static const int _batchSize = 50;

  /// Stream do status de sincronização
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Stream de conflitos pendentes
  Stream<List<SyncConflict>> get conflictsStream => _conflictsController.stream;

  /// Inicializa o serviço de sincronização
  Future<void> initialize() async {
    try {
      // Obter ID do dispositivo
      _deviceId = await deviceService.getDeviceUuid();
      
      // Carregar timestamp do último sync
      _lastSyncTimestamp = await _loadLastSyncTimestamp();
      
      // Configurar monitoramento de conectividade
      await _setupConnectivityMonitoring();
      
      // Configurar sync periódico
      _setupPeriodicSync();
      
      // Processar operações pendentes
      await _processPendingOperations();
      
      analytics.logEvent('sync_service_initialized', parameters: {
        'device_id': _deviceId,
        'last_sync': _lastSyncTimestamp?.toIso8601String(),
      });
      
      _updateSyncStatus(SyncStatus.idle());
      
    } catch (e) {
      analytics.logError('sync_service_initialization_failed', e, null);
      _updateSyncStatus(SyncStatus.error('Failed to initialize sync service'));
      rethrow;
    }
  }

  /// Configura monitoramento de conectividade
  Future<void> _setupConnectivityMonitoring() async {
    final connectivity = Connectivity();
    
    // Estado inicial
    final initialResult = await connectivity.checkConnectivity();
    _isOnline = initialResult != ConnectivityResult.none;
    
    // Monitorar mudanças
    connectivity.onConnectivityChanged.listen((ConnectivityResult result) async {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      if (!wasOnline && _isOnline) {
        // Voltou online - tentar sincronizar
        analytics.logEvent('connectivity_restored');
        await _attemptSync();
      } else if (wasOnline && !_isOnline) {
        // Perdeu conectividade
        analytics.logEvent('connectivity_lost');
        _updateSyncStatus(SyncStatus.offline());
      }
    });
  }

  /// Configura sincronização periódica
  void _setupPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(_syncInterval, (timer) async {
      if (_isOnline && !_isSyncing) {
        await _attemptSync();
      }
    });
  }

  /// Adiciona operação à queue de sincronização
  Future<void> queueOperation(SyncOperation operation) async {
    try {
      // Adicionar à queue em memória
      _pendingOperations.add(operation);
      
      // Persistir localmente para resistir a crashes
      await _persistOperation(operation);
      
      analytics.logEvent('sync_operation_queued', parameters: {
        'operation_type': operation.operation.name,
        'collection': operation.collection,
        'queue_size': _pendingOperations.length.toString(),
      });
      
      // Tentar sincronizar imediatamente se online
      if (_isOnline && !_isSyncing) {
        await _attemptSync();
      }
      
    } catch (e) {
      analytics.logError('sync_operation_queue_failed', e, {
        'operation_id': operation.id,
        'collection': operation.collection,
      });
    }
  }

  /// Sincronização manual (pull-to-refresh)
  Future<SyncResult> syncNow({bool force = false}) async {
    if (!_isOnline) {
      return SyncResult.error('No internet connection');
    }

    if (_isSyncing && !force) {
      return SyncResult.error('Sync already in progress');
    }

    return await _performSync();
  }

  /// Executa sincronização bidirecional
  Future<SyncResult> _performSync() async {
    if (_isSyncing) return SyncResult.error('Sync already in progress');
    
    _isSyncing = true;
    _updateSyncStatus(SyncStatus.syncing());
    
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await _executeBidirectionalSync();
      
      stopwatch.stop();
      analytics.logEvent('sync_completed', parameters: {
        'duration_ms': stopwatch.elapsedMilliseconds.toString(),
        'operations_sent': result.operationsSent.toString(),
        'operations_received': result.operationsReceived.toString(),
        'conflicts_detected': result.conflicts.length.toString(),
      });
      
      _updateSyncStatus(SyncStatus.idle(lastSync: DateTime.now()));
      
      // Notificar conflitos se houver
      if (result.conflicts.isNotEmpty) {
        _conflictsController.add(result.conflicts);
      }
      
      return result;
      
    } catch (e) {
      stopwatch.stop();
      analytics.logError('sync_failed', e, {
        'duration_ms': stopwatch.elapsedMilliseconds.toString(),
        'pending_operations': _pendingOperations.length.toString(),
      });
      
      _updateSyncStatus(SyncStatus.error('Sync failed: ${e.toString()}'));
      return SyncResult.error(e.toString());
    } finally {
      _isSyncing = false;
    }
  }

  /// Executa sincronização bidirecional completa
  Future<SyncResult> _executeBidirectionalSync() async {
    // 1. Preparar operações para envio
    final operationsToSend = List<SyncOperation>.from(_pendingOperations);
    
    // 2. Determinar coleções para sincronizar
    final collectionsToSync = _getCollectionsToSync();
    
    // 3. Executar sincronização via Cloud Function
    final HttpsCallable syncFunction = functions.httpsCallable('syncUserData');
    
    final response = await syncFunction.call({
      'operations': operationsToSend.map((op) => op.toMap()).toList(),
      'deviceId': _deviceId,
      'collections': collectionsToSync,
      'lastSyncTimestamp': _lastSyncTimestamp?.millisecondsSinceEpoch,
    });
    
    final data = response.data as Map<String, dynamic>;
    
    if (data['success'] != true) {
      throw Exception('Server sync failed: ${data['message']}');
    }
    
    // 4. Processar operações recebidas do servidor
    final serverOperations = (data['serverOperations'] as List? ?? [])
        .map((op) => SyncOperation.fromMap(op as Map<String, dynamic>))
        .toList();
    
    // 5. Processar conflitos
    final conflicts = (data['conflicts'] as List? ?? [])
        .map((conflict) => SyncConflict.fromMap(conflict as Map<String, dynamic>))
        .toList();
    
    // 6. Aplicar operações do servidor localmente
    await _applyServerOperations(serverOperations);
    
    // 7. Limpar operações processadas com sucesso
    _pendingOperations.clear();
    await _clearPersistedOperations();
    
    // 8. Salvar timestamp do último sync
    _lastSyncTimestamp = DateTime.now();
    await _saveLastSyncTimestamp(_lastSyncTimestamp!);
    
    return SyncResult(
      success: true,
      operationsSent: operationsToSend.length,
      operationsReceived: serverOperations.length,
      conflicts: conflicts,
      timestamp: _lastSyncTimestamp!,
    );
  }

  /// Aplica operações recebidas do servidor localmente
  Future<void> _applyServerOperations(List<SyncOperation> operations) async {
    for (final operation in operations) {
      try {
        await _applyLocalOperation(operation);
      } catch (e) {
        analytics.logError('server_operation_apply_failed', e, {
          'operation_id': operation.id,
          'operation_type': operation.operation.name,
          'collection': operation.collection,
        });
      }
    }
  }

  /// Aplica uma operação localmente no Hive
  Future<void> _applyLocalOperation(SyncOperation operation) async {
    final box = await storage.openBox(operation.collection);
    
    switch (operation.operation) {
      case SyncOperationType.create:
      case SyncOperationType.update:
        await box.put(operation.id, operation.data);
        break;
        
      case SyncOperationType.delete:
        await box.delete(operation.id);
        break;
    }
  }

  /// Obtém coleções que devem ser sincronizadas
  List<String> _getCollectionsToSync() {
    // Baseado na configuração do ReceitaAgroSyncManager
    return [
      'receituagro_user_favorites',
      'receituagro_user_comments',
      'receituagro_user_settings',
      'receituagro_user_diagnostic_history',
      'receituagro_user_notes',
    ];
  }

  /// Resolve conflito específico
  Future<void> resolveConflict(String conflictId, ConflictResolution resolution) async {
    try {
      final HttpsCallable resolveFunction = functions.httpsCallable('resolveConflicts');
      
      final response = await resolveFunction.call({
        'conflictId': conflictId,
        'resolution': resolution.toMap(),
      });
      
      if (response.data['success'] == true) {
        analytics.logEvent('conflict_resolved', parameters: {
          'conflict_id': conflictId,
          'resolution_strategy': resolution.strategy.name,
        });
        
        // Atualizar dados locais se necessário
        final finalData = response.data['finalData'];
        if (finalData != null) {
          // Aplicar dados resolvidos localmente
          // await _applyResolvedData(conflictId, finalData);
        }
      }
      
    } catch (e) {
      analytics.logError('conflict_resolution_failed', e, {
        'conflict_id': conflictId,
      });
      rethrow;
    }
  }

  /// Tenta sincronizar com retry automático
  Future<void> _attemptSync() async {
    int retryCount = 0;
    
    while (retryCount < _maxRetries && _isOnline) {
      try {
        await _performSync();
        _retryTimer?.cancel();
        return;
      } catch (e) {
        retryCount++;
        
        if (retryCount >= _maxRetries) {
          analytics.logError('sync_max_retries_reached', e, {
            'retry_count': retryCount.toString(),
          });
          _updateSyncStatus(SyncStatus.error('Max retries reached'));
          return;
        }
        
        // Aguardar antes de tentar novamente
        await Future.delayed(_retryDelay * retryCount);
      }
    }
  }

  /// Persiste operação localmente
  Future<void> _persistOperation(SyncOperation operation) async {
    final operationsBox = await storage.openBox('sync_pending_operations');
    await operationsBox.put(operation.id, operation.toMap());
  }

  /// Carrega operações persistidas
  Future<void> _processPendingOperations() async {
    try {
      final operationsBox = await storage.openBox('sync_pending_operations');
      
      for (final key in operationsBox.keys) {
        final operationData = operationsBox.get(key) as Map<String, dynamic>?;
        if (operationData != null) {
          final operation = SyncOperation.fromMap(operationData);
          _pendingOperations.add(operation);
        }
      }
      
      analytics.logEvent('pending_operations_loaded', parameters: {
        'count': _pendingOperations.length.toString(),
      });
      
    } catch (e) {
      analytics.logError('pending_operations_load_failed', e, null);
    }
  }

  /// Limpa operações persistidas
  Future<void> _clearPersistedOperations() async {
    final operationsBox = await storage.openBox('sync_pending_operations');
    await operationsBox.clear();
  }

  /// Carrega timestamp do último sync
  Future<DateTime?> _loadLastSyncTimestamp() async {
    final settingsBox = await storage.openBox('sync_settings');
    final timestamp = settingsBox.get('last_sync_timestamp') as int?;
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Salva timestamp do último sync
  Future<void> _saveLastSyncTimestamp(DateTime timestamp) async {
    final settingsBox = await storage.openBox('sync_settings');
    await settingsBox.put('last_sync_timestamp', timestamp.millisecondsSinceEpoch);
  }

  /// Atualiza status de sincronização
  void _updateSyncStatus(SyncStatus status) {
    _syncStatusController.add(status);
  }

  /// Obtém estatísticas de sincronização
  Future<SyncStats> getStats() async {
    return SyncStats(
      lastSyncTimestamp: _lastSyncTimestamp,
      pendingOperations: _pendingOperations.length,
      isOnline: _isOnline,
      isSyncing: _isSyncing,
    );
  }

  /// Limpa todos os dados de sincronização
  Future<void> clearSyncData() async {
    _pendingOperations.clear();
    await _clearPersistedOperations();
    
    final settingsBox = await storage.openBox('sync_settings');
    await settingsBox.clear();
    
    _lastSyncTimestamp = null;
    
    analytics.logEvent('sync_data_cleared');
    _updateSyncStatus(SyncStatus.idle());
  }

  /// Dispose dos recursos
  void dispose() {
    _periodicSyncTimer?.cancel();
    _retryTimer?.cancel();
    _syncStatusController.close();
    _conflictsController.close();
  }
}

// Modelos de dados para sincronização

enum SyncOperationType { create, update, delete }

class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.collection,
    required this.operation,
    required this.timestamp,
    this.data,
  });

  final String id;
  final String collection;
  final SyncOperationType operation;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  Map<String, dynamic> toMap() => {
    'id': id,
    'collection': collection,
    'operation': operation.name,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'data': data,
  };

  static SyncOperation fromMap(Map<String, dynamic> map) => SyncOperation(
    id: map['id'] as String,
    collection: map['collection'] as String,
    operation: SyncOperationType.values.byName(map['operation'] as String),
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    data: map['data'] as Map<String, dynamic>?,
  );
}

class SyncStatus {
  const SyncStatus._({
    required this.state,
    this.message,
    this.lastSync,
    this.progress,
  });

  final SyncState state;
  final String? message;
  final DateTime? lastSync;
  final double? progress;

  factory SyncStatus.idle({DateTime? lastSync}) => SyncStatus._(
    state: SyncState.idle,
    lastSync: lastSync,
  );

  factory SyncStatus.syncing({double? progress}) => SyncStatus._(
    state: SyncState.syncing,
    progress: progress,
  );

  factory SyncStatus.offline() => SyncStatus._(
    state: SyncState.offline,
    message: 'No internet connection',
  );

  factory SyncStatus.error(String message) => SyncStatus._(
    state: SyncState.error,
    message: message,
  );
}

enum SyncState { idle, syncing, offline, error }

class SyncResult {
  const SyncResult({
    required this.success,
    required this.operationsSent,
    required this.operationsReceived,
    required this.conflicts,
    required this.timestamp,
    this.message,
  });

  final bool success;
  final int operationsSent;
  final int operationsReceived;
  final List<SyncConflict> conflicts;
  final DateTime timestamp;
  final String? message;

  factory SyncResult.error(String message) => SyncResult(
    success: false,
    operationsSent: 0,
    operationsReceived: 0,
    conflicts: [],
    timestamp: DateTime.now(),
    message: message,
  );
}

class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.collection,
    required this.documentId,
    required this.conflictType,
    required this.clientData,
    required this.serverData,
    required this.clientTimestamp,
    required this.serverTimestamp,
  });

  final String id;
  final String collection;
  final String documentId;
  final String conflictType;
  final Map<String, dynamic> clientData;
  final Map<String, dynamic> serverData;
  final DateTime clientTimestamp;
  final DateTime serverTimestamp;

  static SyncConflict fromMap(Map<String, dynamic> map) => SyncConflict(
    id: map['id'] as String,
    collection: map['collection'] as String,
    documentId: map['documentId'] as String,
    conflictType: map['conflictType'] as String,
    clientData: map['clientData'] as Map<String, dynamic>,
    serverData: map['serverData'] as Map<String, dynamic>,
    clientTimestamp: DateTime.fromMillisecondsSinceEpoch(map['clientTimestamp'] as int),
    serverTimestamp: DateTime.fromMillisecondsSinceEpoch(map['serverTimestamp'] as int),
  );
}

enum ConflictStrategy { lastWriteWins, userGuided, merge }

class ConflictResolution {
  const ConflictResolution({
    required this.strategy,
    this.keepLocal,
    this.keepRemote,
    this.mergeFields,
  });

  final ConflictStrategy strategy;
  final bool? keepLocal;
  final bool? keepRemote;
  final List<String>? mergeFields;

  Map<String, dynamic> toMap() => {
    'strategy': strategy.name,
    'keepLocal': keepLocal,
    'keepRemote': keepRemote,
    'mergeFields': mergeFields,
  };
}

class SyncStats {
  const SyncStats({
    required this.lastSyncTimestamp,
    required this.pendingOperations,
    required this.isOnline,
    required this.isSyncing,
  });

  final DateTime? lastSyncTimestamp;
  final int pendingOperations;
  final bool isOnline;
  final bool isSyncing;
}