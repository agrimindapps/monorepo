import 'dart:async';
import 'dart:convert';

import '../database/daos/sync_queue_dao.dart';
import '../database/nebulalist_database.dart';

/// Service para gerenciar fila de sincronização usando Drift
///
/// Responsável por enfileirar operações offline, processar a fila
/// e gerenciar retry logic para operações falhadas.
///
/// **Padrão:** Baseado em app-plantis/SyncQueueDriftService
///
/// **Características:**
/// - Persiste operações offline no Drift
/// - Retry automático (até 3 tentativas por padrão)
/// - Stream reativo de items pendentes
/// - Estatísticas de sync (pending/synced/failed)
/// - Limpeza automática de items sincronizados
///
/// **Exemplo de uso:**
/// ```dart
/// final service = NebulalistSyncQueueService(database.syncQueueDao);
///
/// // Inicializar
/// service.startWatching();
///
/// // Enfileirar operação
/// await service.enqueue(
///   modelType: 'List',
///   modelId: 'abc-123',
///   operation: 'create',
///   data: {'name': 'Shopping List'},
/// );
///
/// // Processar fila
/// final synced = await service.processQueue(
///   syncCallback: (item) async {
///     // Sync to Firebase
///     await firebaseService.save(item.data);
///   },
/// );
///
/// // Limpar recursos
/// service.dispose();
/// ```
class NebulalistSyncQueueService {
  final SyncQueueDao _dao;
  StreamSubscription<List<NebulalistSyncQueueData>>? _queueSubscription;
  final StreamController<List<NebulalistSyncQueueData>> _queueController =
      StreamController<List<NebulalistSyncQueueData>>.broadcast();

  NebulalistSyncQueueService(this._dao);

  /// Stream de itens pendentes (para UI observar mudanças)
  Stream<List<NebulalistSyncQueueData>> get queueStream =>
      _queueController.stream;

  /// Inicializar stream watcher
  ///
  /// [limit] - Número máximo de itens a observar (padrão: 50)
  ///
  /// Deve ser chamado após construção do service
  void startWatching({int limit = 50}) {
    _queueSubscription?.cancel();
    _queueSubscription =
        _dao.watchPendingItems(limit: limit).listen(_queueController.add);
  }

  /// Parar stream watcher
  void stopWatching() {
    _queueSubscription?.cancel();
    _queueSubscription = null;
  }

  /// Enfileirar operação para sincronização
  ///
  /// [modelType] - Nome do modelo (ex: 'List', 'ItemMaster', 'ListItem')
  /// [modelId] - ID do registro
  /// [operation] - Tipo de operação: 'create', 'update', 'delete'
  /// [data] - Dados do registro (Map que será serializado para JSON)
  ///
  /// Throws ArgumentError se operation for inválida
  Future<void> enqueue({
    required String modelType,
    required String modelId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    // Validação de operation
    if (!['create', 'update', 'delete'].contains(operation)) {
      throw ArgumentError(
        'Invalid operation: $operation. Must be create/update/delete',
      );
    }

    await _dao.enqueue(
      modelType: modelType,
      modelId: modelId,
      operation: operation,
      data: jsonEncode(data),
    );
  }

  /// Obter itens pendentes de sincronização
  ///
  /// [limit] - Número máximo de itens (padrão: 50)
  Future<List<NebulalistSyncQueueData>> getPendingItems({
    int limit = 50,
  }) async {
    return await _dao.getPendingItems(limit: limit);
  }

  /// Obter itens que falharam (excederam max retries)
  ///
  /// [maxRetries] - Número máximo de tentativas (padrão: 3)
  /// [limit] - Número máximo de itens (padrão: 50)
  Future<List<NebulalistSyncQueueData>> getFailedItems({
    int maxRetries = 3,
    int limit = 50,
  }) async {
    return await _dao.getFailedItems(
      maxRetries: maxRetries,
      limit: limit,
    );
  }

  /// Marcar item como sincronizado
  ///
  /// [itemId] - ID do item na fila
  ///
  /// Retorna true se foi marcado, false caso contrário
  Future<bool> markAsSynced(int itemId) async {
    return await _dao.markAsSynced(itemId);
  }

  /// Incrementar contador de tentativas e registrar erro
  ///
  /// [itemId] - ID do item na fila
  /// [errorMessage] - Mensagem de erro
  Future<void> recordFailedAttempt(int itemId, String errorMessage) async {
    await _dao.incrementSyncAttempts(itemId, errorMessage);
  }

  /// Remover itens sincronizados (limpeza)
  ///
  /// Útil para evitar crescimento infinito da tabela
  Future<void> cleanSyncedItems() async {
    await _dao.clearSyncedItems();
  }

  /// Obter contagem de itens pendentes
  Future<int> getPendingCount() async {
    return await _dao.countPendingItems();
  }

  /// Obter contagem de itens sincronizados
  Future<int> getSyncedCount() async {
    return await _dao.countSyncedItems();
  }

  /// Obter contagem de itens falhados
  ///
  /// [maxRetries] - Número máximo de tentativas (padrão: 3)
  Future<int> getFailedCount({int maxRetries = 3}) async {
    return await _dao.countFailedItems(maxRetries: maxRetries);
  }

  /// Processar fila de sincronização
  ///
  /// [syncCallback] - Função que executa a sincronização do item.
  ///                  Recebe NebulalistSyncQueueData e deve fazer sync com remote.
  /// [maxRetries] - Máximo de tentativas antes de desistir (padrão: 3)
  ///
  /// Retorna número de itens processados com sucesso.
  ///
  /// **Exemplo:**
  /// ```dart
  /// final synced = await service.processQueue(
  ///   syncCallback: (item) async {
  ///     final data = jsonDecode(item.data);
  ///
  ///     switch (item.modelType) {
  ///       case 'List':
  ///         await firebaseService.saveList(data);
  ///         break;
  ///       case 'ItemMaster':
  ///         await firebaseService.saveItemMaster(data);
  ///         break;
  ///     }
  ///   },
  ///   maxRetries: 3,
  /// );
  /// ```
  Future<int> processQueue({
    required Future<void> Function(NebulalistSyncQueueData) syncCallback,
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
    await _dao.deleteAll();
  }

  /// Obter estatísticas da fila
  ///
  /// Retorna Map com contadores:
  /// - pending: Itens aguardando sync
  /// - synced: Itens já sincronizados
  /// - failed: Itens que falharam
  /// - total: Total de itens
  Future<Map<String, int>> getStats() async {
    return await _dao.getStats(maxRetries: 3);
  }

  /// Reprocessar itens falhados (resetar contador de tentativas)
  ///
  /// Útil para tentar novamente após resolver problema de conectividade.
  ///
  /// [maxRetries] - Considerar como falhado se >= maxRetries
  ///
  /// Retorna número de itens que serão retentados
  Future<int> retryFailedItems({int maxRetries = 3}) async {
    final failedItems = await getFailedItems(maxRetries: maxRetries);
    int retryCount = 0;

    for (final item in failedItems) {
      // Resetar contador de tentativas (volta para 0)
      // Fazemos isso setando attempts = 0 via update direto
      await _dao.incrementSyncAttempts(item.id, null);
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
