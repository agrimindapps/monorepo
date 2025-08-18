import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../data/models/planta_model.dart';
import '../data/models/tarefa_model.dart';
import 'conflict_resolution_strategy.dart';

@injectable
class ConflictResolver {
  /// Resolve conflito baseado na estratégia definida
  dynamic resolveConflict(ConflictData conflictData, {
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.newerWins
  }) {
    switch (strategy) {
      case ConflictResolutionStrategy.localWins:
        return conflictData.localData;
      case ConflictResolutionStrategy.remoteWins:
        return conflictData.remoteData;
      case ConflictResolutionStrategy.newerWins:
        return _resolveNewerWins(conflictData);
      case ConflictResolutionStrategy.merge:
        return _mergeData(conflictData);
      case ConflictResolutionStrategy.manual:
        // TODO: Implementar interface de resolução manual
        throw UnimplementedError('Resolução manual ainda não implementada');
    }
  }

  /// Resolve conflito escolhendo o dado mais recente
  dynamic _resolveNewerWins(ConflictData conflictData) {
    return conflictData.localTimestamp.isAfter(conflictData.remoteTimestamp)
        ? conflictData.localData
        : conflictData.remoteData;
  }

  /// Merge inteligente baseado no tipo de modelo
  dynamic _mergeData(ConflictData conflictData) {
    switch (conflictData.modelType) {
      case 'PlantaModel':
        return _mergePlantaModel(
          conflictData.localData as PlantaModel, 
          conflictData.remoteData as PlantaModel
        );
      case 'TarefaModel':
        return _mergeTarefaModel(
          conflictData.localData as TarefaModel, 
          conflictData.remoteData as TarefaModel
        );
      default:
        throw UnimplementedError('Merge não implementado para ${conflictData.modelType}');
    }
  }

  /// Merge específico para PlantaModel
  PlantaModel _mergePlantaModel(PlantaModel local, PlantaModel remote) {
    final DateTime now = DateTime.now();
    return PlantaModel(
      id: local.id,
      createdAtMs: local.createdAtMs ?? remote.createdAtMs,
      updatedAtMs: now.millisecondsSinceEpoch,
      lastSyncAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      isDeleted: local.isDeleted || remote.isDeleted,
      version: local.version + 1,
      userId: local.userId ?? remote.userId,
      moduleName: local.moduleName ?? remote.moduleName,
      nome: local.nome ?? remote.nome,
      especie: local.especie ?? remote.especie,
      espacoId: local.espacoId ?? remote.espacoId,
      imagePaths: local.imagePaths ?? remote.imagePaths,
      observacoes: local.observacoes ?? remote.observacoes,
      comentarios: local.comentarios ?? remote.comentarios,
      dataCadastro: local.dataCadastro ?? remote.dataCadastro,
      fotoBase64: local.fotoBase64 ?? remote.fotoBase64,
    );
  }

  /// Merge específico para TarefaModel
  TarefaModel _mergeTarefaModel(TarefaModel local, TarefaModel remote) {
    final DateTime now = DateTime.now();
    return TarefaModel(
      id: local.id,
      createdAtMs: local.createdAtMs ?? remote.createdAtMs,
      updatedAtMs: now.millisecondsSinceEpoch,
      lastSyncAtMs: now.millisecondsSinceEpoch,
      isDirty: true,
      isDeleted: local.isDeleted || remote.isDeleted,
      version: local.version + 1,
      userId: local.userId ?? remote.userId,
      moduleName: local.moduleName ?? remote.moduleName,
      plantaId: local.plantaId,
      tipoCuidado: local.tipoCuidado,
      dataExecucao: local.dataExecucao,
      concluida: local.concluida || remote.concluida,
      observacoes: local.observacoes ?? remote.observacoes,
      dataConclusao: local.dataConclusao ?? remote.dataConclusao,
    );
  }
}