
import '../data/models/conflict_history_model.dart';
import 'conflict_history_drift_service.dart';

/// ADAPTER PATTERN - Mantém interface antiga mas delega para Drift
///
/// Este adapter permite uso consistente do conflict history enquanto
/// toda a base de código migra para a implementação Drift nativa.
///
/// ⚠️ DEPRECATED: Use ConflictHistoryDriftService diretamente para código novo
class ConflictHistoryService {
  final ConflictHistoryDriftService _driftService;

  ConflictHistoryService(this._driftService);

  /// Salva um novo registro de histórico de conflito
  Future<void> saveConflict(ConflictHistoryModel conflictHistory) async {
    await _driftService.recordConflict(
      tableName: conflictHistory.modelType,
      recordId: conflictHistory.modelId,
      conflictType: 'sync_conflict',
      resolution: conflictHistory.resolutionStrategy,
      localData: conflictHistory.localData,
      remoteData: conflictHistory.remoteData,
      mergedData: conflictHistory.resolvedData,
      userId: conflictHistory.userId,
    );
  }

  /// Busca histórico de conflitos por ID do modelo
  Future<List<ConflictHistoryModel>> getConflictsByModelId(
    String modelId,
  ) async {
    // Interface antiga não tinha tableName - buscar em todos
    // Isso é uma limitação do adapter, código novo deve usar getByModel()
    final allRecent = await _driftService.getRecent(limit: 1000);
    return allRecent.where((c) => c.modelId == modelId).toList();
  }

  /// Busca todos os históricos de conflitos
  Future<List<ConflictHistoryModel>> getAllConflicts() async {
    return await _driftService.getRecent(limit: 1000);
  }

  /// Remove um registro específico de conflito
  Future<void> removeConflict(String conflictId) async {
    // Drift não tem delete por ID - marcar como resolvido é equivalente
    await _driftService.markAsResolved(conflictId);
  }

  /// Limpar histórico de conflitos
  Future<void> clearConflictHistory() async {
    await _driftService.clearAll();
  }

  /// Conta o número total de conflitos registrados
  Future<int> countConflicts() async {
    final stats = await _driftService.getStats();
    return stats['total'] as int;
  }

  /// Obtém os últimos N conflitos registrados
  Future<List<ConflictHistoryModel>> getRecentConflicts(int limit) async {
    return await _driftService.getRecent(limit: limit);
  }

  // NOVOS MÉTODOS ASSÍNCRONOS (interface melhorada)

  /// Obter conflitos não resolvidos
  Future<List<ConflictHistoryModel>> getUnresolvedConflicts() async {
    return await _driftService.getUnresolved();
  }

  /// Obter estatísticas de conflitos
  Future<Map<String, dynamic>> getConflictStats() async {
    return await _driftService.getStats();
  }

  /// Limpar conflitos antigos resolvidos
  Future<int> cleanOldConflicts({
    Duration age = const Duration(days: 30),
  }) async {
    return await _driftService.cleanOldConflicts(age: age);
  }
}
