import 'package:core/core.dart' hide ConflictResolutionStrategy, Task;

import '../../features/plants/data/models/plant_model.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../../features/tasks/domain/entities/task.dart';
import 'conflict_resolution_strategy.dart';

@injectable
class ConflictResolver {
  /// Resolve conflito baseado na estratégia definida
  dynamic resolveConflict(
    ConflictData conflictData, {
    ConflictResolutionStrategy strategy = ConflictResolutionStrategy.newerWins,
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
}
