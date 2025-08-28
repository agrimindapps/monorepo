import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../services/analytics_service.dart';
import '../models/sync_queue_item.dart';
import 'sync_queue.dart';

enum NetworkStatus { offline, wifi, mobile, ethernet, other }

@singleton
class SyncOperations {
  final SyncQueue _syncQueue;
  final Connectivity _connectivity;
  final AnalyticsService _analytics;

  late StreamSubscription<List<ConnectivityResult>> _networkSubscription;
  bool _isProcessingSync = false;
  Timer? _retryTimer;

  NetworkStatus _currentNetworkStatus = NetworkStatus.offline;
  NetworkStatus get currentNetworkStatus => _currentNetworkStatus;

  SyncOperations(this._syncQueue, this._connectivity, this._analytics) {
    _initializeNetworkListener();
  }

  void _initializeNetworkListener() {
    // Escuta mudanças de conectividade
    _networkSubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final newStatus = _mapConnectivityResult(results);

      if (_currentNetworkStatus != newStatus) {
        _currentNetworkStatus = newStatus;
        debugPrint('📶 Conectividade mudou: ${newStatus.name}');

        // Processa fila quando voltar online
        if (newStatus != NetworkStatus.offline) {
          _scheduleQueueProcessing();
        }
      }
    });

    // Verifica status inicial
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _currentNetworkStatus = _mapConnectivityResult(results);
    debugPrint('📶 Conectividade inicial: ${_currentNetworkStatus.name}');

    if (_currentNetworkStatus != NetworkStatus.offline) {
      _scheduleQueueProcessing();
    }
  }

  NetworkStatus _mapConnectivityResult(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }

    if (results.contains(ConnectivityResult.wifi)) {
      return NetworkStatus.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      return NetworkStatus.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return NetworkStatus.ethernet;
    } else {
      return NetworkStatus.other;
    }
  }

  void _scheduleQueueProcessing() {
    // Agenda processamento com delay para evitar spam
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 2), () {
      processOfflineQueue();
    });
  }

  Future<void> processOfflineQueue() async {
    // Previne múltiplos processamentos simultâneos
    if (_isProcessingSync) {
      debugPrint('⏸️ Sync já em andamento, ignorando...');
      return;
    }

    // Só processa se estiver online
    if (_currentNetworkStatus == NetworkStatus.offline) {
      debugPrint('📵 Offline, não processando fila');
      return;
    }

    _isProcessingSync = true;
    debugPrint('🔄 Iniciando processamento da fila de sync...');

    try {
      await _analytics.log('sync_queue_processing_started');

      final pendingItems = _syncQueue.getPendingItems();

      if (pendingItems.isEmpty) {
        debugPrint('✅ Fila de sync vazia');
        return;
      }

      debugPrint('📋 Processando ${pendingItems.length} items da fila');

      // Prioriza items: Create > Update > Delete
      final prioritizedItems = _prioritizeItems(pendingItems);

      int processedCount = 0;
      int failedCount = 0;

      for (var item in prioritizedItems) {
        try {
          await _processSyncItem(item);
          processedCount++;
          debugPrint('✅ Item processado: ${item.modelType}.${item.operation}');
        } catch (e) {
          failedCount++;
          debugPrint('❌ Erro ao processar item ${item.id}: $e');

          // Incrementa retry ou remove se excedeu tentativas
          if (item.shouldRetry) {
            await _syncQueue.incrementRetryCount(item.id, e.toString());
          } else {
            debugPrint('🗑️ Item excedeu tentativas, removendo da fila');
            await _syncQueue.removeItem(item.id);
          }
        }
      }

      // Limpa items sincronizados
      await _syncQueue.clearSyncedItems();

      // Log analytics
      await _analytics.log('sync_queue_processing_completed');

      debugPrint(
        '🎯 Sync concluído: $processedCount processados, $failedCount falharam',
      );
    } catch (e) {
      debugPrint('💥 Erro no processamento da fila: $e');
      await _analytics.recordError(e, null);
    } finally {
      _isProcessingSync = false;
    }
  }

  List<SyncQueueItem> _prioritizeItems(List<SyncQueueItem> items) {
    // Ordena por prioridade calculada + timestamp
    items.sort((a, b) {
      // Primeiro por prioridade (maior primeiro)
      final priorityComparison = b.calculatedPriority.compareTo(
        a.calculatedPriority,
      );
      if (priorityComparison != 0) return priorityComparison;

      // Depois por timestamp (mais antigo primeiro)
      return a.timestamp.compareTo(b.timestamp);
    });

    return items;
  }

  Future<void> _processSyncItem(SyncQueueItem item) async {
    debugPrint(
      '⚙️ Processando: ${item.modelType}.${item.operation} (ID: ${item.id})',
    );

    // Simula processamento por tipo de operação
    // TODO: Implementar integração real com repositories
    switch (item.operationType) {
      case SyncOperationType.create:
        await _performCreate(item);
        break;
      case SyncOperationType.update:
        await _performUpdate(item);
        break;
      case SyncOperationType.delete:
        await _performDelete(item);
        break;
    }
  }

  Future<void> _performCreate(SyncQueueItem item) async {
    // TODO: Integrar com repository específico baseado no modelType
    debugPrint('➕ Criando ${item.modelType}...');

    // Simula operação remota
    await Future.delayed(Duration(milliseconds: 500 + (item.retryCount * 200)));

    // Marca como sincronizado
    await _syncQueue.markItemAsSynced(item.id);

    await _analytics.log('sync_item_created');
  }

  Future<void> _performUpdate(SyncQueueItem item) async {
    // TODO: Integrar com repository específico baseado no modelType
    debugPrint('📝 Atualizando ${item.modelType}...');

    // Simula operação remota
    await Future.delayed(Duration(milliseconds: 300 + (item.retryCount * 200)));

    // Marca como sincronizado
    await _syncQueue.markItemAsSynced(item.id);

    await _analytics.log('sync_item_updated');
  }

  Future<void> _performDelete(SyncQueueItem item) async {
    // TODO: Integrar com repository específico baseado no modelType
    debugPrint('🗑️ Deletando ${item.modelType}...');

    // Simula operação remota
    await Future.delayed(Duration(milliseconds: 200 + (item.retryCount * 200)));

    // Marca como sincronizado
    await _syncQueue.markItemAsSynced(item.id);

    await _analytics.log('sync_item_deleted');
  }

  /// Força processamento da fila manualmente
  Future<void> forceSyncNow() async {
    debugPrint('🚀 Forçando sincronização...');
    await processOfflineQueue();
  }

  /// Verifica se está online
  bool get isOnline => _currentNetworkStatus != NetworkStatus.offline;

  /// Obtém estatísticas de conectividade
  Map<String, dynamic> getConnectivityStats() {
    return {
      'current_status': _currentNetworkStatus.name,
      'is_online': isOnline,
      'is_processing_sync': _isProcessingSync,
    };
  }

  /// Dispose de recursos
  void dispose() {
    _networkSubscription.cancel();
    _retryTimer?.cancel();
    debugPrint('♻️ SyncOperations dispose');
  }
}
