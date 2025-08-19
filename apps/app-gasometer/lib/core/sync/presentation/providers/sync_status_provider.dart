import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../models/sync_queue_item.dart';
import '../../services/sync_service.dart';

@injectable
class SyncStatusProvider extends ChangeNotifier {
  final SyncService _syncService;

  // Estado atual
  SyncStatus _status = SyncStatus.idle;
  String _message = '';
  List<SyncQueueItem> _queueItems = [];
  Map<String, dynamic> _stats = {};
  bool _isInitialized = false;

  // Subscriptions
  StreamSubscription<SyncStatus>? _statusSubscription;
  StreamSubscription<String>? _messageSubscription;
  StreamSubscription<List<SyncQueueItem>>? _queueSubscription;

  // Getters públicos
  SyncStatus get status => _status;
  String get message => _message;
  List<SyncQueueItem> get queueItems => _queueItems;
  Map<String, dynamic> get stats => _stats;
  bool get isInitialized => _isInitialized;

  // Getters de conveniência
  bool get isLoading => _status.isLoading;
  bool get hasError => _status.hasError;
  bool get isSuccess => _status.isSuccess;
  bool get isOffline => _status.isOffline;
  bool get hasQueueItems => _queueItems.isNotEmpty;
  int get pendingCount => _queueItems.length;

  SyncStatusProvider(this._syncService) {
    _initializeProvider();
  }

  /// Inicializa o provider e suas subscriptions
  Future<void> _initializeProvider() async {
    try {
      // Inicializa o SyncService se necessário
      if (!_syncService.isInitialized) {
        await _syncService.initialize();
      }

      // Setup subscriptions
      _statusSubscription = _syncService.statusStream.listen(_onStatusChanged);
      _messageSubscription = _syncService.messageStream.listen(_onMessageChanged);
      _queueSubscription = _syncService.queueStream.listen(_onQueueChanged);

      // Estado inicial
      _status = _syncService.currentStatus;
      _stats = _syncService.getSyncStats();
      _queueItems = _syncService.getAllQueueItems();
      _isInitialized = true;

      notifyListeners();
      debugPrint('✅ SyncStatusProvider inicializado');

    } catch (e) {
      debugPrint('❌ Erro ao inicializar SyncStatusProvider: $e');
      _status = SyncStatus.error;
      _message = 'Erro ao inicializar sincronização';
      notifyListeners();
    }
  }

  /// Força sincronização manual
  Future<void> forceSyncNow() async {
    try {
      await _syncService.forceSyncNow();
    } catch (e) {
      debugPrint('❌ Erro ao forçar sincronização: $e');
      _message = 'Erro ao sincronizar: $e';
      notifyListeners();
    }
  }

  /// Adiciona item à fila de sincronização
  Future<void> addToSyncQueue({
    required String modelType,
    required SyncOperationType operation,
    required Map<String, dynamic> data,
    String? userId,
    int priority = 0,
  }) async {
    try {
      await _syncService.addToSyncQueue(
        modelType: modelType,
        operation: operation,
        data: data,
        userId: userId,
        priority: priority,
      );
    } catch (e) {
      debugPrint('❌ Erro ao adicionar à fila: $e');
      _message = 'Erro ao adicionar à fila: $e';
      notifyListeners();
    }
  }

  /// Limpa todos os itens da fila
  Future<void> clearSyncQueue() async {
    await _syncService.clearSyncQueue();
    _updateStats();
  }

  /// Limpa apenas itens sincronizados
  Future<void> clearSyncedItems() async {
    await _syncService.clearSyncedItems();
    _updateStats();
  }

  /// Limpa itens que falharam
  Future<void> clearFailedItems() async {
    await _syncService.clearFailedItems();
    _updateStats();
  }

  /// Obtém itens pendentes por tipo
  List<SyncQueueItem> getPendingItemsByType(String modelType) {
    return _queueItems
        .where((item) => item.modelType == modelType && !item.isSynced)
        .toList();
  }

