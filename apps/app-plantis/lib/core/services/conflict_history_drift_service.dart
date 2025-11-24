import 'dart:async';


import '../../database/repositories/conflict_history_drift_repository.dart';
import '../data/models/conflict_history_model.dart';

/// Service para gerenciar histórico de conflitos usando Drift
///
/// Responsável por registrar conflitos de sincronização, rastrear
/// resoluções e fornecer análise de conflitos.
class ConflictHistoryDriftService {
  final ConflictHistoryDriftRepository _repository;

  ConflictHistoryDriftService(this._repository);

  /// Registrar novo conflito
  ///
  /// [tableName] - Nome da tabela onde ocorreu o conflito
  /// [recordId] - ID do registro em conflito
  /// [conflictType] - Tipo de conflito (ex: 'version_mismatch', 'concurrent_edit')
  /// [localVersion] - Versão local do registro
  /// [remoteVersion] - Versão remota do registro
  /// [resolution] - Estratégia de resolução aplicada
  /// [localData] - Dados locais do registro
  /// [remoteData] - Dados remotos do registro
  /// [mergedData] - Dados após resolução
  Future<int> recordConflict({
    required String tableName,
    required String recordId,
    required String conflictType,
    int? localVersion,
    int? remoteVersion,
    String? resolution,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
    Map<String, dynamic>? mergedData,
    String? userId,
  }) async {
    final conflict = ConflictHistoryModel.create(
      modelType: tableName,
      modelId: recordId,
      resolutionStrategy: resolution ?? 'unresolved',
      localData: localData ?? {},
      remoteData: remoteData ?? {},
      resolvedData: mergedData ?? {},
      userId: userId,
    );

    return await _repository.logConflict(conflict);
  }

  /// Marcar conflito como resolvido
  Future<bool> markAsResolved(String conflictId) async {
    return await _repository.markAsResolved(
      conflictId,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Obter conflitos não resolvidos
  Future<List<ConflictHistoryModel>> getUnresolved() async {
    return await _repository.getUnresolvedConflicts();
  }

  /// Obter histórico de conflitos por tipo de modelo
  Future<List<ConflictHistoryModel>> getByModelType(String modelType) async {
    return await _repository.getConflictHistory(modelType: modelType);
  }

  /// Obter conflitos recentes
  Future<List<ConflictHistoryModel>> getRecent({int limit = 50}) async {
    return await _repository.getConflictHistory();
  }

  /// Limpar conflitos antigos
  Future<int> cleanOldConflicts({
    Duration age = const Duration(days: 30),
  }) async {
    return await _repository.clearOldConflicts(daysToKeep: age.inDays);
  }

  /// Obter estatísticas de conflitos
  Future<Map<String, dynamic>> getStats() async {
    final unresolved = await _repository.getUnresolvedCount();

    return {
      'unresolved': unresolved,
      'resolved': 0, // TODO: Calculate when method available
      'total': unresolved,
      'byModel': <String, int>{}, // TODO: Implement when method available
      'resolutionRate': '0.0', // TODO: Calculate when resolved count available
    };
  }

  /// Obter conflitos agrupados por tipo
  Future<Map<String, List<ConflictHistoryModel>>> getConflictsByType() async {
    final allConflicts = await getRecent(limit: 1000);
    final Map<String, List<ConflictHistoryModel>> groupedByType = {};

    for (final conflict in allConflicts) {
      final type = conflict.modelType;
      if (!groupedByType.containsKey(type)) {
        groupedByType[type] = [];
      }
      groupedByType[type]!.add(conflict);
    }

    return groupedByType;
  }

  /// Obter conflitos agrupados por estratégia de resolução
  Future<Map<String, List<ConflictHistoryModel>>>
  getConflictsByResolution() async {
    final allConflicts = await getRecent(limit: 1000);
    final Map<String, List<ConflictHistoryModel>> groupedByResolution = {};

    for (final conflict in allConflicts) {
      final resolution = conflict.resolutionStrategy;
      if (!groupedByResolution.containsKey(resolution)) {
        groupedByResolution[resolution] = [];
      }
      groupedByResolution[resolution]!.add(conflict);
    }

    return groupedByResolution;
  }

  /// Obter taxa de resolução automática
  Future<double> getAutoResolutionRate() async {
    final allConflicts = await getRecent(limit: 1000);
    if (allConflicts.isEmpty) return 0.0;

    final autoResolved = allConflicts.where((c) => c.autoResolved).length;
    return (autoResolved / allConflicts.length) * 100;
  }

  /// Stream de conflitos não resolvidos (para UI observar mudanças)
  /// TODO: Implement watchUnresolvedConflicts in repository
  Stream<List<ConflictHistoryModel>> watchUnresolvedConflicts() {
    // Temporary workaround: return periodic stream
    return Stream.periodic(
      const Duration(seconds: 5),
      (_) => getUnresolved(),
    ).asyncMap((future) => future);
  }

  /// Limpar todos os conflitos (útil para testes)
  Future<void> clearAll() async {
    await _repository.deleteAll();
  }

  /// Exportar conflitos para análise
  ///
  /// Retorna mapa com informações detalhadas de conflitos
  Future<Map<String, dynamic>> exportConflictsForAnalysis({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final conflicts = await getRecent(limit: 1000);

    // Filtrar por datas se fornecidas
    final filteredConflicts = conflicts.where((c) {
      if (startDate != null && c.createdAt != null) {
        if (c.createdAt!.isBefore(startDate)) return false;
      }
      if (endDate != null && c.createdAt != null) {
        if (c.createdAt!.isAfter(endDate)) return false;
      }
      return true;
    }).toList();

    final stats = await getStats();
    final byType = await getConflictsByType();
    final byResolution = await getConflictsByResolution();
    final autoResolutionRate = await getAutoResolutionRate();

    return {
      'summary': stats,
      'autoResolutionRate': autoResolutionRate,
      'totalAnalyzed': filteredConflicts.length,
      'byType': byType.map((key, value) => MapEntry(key, value.length)),
      'byResolution': byResolution.map(
        (key, value) => MapEntry(key, value.length),
      ),
      'conflicts': filteredConflicts.map((c) => c.toMap()).toList(),
    };
  }
}
