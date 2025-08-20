import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../models/sync_queue_item.dart';
import '../strategies/conflict_resolution_strategy.dart';
import 'sync_queue.dart';
import 'sync_operations.dart';
import 'conflict_resolver.dart';
import '../../services/analytics_service.dart';
import '../../data/models/base_sync_model.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';

enum SyncStatus {
  idle,
  syncing,
  error,
  success,
  conflict,
  offline
}

/// Serviço principal de sincronização que orquestra todas as operações
@singleton
class SyncService {
  final SyncQueue _syncQueue;
  final SyncOperations _syncOperations;
  final ConflictResolver _conflictResolver;
  final AnalyticsService _analytics;
  final AuthRepository _authRepository;

  final StreamController<SyncStatus> _statusController = 
      StreamController<SyncStatus>.broadcast();
  
  final StreamController<String> _messageController = 
      StreamController<String>.broadcast();

  Stream<SyncStatus> get statusStream => _statusController.stream;
  Stream<String> get messageStream => _messageController.stream;
  Stream<List<SyncQueueItem>> get queueStream => _syncQueue.queueStream;

  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Timer? _autoSyncTimer;
  static const Duration _autoSyncInterval = Duration(minutes: 5);

  SyncService(
    this._syncQueue,
    this._syncOperations,
    this._conflictResolver,
    this._analytics,
    this._authRepository,
  );

  /// Inicializa o serviço de sincronização
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 Inicializando SyncService...');
      
      await _syncQueue.initialize();
      _startAutoSync();
      
      _isInitialized = true;
      _updateStatus(SyncStatus.idle);
      _updateMessage('Serviço de sincronização inicializado');
      