  /// Obtém estatísticas por tipo de modelo
  Map<String, int> getStatsByModelType() {
    final statsByType = <String, int>{};
    
    for (var item in _queueItems) {
      statsByType[item.modelType] = (statsByType[item.modelType] ?? 0) + 1;
    }
    
    return statsByType;
  }

  /// Verifica se há itens pendentes para um tipo específico
  bool hasPendingItemsForType(String modelType) {
    return _queueItems.any((item) => item.modelType == modelType && !item.isSynced);
  }

  /// Obtém contagem de itens por status
  Map<String, int> getItemsCountByStatus() {
    int pending = 0;
    int synced = 0;
    int failed = 0;
    int retrying = 0;

    for (var item in _queueItems) {
      if (item.isSynced) {
        synced++;
      } else if (!item.shouldRetry) {
        failed++;
      } else if (item.retryCount > 0) {
        retrying++;
      } else {
        pending++;
      }
    }

    return {
      'pending': pending,
      'synced': synced,
      'failed': failed,
      'retrying': retrying,
    };
  }

  /// Formatação de mensagem amigável baseada no status
  String get friendlyMessage {
    switch (_status) {
      case SyncStatus.idle:
        if (_queueItems.isEmpty) {
          return 'Todos os dados estão sincronizados';
        } else {
          return '${_queueItems.length} itens aguardando sincronização';
        }
      case SyncStatus.syncing:
        return _message.isNotEmpty ? _message : 'Sincronizando dados...';
      case SyncStatus.error:
        return _message.isNotEmpty ? _message : 'Erro na sincronização';
      case SyncStatus.success:
        return 'Sincronização concluída com sucesso';
      case SyncStatus.conflict:
        return 'Conflitos detectados - resolução necessária';
      case SyncStatus.offline:
        return 'Sem conexão - dados serão sincronizados quando voltar online';
    }
  }

  /// Cor indicativa do status atual
  String get statusColor {
    switch (_status) {
      case SyncStatus.idle:
        return _queueItems.isEmpty ? '#4CAF50' : '#FF9800'; // Verde ou Laranja
      case SyncStatus.syncing:
        return '#2196F3'; // Azul
      case SyncStatus.error:
        return '#F44336'; // Vermelho
      case SyncStatus.success:
        return '#4CAF50'; // Verde
      case SyncStatus.conflict:
        return '#FF5722'; // Vermelho escuro
      case SyncStatus.offline:
        return '#757575'; // Cinza
    }
  }

  /// Ícone indicativo do status atual
  String get statusIcon {
    switch (_status) {
      case SyncStatus.idle:
        return _queueItems.isEmpty ? '✅' : '⏳';
      case SyncStatus.syncing:
        return '🔄';
      case SyncStatus.error:
        return '❌';
      case SyncStatus.success:
        return '✅';
      case SyncStatus.conflict:
        return '⚠️';
      case SyncStatus.offline:
        return '📵';
    }
  }

  // Event handlers
  void _onStatusChanged(SyncStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _updateStats();
      notifyListeners();
      debugPrint('📊 Status sync UI atualizado: ${newStatus.name}');
    }
  }

  void _onMessageChanged(String newMessage) {
    if (_message != newMessage) {
      _message = newMessage;
      notifyListeners();
      debugPrint('💬 Mensagem sync UI: $newMessage');
    }
  }

  void _onQueueChanged(List<SyncQueueItem> newQueue) {
    _queueItems = newQueue;
    _updateStats();
    notifyListeners();
    debugPrint('📋 Fila sync UI atualizada: ${newQueue.length} itens');
  }

  void _updateStats() {
    _stats = _syncService.getSyncStats();
  }

  @override
  void dispose() {
    debugPrint('♻️ Disposing SyncStatusProvider...');
    
    _statusSubscription?.cancel();
    _messageSubscription?.cancel();
    _queueSubscription?.cancel();
    
    super.dispose();
    debugPrint('✅ SyncStatusProvider disposed');
  }
}