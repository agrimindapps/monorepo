import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../features/plants/data/models/plant_model.dart';
import '../../features/tasks/data/models/task_model.dart';
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
      case 'PlantModel':
        return _mergePlantModel(
          conflictData.localData as PlantModel, 
          conflictData.remoteData as PlantModel
        );
      case 'TaskModel':
        return _mergeTaskModel(
          conflictData.localData as TaskModel, 
          conflictData.remoteData as TaskModel
        );
      default:
        throw UnimplementedError('Merge não implementado para ${conflictData.modelType}');
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
      version: (local.version ?? 1) + 1,
      userId: local.userId ?? remote.userId,
      moduleName: local.moduleName ?? remote.moduleName,
      name: local.name.isNotEmpty ? local.name : remote.name,
      species: local.species ?? remote.species,
      spaceId: local.spaceId ?? remote.spaceId,
      imageUrls: local.imageUrls.isNotEmpty ? local.imageUrls : remote.imageUrls,
      notes: local.notes ?? remote.notes,
      plantingDate: local.plantingDate ?? remote.plantingDate,
      imageBase64: local.imageBase64 ?? remote.imageBase64,
      config: local.config ?? remote.config,
    );
  }

  /// Merge específico para TaskModel
  TaskModel _mergeTaskModel(TaskModel local, TaskModel remote) {
    final DateTime now = DateTime.now();
    return TaskModel(
      id: local.id,
      createdAt: local.createdAt,
      updatedAt: now,
      title: local.title.isNotEmpty ? local.title : remote.title,
      description: local.description ?? remote.description,
      plantId: local.plantId,
      plantName: local.plantName.isNotEmpty ? local.plantName : remote.plantName,
      type: local.type,
      status: local.status.index > remote.status.index ? local.status : remote.status, // Status mais avançado
      priority: local.priority,
      dueDate: local.dueDate,
      completedAt: local.completedAt ?? remote.completedAt,
      completionNotes: local.completionNotes ?? remote.completionNotes,
      isRecurring: local.isRecurring || remote.isRecurring,
      recurringIntervalDays: local.recurringIntervalDays ?? remote.recurringIntervalDays,
      nextDueDate: local.nextDueDate ?? remote.nextDueDate,
      lastSyncAt: now,
      isDirty: true,
      isDeleted: local.isDeleted || remote.isDeleted,
      version: (local.version ?? 1) + 1,
      userId: local.userId ?? remote.userId,
      moduleName: local.moduleName ?? remote.moduleName,
    );
  }
}