      await _analytics.log('sync_service_initialized');
      debugPrint('✅ SyncService inicializado com sucesso');
      
    } catch (e) {
      debugPrint('❌ Erro ao inicializar SyncService: $e');
      _updateStatus(SyncStatus.error);
      _updateMessage('Erro ao inicializar sincronização: $e');
      await _analytics.recordError(e, null);
      rethrow;
    }
  }

  /// Adiciona um item à fila de sincronização
  Future<void> addToSyncQueue({
    required String modelType,
    required SyncOperationType operation,
    required Map<String, dynamic> data,
    String? userId,
    int priority = 0,
  }) async {
    try {
      await _syncQueue.addToQueue(
        modelType: modelType,
        operation: operation.name,
        data: data,
        userId: userId,
        priority: priority,
      );

      _updateMessage('${operation.name.toUpperCase()} adicionado à fila: $modelType');
      
      // Tenta sincronizar automaticamente se estiver online
      if (_syncOperations.isOnline && _currentStatus != SyncStatus.syncing) {
        unawaited(_performSync());
      }

    } catch (e) {
      debugPrint('❌ Erro ao adicionar à fila de sync: $e');
      await _analytics.recordError(e, null);
      rethrow;
    }
  }

  /// Força sincronização manual
  Future<void> forceSyncNow() async {
    if (!_isInitialized) {
      throw StateError('SyncService não foi inicializado');
    }

    if (_currentStatus == SyncStatus.syncing) {
      debugPrint('⏸️ Sync já em andamento, ignorando...');
      return;
    }

    debugPrint('🚀 Forçando sincronização manual...');
    await _performSync();
  }

  /// Executa sincronização
  Future<void> _performSync() async {
    if (!_syncOperations.isOnline) {
      _updateStatus(SyncStatus.offline);
      _updateMessage('Offline - aguardando conexão');
      return;
    }

    // Verificar autenticação antes de sincronizar
    final userResult = await _authRepository.getCurrentUser();
    final currentUser = userResult.fold(
      (failure) => null,
      (user) => user,
    );

    if (currentUser == null) {
      _updateStatus(SyncStatus.error);
      _updateMessage('Usuário não autenticado - sincronização cancelada');
      debugPrint('❌ Tentativa de sincronização sem usuário autenticado');
      await _analytics.recordError('sync_without_auth', null);
      return;
    }

    // Log tentativa de sincronização com user ID (apenas para debug em desenvolvimento)
    if (kDebugMode) {
      debugPrint('🔐 Iniciando sincronização para usuário: ${currentUser.id.substring(0, 8)}...');
    }

    _updateStatus(SyncStatus.syncing);
    _updateMessage('Sincronizando dados...');

    try {
      await _syncOperations.processOfflineQueue();
      
      final stats = _syncQueue.getQueueStats();
      
      if (stats['failed'] > 0) {
        _updateStatus(SyncStatus.error);
        _updateMessage('Alguns itens falharam na sincronização');
      } else if (stats['pending'] > 0) {
        _updateStatus(SyncStatus.syncing);
        _updateMessage('${stats['pending']} itens aguardando sincronização');
      } else {
        _updateStatus(SyncStatus.success);
        _updateMessage('Sincronização concluída com sucesso');
      }

    } catch (e) {
      debugPrint('❌ Erro durante sincronização: $e');
      _updateStatus(SyncStatus.error);
      _updateMessage('Erro na sincronização: $e');
      await _analytics.recordError(e, null);
    }
  }

  /// Inicia sincronização automática periódica
  void _startAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(_autoSyncInterval, (timer) {
      if (_syncOperations.isOnline && _currentStatus != SyncStatus.syncing) {
        unawaited(_performSync());
      }
    });
    debugPrint('⏰ Auto-sync iniciado (${_autoSyncInterval.inMinutes} min)');
  }

  /// Para sincronização automática
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    debugPrint('⏹️ Auto-sync parado');
  }

  /// Limpa todos os itens da fila
  Future<void> clearSyncQueue() async {
    await _syncQueue.clearAllItems();
    _updateMessage('Fila de sincronização limpa');
  }

  /// Limpa apenas itens sincronizados
  Future<void> clearSyncedItems() async {
    await _syncQueue.clearSyncedItems();
    _updateMessage('Itens sincronizados removidos');
  }

  /// Limpa itens que falharam
  Future<void> clearFailedItems() async {
    await _syncQueue.clearFailedItems();
    _updateMessage('Itens com falha removidos');
  }

  /// Obtém estatísticas de sincronização
  Map<String, dynamic> getSyncStats() {
    final queueStats = _syncQueue.getQueueStats();
    final connectivityStats = _syncOperations.getConnectivityStats();
    
    return {
      'status': _currentStatus.name,
      'is_initialized': _isInitialized,
      'auto_sync_enabled': _autoSyncTimer != null,
      ...queueStats,
      ...connectivityStats,
    };
  }

  /// Obtém itens pendentes por tipo
  List<SyncQueueItem> getPendingItemsByType(String modelType) {
    return _syncQueue.getItemsByModelType(modelType);
  }

  /// Obtém todos os itens da fila
  List<SyncQueueItem> getAllQueueItems() {
    return _syncQueue.getAllItems();
  }

  /// Verifica se há conflitos pendentes
  bool hasConflicts() {
    // TODO: Implementar verificação de conflitos reais
    return false;
  }

  /// Resolve conflito com estratégia específica
  Future<void> resolveConflict<T extends BaseSyncModel>({
    required T localEntity,
    required T remoteEntity,
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.newerWins,
  }) async {
    try {
      final conflictData = _conflictResolver.getConflictData(localEntity, remoteEntity);
      _conflictResolver.resolveConflict(
        conflictData,
        strategy: strategy,
      );

      // TODO: Salvar entidade resolvida no repository apropriado
      
      _updateMessage('Conflito resolvido: ${strategy.displayName}');
      await _analytics.log('conflict_resolved');

    } catch (e) {
      debugPrint('❌ Erro ao resolver conflito: $e');
      await _analytics.recordError(e, null);
      rethrow;
    }
  }

  /// Atualiza status e notifica listeners
  void _updateStatus(SyncStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      if (!_statusController.isClosed) {
        _statusController.add(status);
      }
      debugPrint('📊 Status sync: ${status.name}');
    }
  }

  /// Atualiza mensagem e notifica listeners
  void _updateMessage(String message) {
    if (!_messageController.isClosed) {
      _messageController.add(message);
    }
    debugPrint('💬 Sync message: $message');
  }

  /// Dispose de recursos
  Future<void> dispose() async {
    debugPrint('♻️ Disposing SyncService...');
    
    _autoSyncTimer?.cancel();
    _syncOperations.dispose();
    
    await _statusController.close();
    await _messageController.close();
    await _syncQueue.dispose();
    
    _isInitialized = false;
    debugPrint('✅ SyncService disposed');
  }
}

extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.idle:
        return 'Aguardando';
      case SyncStatus.syncing:
        return 'Sincronizando';
      case SyncStatus.error:
        return 'Erro';
      case SyncStatus.success:
        return 'Sucesso';
      case SyncStatus.conflict:
        return 'Conflito';
      case SyncStatus.offline:
        return 'Offline';
    }
  }

  bool get isLoading => this == SyncStatus.syncing;
  bool get hasError => this == SyncStatus.error;
  bool get isSuccess => this == SyncStatus.success;
  bool get isOffline => this == SyncStatus.offline;
}