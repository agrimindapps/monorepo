import 'package:core/core.dart' hide Column, ConflictResolutionStrategy, Task;
import 'package:flutter/material.dart';

import '../../features/plants/data/models/plant_model.dart';
import '../../features/plants/domain/entities/plant.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../widgets/conflict_resolution_dialog.dart';
import 'conflict_resolution_strategy.dart';

@injectable
class ConflictResolver {
  /// Resolve conflito baseado na estratégia definida
  ///
  /// Para estratégia manual, retorna um Future que será resolvido quando o usuário escolher
  /// IMPORTANTE: Para estratégia manual, é necessário passar o BuildContext
  Future<dynamic> resolveConflict(
    ConflictData conflictData, {
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.newerWins,
    BuildContext? context,
  }) async {
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
        if (context == null) {
          throw ArgumentError(
            'BuildContext é obrigatório para resolução manual de conflitos',
          );
        }
        return await _resolveManually(conflictData, context);
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
      case 'PlantModel':
        return _mergePlantModel(
          conflictData.localData as PlantModel,
          conflictData.remoteData as PlantModel,
        );
      case 'TaskModel':
        return _mergeTaskModel(
          conflictData.localData as TaskModel,
          conflictData.remoteData as TaskModel,
        );
      default:
        throw UnimplementedError(
          'Merge não implementado para ${conflictData.modelType}',
        );
    }
  }

  /// Merge específico para PlantModel
  PlantModel _mergePlantModel(PlantModel local, PlantModel remote) {
    final DateTime now = DateTime.now();
    return PlantModel(
      id: local.id,
      createdAt: local.createdAt ?? remote.createdAt,
      updatedAt: now,
      lastSyncAt: now,
      isDirty: true,
      isDeleted: local.isDeleted || remote.isDeleted,
      version: local.version + 1,
      userId: local.userId ?? remote.userId,
      moduleName: local.moduleName ?? remote.moduleName,
      name: local.name.isNotEmpty ? local.name : remote.name,
      species: local.species ?? remote.species,
      spaceId: local.spaceId ?? remote.spaceId,
      imageUrls:
          local.imageUrls.isNotEmpty ? local.imageUrls : remote.imageUrls,
      notes: local.notes ?? remote.notes,
      plantingDate: local.plantingDate ?? remote.plantingDate,
      imageBase64: local.imageBase64 ?? remote.imageBase64,
      config: local.config ?? remote.config,
    );
  }

  /// Merge específico para TaskModel
  TaskModel _mergeTaskModel(TaskModel local, TaskModel remote) {
    final localTask = local as Task;
    final remoteTask = remote as Task;

    return local
        .copyWith(
          updatedAt: DateTime.now(),
          isDirty: true,
          isDeleted: localTask.isDeleted || remoteTask.isDeleted,
          version: localTask.version + 1,
          userId: localTask.userId ?? remoteTask.userId,
          moduleName: localTask.moduleName ?? remoteTask.moduleName,
          lastSyncAt: DateTime.now(),
        )
        .copyWithTaskData(
          title:
              localTask.title.isNotEmpty ? localTask.title : remoteTask.title,
          description: localTask.description ?? remoteTask.description,
          plantId: localTask.plantId, // plantId não muda em conflitos
          status:
              localTask.status.index > remoteTask.status.index
                  ? localTask.status
                  : remoteTask.status,
          completedAt: localTask.completedAt ?? remoteTask.completedAt,
          completionNotes:
              localTask.completionNotes ?? remoteTask.completionNotes,
          isRecurring: localTask.isRecurring || remoteTask.isRecurring,
          recurringIntervalDays:
              localTask.recurringIntervalDays ??
              remoteTask.recurringIntervalDays,
          nextDueDate: localTask.nextDueDate ?? remoteTask.nextDueDate,
        );
  }

  /// Resolução manual via diálogo interativo
  /// Mostra diálogo para o usuário escolher qual versão manter
  Future<dynamic> _resolveManually(
    ConflictData conflictData,
    BuildContext context,
  ) async {
    // Atualmente, apenas PlantModel tem suporte completo ao diálogo
    if (conflictData.modelType != 'PlantModel') {
      // Para outros tipos, usa newerWins como fallback
      return _resolveNewerWins(conflictData);
    }

    // PlantModel extends Plant, então podemos fazer cast direto
    final localPlant = conflictData.localData as Plant;
    final remotePlant = conflictData.remoteData as Plant;

    // Mostra diálogo e aguarda resolução
    final result = await showDialog<Plant>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ConflictResolutionDialog(
          localVersion: localPlant,
          remoteVersion: remotePlant,
          onResolve: (chosenVersion) async {
            // Retorna a versão escolhida
            Navigator.of(context).pop(chosenVersion);
          },
        );
      },
    );

    // Se o usuário fechou o diálogo sem escolher, usa newerWins
    if (result == null) {
      return _resolveNewerWins(conflictData);
    }

    // Determina qual era o modelo original escolhido comparando IDs e timestamps
    final isLocalChosen = result.id == localPlant.id &&
        result.name == localPlant.name &&
        result.updatedAt == localPlant.updatedAt;

    return isLocalChosen ? conflictData.localData : conflictData.remoteData;
  }
}
