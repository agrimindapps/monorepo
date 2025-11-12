import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../database/plantis_database.dart' as db;
import '../../database/repositories/sync_queue_drift_repository.dart';

/// Service para gerenciar fila de sincronização usando Drift
///
/// Responsável por enfileirar operações offline, processar a fila
/// e gerenciar retry logic para operações falhadas.
@lazySingleton
class SyncQueueDriftService {
  final SyncQueueDriftRepository _repository;
  StreamSubscription<List<db.PlantsSyncQueueData>>? _queueSubscription;
  final StreamController<List<db.PlantsSyncQueueData>> _queueController =
      StreamController<List<db.PlantsSyncQueueData>>.broadcast();

  SyncQueueDriftService(this._repository);

  /// Stream de itens pendentes (para UI observar mudanças)
  Stream<List<db.PlantsSyncQueueData>> get queueStream => _queueController.stream;

  /// Inicializar stream watcher
  void startWatching({int limit = 50}) {
    _queueSubscription?.cancel();
    _queueSubscription = _repository
        .watchPendingItems(limit: limit)
        .listen(_queueController.add);
  }

  /// Parar stream watcher
  void stopWatching() {
    _queueSubscription?.cancel();
    _queueSubscription = null;
  }

  /// Enfileirar operação para sincronização
  ///
  /// [modelType] - Nome do modelo (ex: 'Plant', 'Space', 'Task')
  /// [modelId] - ID do registro
  /// [operation] - Tipo de operação: 'create', 'update', 'delete'
  /// [data] - Dados do registro (JSON serializado)
  Future<void> enqueue({
    required String modelType,
    required String modelId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    // Validação de operation
    if (!['create', 'update', 'delete'].contains(operation)) {
      throw ArgumentError('Invalid operation: $operation. Must be create/update/delete');
    }

    await _repository.enqueue(
      modelType: modelType,
      modelId: modelId,
      operation: operation,
      data: jsonEncode(data),
    );
  }

  /// Obter itens pendentes de sincronização
  Future<List<db.PlantsSyncQueueData>> getPendingItems({int limit = 50}) async {
    return await _repository.getPendingItems(limit: limit);
  }

  /// Obter itens que falharam (excederam max retries)
  Future<List<db.PlantsSyncQueueData>> getFailedItems({
    int maxRetries = 3,
    int limit = 50,
  }) async {
    return await _repository.getFailedItems(
      maxRetries: maxRetries,
      limit: limit,
    );
  }

  /// Marcar item como sincronizado
  Future<bool> markAsSynced(int itemId) async {
    return await _repository.markAsSynced(itemId);
  }

  /// Incrementar contador de tentativas e registrar erro
  Future<void> recordFailedAttempt(int itemId, String errorMessage) async {
    await _repository.incrementSyncAttempts(itemId, errorMessage);
  }

  /// Remover itens sincronizados (limpeza)
  Future<void> cleanSyncedItems() async {
    await _repository.clearSyncedItems();
  }

  /// Obter contagem de itens pendentes
  Future<int> getPendingCount() async {
    return await _repository.countPendingItems();
  }

  /// Obter contagem de itens sincronizados
  Future<int> getSyncedCount() async {
    return await _repository.countSyncedItems();
  }

  /// Obter contagem de itens falhados
  Future<int> getFailedCount({int maxRetries = 3}) async {
    return await _repository.countFailedItems(maxRetries: maxRetries);
  }

  /// Processar fila de sincronização
  ///
  /// [syncCallback] - Função que executa a sincronização do item
  /// [maxRetries] - Máximo de tentativas antes de desistir
  ///
  /// Retorna número de itens processados com sucesso
  Future<int> processQueue({
    required Future<void> Function(db.PlantsSyncQueueData) syncCallback,
    int maxRetries = 3,
  }) async {
    final pending = await getPendingItems();
    int successCount = 0;

    for (final item in pending) {
      // Skip se excedeu tentativas
      if (item.attempts >= maxRetries) {
        continue;
      }

      try {
        // Executar callback de sincronização
        await syncCallback(item);

        // Marcar como sincronizado
        await markAsSynced(item.id);
        successCount++;
      } catch (e) {
        // Registrar falha
        await recordFailedAttempt(item.id, e.toString());
      }
    }

    return successCount;
  }

  /// Limpar toda a fila (útil para testes)
  Future<void> clearAll() async {
    await _repository.deleteAll();
  }

  /// Obter estatísticas da fila
  Future<Map<String, int>> getStats() async {
    final pending = await getPendingCount();
    final synced = await getSyncedCount();
    final failed = await getFailedCount(maxRetries: 3);

    return {
      'pending': pending,
      'synced': synced,
      'failed': failed,
      'total': pending + synced + failed,
    };
  }

  /// Reprocessar itens falhados (resetar contador de tentativas)
  ///
  /// Útil para tentar novamente após resolver problema de conectividade
  Future<int> retryFailedItems({int maxRetries = 3}) async {
    final failedItems = await getFailedItems(maxRetries: maxRetries);
    int retryCount = 0;

    for (final item in failedItems) {
      // Resetar contador de tentativas para zero
      await _repository.incrementSyncAttempts(item.id, null);
      retryCount++;
    }

    return retryCount;
  }

  /// Dispose - limpar recursos
  void dispose() {
    _queueSubscription?.cancel();
    _queueController.close();
  }
}
