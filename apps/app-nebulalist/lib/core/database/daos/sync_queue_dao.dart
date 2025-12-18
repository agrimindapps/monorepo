import 'package:drift/drift.dart';

import '../nebulalist_database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

/// DAO para operações na tabela de sync queue
///
/// Responsável por gerenciar a fila de operações pendentes de sincronização.
///
/// **Padrão:** Baseado em app-plantis/SyncQueueDriftRepository
///
/// **Operações principais:**
/// - enqueue: Adiciona operação à fila
/// - getPendingItems: Busca items não sincronizados
/// - markAsSynced: Marca item como sincronizado
/// - incrementSyncAttempts: Registra falha de tentativa
/// - clearSyncedItems: Remove itens já sincronizados
///
/// **Exemplo:**
/// ```dart
/// final dao = database.syncQueueDao;
///
/// // Enfileirar operação
/// await dao.enqueue(
///   modelType: 'List',
///   modelId: 'abc-123',
///   operation: 'create',
///   data: jsonEncode(model.toJson()),
/// );
///
/// // Processar fila
/// final pending = await dao.getPendingItems();
/// for (final item in pending) {
///   try {
///     await syncToFirebase(item);
///     await dao.markAsSynced(item.id);
///   } catch (e) {
///     await dao.incrementSyncAttempts(item.id, e.toString());
///   }
/// }
/// ```
@DriftAccessor(tables: [NebulalistSyncQueue])
class SyncQueueDao extends DatabaseAccessor<NebulalistDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  /// Adiciona item à fila de sincronização
  ///
  /// [modelType] - Tipo do modelo ('List', 'ItemMaster', 'ListItem')
  /// [modelId] - ID do registro
  /// [operation] - Operação ('create', 'update', 'delete')
  /// [data] - JSON serializado do modelo
  ///
  /// Retorna o ID do item enfileirado
  Future<int> enqueue({
    required String modelType,
    required String modelId,
    required String operation,
    required String data,
  }) async {
    final companion = NebulalistSyncQueueCompanion.insert(
      modelType: modelType,
      modelId: modelId,
      operation: operation,
      data: data,
      timestamp: Value(DateTime.now()),
      attempts: const Value(0),
      isSynced: const Value(false),
      lastError: const Value(null),
    );

    return await into(nebulalistSyncQueue).insert(companion);
  }

  /// Busca itens pendentes de sincronização (não sincronizados)
  ///
  /// [limit] - Número máximo de itens a retornar (padrão: 50)
  ///
  /// Retorna lista ordenada por timestamp (mais antigos primeiro)
  Future<List<NebulalistSyncQueueData>> getPendingItems({
    int limit = 50,
  }) async {
    return (select(nebulalistSyncQueue)
          ..where((s) => s.isSynced.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.timestamp)])
          ..limit(limit))
        .get();
  }

  /// Marca item como sincronizado com sucesso
  ///
  /// [id] - ID do item na fila
  ///
  /// Retorna true se foi atualizado, false caso contrário
  Future<bool> markAsSynced(int id) async {
    final updated = await (update(nebulalistSyncQueue)
          ..where((s) => s.id.equals(id)))
        .write(const NebulalistSyncQueueCompanion(isSynced: Value(true)));

    return updated > 0;
  }

  /// Incrementa contador de tentativas e registra erro
  ///
  /// [id] - ID do item na fila
  /// [errorMessage] - Mensagem de erro (opcional)
  ///
  /// Usado quando uma tentativa de sync falha
  Future<void> incrementSyncAttempts(int id, String? errorMessage) async {
    final item = await (select(nebulalistSyncQueue)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();

    if (item != null) {
      await (update(nebulalistSyncQueue)..where((s) => s.id.equals(id))).write(
        NebulalistSyncQueueCompanion(
          attempts: Value(item.attempts + 1),
          lastError: Value(errorMessage),
        ),
      );
    }
  }

  /// Remove itens já sincronizados (limpeza)
  ///
  /// Útil para evitar crescimento infinito da tabela
  Future<void> clearSyncedItems() async {
    await (delete(nebulalistSyncQueue)..where((s) => s.isSynced.equals(true)))
        .go();
  }

  /// Conta número de itens pendentes
  Future<int> countPendingItems() async {
    final count = nebulalistSyncQueue.id.count();
    final query = selectOnly(nebulalistSyncQueue)
      ..addColumns([count])
      ..where(nebulalistSyncQueue.isSynced.equals(false));

    return query.map((row) => row.read(count)!).getSingle();
  }

  /// Conta número de itens sincronizados
  Future<int> countSyncedItems() async {
    final count = nebulalistSyncQueue.id.count();
    final query = selectOnly(nebulalistSyncQueue)
      ..addColumns([count])
      ..where(nebulalistSyncQueue.isSynced.equals(true));

    return query.map((row) => row.read(count)!).getSingle();
  }

  /// Conta itens que falharam (excederam max retries)
  ///
  /// [maxRetries] - Número máximo de tentativas (padrão: 3)
  Future<int> countFailedItems({int maxRetries = 3}) async {
    final count = nebulalistSyncQueue.id.count();
    final query = selectOnly(nebulalistSyncQueue)
      ..addColumns([count])
      ..where(
        nebulalistSyncQueue.attempts.isBiggerOrEqualValue(maxRetries) &
            nebulalistSyncQueue.isSynced.equals(false),
      );

    return query.map((row) => row.read(count)!).getSingle();
  }

  /// Busca itens que falharam (excederam max retries)
  ///
  /// [maxRetries] - Número máximo de tentativas (padrão: 3)
  /// [limit] - Número máximo de itens a retornar (padrão: 50)
  Future<List<NebulalistSyncQueueData>> getFailedItems({
    int maxRetries = 3,
    int limit = 50,
  }) async {
    return (select(nebulalistSyncQueue)
          ..where(
            (s) =>
                s.attempts.isBiggerOrEqualValue(maxRetries) &
                s.isSynced.equals(false),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.timestamp)])
          ..limit(limit))
        .get();
  }

  /// Watch stream de itens pendentes (updates em tempo real)
  ///
  /// [limit] - Número máximo de itens a retornar (padrão: 50)
  ///
  /// Retorna stream que emite nova lista sempre que há mudanças
  Stream<List<NebulalistSyncQueueData>> watchPendingItems({
    int limit = 50,
  }) {
    return (select(nebulalistSyncQueue)
          ..where((s) => s.isSynced.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.timestamp)])
          ..limit(limit))
        .watch();
  }

  /// Remove todos os itens (útil para testes)
  Future<void> deleteAll() async {
    await delete(nebulalistSyncQueue).go();
  }

  /// Obtém estatísticas da fila
  ///
  /// Retorna Map com contadores de pending, synced, failed
  Future<Map<String, int>> getStats({int maxRetries = 3}) async {
    final pending = await countPendingItems();
    final synced = await countSyncedItems();
    final failed = await countFailedItems(maxRetries: maxRetries);

    return {
      'pending': pending,
      'synced': synced,
      'failed': failed,
      'total': pending + synced + failed,
    };
  }
}
