import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../../database/repositories/plant_tasks_drift_repository.dart';
import '../../../domain/entities/plant_task.dart';
import '../../models/plant_task_model.dart';

/// ============================================================================
/// PLANT TASKS LOCAL DATASOURCE - MIGRADO PARA DRIFT
/// ============================================================================
///
/// **MIGRAÇÃO PARA DRIFT (Fase 2):**
/// - Removido código legado (Box, JSON serialization)
/// - Usa PlantTasksDriftRepository para persistência
/// - Mantém cache em memória para performance (5 minutos)
/// - Interface pública idêntica (0 breaking changes)
/// ============================================================================

abstract class PlantTasksLocalDatasource {
  Future<List<PlantTask>> getPlantTasks();
  Future<List<PlantTask>> getPlantTasksByPlantId(String plantId);
  Future<PlantTask?> getPlantTaskById(String id);
  Future<void> addPlantTask(PlantTask task);
  Future<void> addPlantTasks(List<PlantTask> tasks);
  Future<void> updatePlantTask(PlantTask task);
  Future<void> deletePlantTask(String id);
  Future<void> deletePlantTasksByPlantId(String plantId);
  Future<List<PlantTask>> getPendingPlantTasks();
  Future<List<PlantTask>> getOverduePlantTasks();
  Future<List<PlantTask>> getTodayPlantTasks();
  Future<List<PlantTask>> getUpcomingPlantTasks();
  Future<void> clearCache();
}

class PlantTasksLocalDatasourceImpl implements PlantTasksLocalDatasource {
  final PlantTasksDriftRepository _driftRepo;

  // Cache em memória (5 minutos de validade)
  List<PlantTask>? _cachedTasks;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(minutes: 5);

  PlantTasksLocalDatasourceImpl(this._driftRepo);

  @override
  Future<List<PlantTask>> getPlantTasks() async {
    try {
      // Verifica cache em memória
      if (_cachedTasks != null && _cacheTimestamp != null) {
        final now = DateTime.now();
        if (now.difference(_cacheTimestamp!).compareTo(_cacheValidity) < 0) {
          if (kDebugMode) {
            print(
              '🔄 PlantTasksLocalDatasource: Retornando ${_cachedTasks!.length} tasks do cache',
            );
          }
          return _cachedTasks!;
        }
      }

      // Busca do Drift
      final taskModels = await _driftRepo.getAllPlantTasks();
      final tasks = taskModels.map((model) => model.toEntity()).toList();

      if (kDebugMode) {
        print(
          '📥 PlantTasksLocalDatasource: Carregando ${tasks.length} tasks do Drift',
        );
      }

      // Atualiza cache
      _cachedTasks = tasks;
      _cacheTimestamp = DateTime.now();

      if (kDebugMode) {
        print(
          '✅ PlantTasksLocalDatasource: ${tasks.length} tasks carregadas com sucesso',
        );
      }

      return tasks;
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksLocalDatasource: Erro ao buscar tasks: $e');
      }
      throw CacheFailure(
        'Erro ao buscar tarefas do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PlantTask>> getPlantTasksByPlantId(String plantId) async {
    try {
      final taskModels = await _driftRepo.getPlantTasksByPlantId(plantId);
      final tasks = taskModels.map((model) => model.toEntity()).toList();

      if (kDebugMode) {
        print(
          '📥 PlantTasksLocalDatasource: ${tasks.length} tasks encontradas para planta $plantId',
        );
      }

      return tasks;
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ PlantTasksLocalDatasource: Erro ao buscar tasks por plantId: $e',
        );
      }
      throw CacheFailure(
        'Erro ao buscar tarefas por planta do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<PlantTask?> getPlantTaskById(String id) async {
    try {
      final taskModel = await _driftRepo.getPlantTaskById(id);
      return taskModel?.toEntity();
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksLocalDatasource: Erro ao buscar task por ID: $e');
      }
      throw CacheFailure(
        'Erro ao buscar tarefa do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> addPlantTask(PlantTask task) async {
    try {
      if (kDebugMode) {
        print(
          '💾 PlantTasksLocalDatasource: Salvando task ${task.id} - ${task.title}',
        );
      }

      final taskModel = PlantTaskModel.fromEntity(task);
      await _driftRepo.insertPlantTask(taskModel);
      _invalidateCache();

      if (kDebugMode) {
        print('✅ PlantTasksLocalDatasource: Task ${task.id} salva com sucesso');
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Plant not found locally')) {
        if (kDebugMode) {
          print(
            '⚠️ PlantTasksLocalDatasource: Skipping task ${task.id} because plant is not cached yet',
          );
        }
        return;
      }
      if (kDebugMode) {
        print('❌ PlantTasksLocalDatasource: Erro ao salvar task: $e');
      }
      throw CacheFailure(
        'Erro ao salvar tarefa no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> addPlantTasks(List<PlantTask> tasks) async {
    try {
      if (kDebugMode) {
        print(
          '💾 PlantTasksLocalDatasource: Salvando ${tasks.length} tasks em lote',
        );
      }

      for (final task in tasks) {
        try {
          final taskModel = PlantTaskModel.fromEntity(task);
          await _driftRepo.insertPlantTask(taskModel);
        } catch (e) {
          final msg = e.toString();
          if (msg.contains('Plant not found locally')) {
            if (kDebugMode) {
              print(
                '⚠️ PlantTasksLocalDatasource: Skipping task ${task.id} in batch because plant is not cached yet',
              );
            }
            continue;
          }
          rethrow;
        }
      }
      _invalidateCache();

      if (kDebugMode) {
        print(
          '✅ PlantTasksLocalDatasource: ${tasks.length} tasks salvas em lote com sucesso',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksLocalDatasource: Erro ao salvar tasks em lote: $e');
      }
      throw CacheFailure(
        'Erro ao salvar tarefas em lote no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updatePlantTask(PlantTask task) async {
    try {
      final taskModel = PlantTaskModel.fromEntity(task).markAsDirty();
      await _driftRepo.updatePlantTask(taskModel);
      _invalidateCache();

      if (kDebugMode) {
        print(
          '✅ PlantTasksLocalDatasource: Task ${task.id} atualizada com sucesso',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksLocalDatasource: Erro ao atualizar task: $e');
      }
      throw CacheFailure(
        'Erro ao atualizar tarefa no cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deletePlantTask(String id) async {
    try {
      await _driftRepo.deletePlantTask(id);
      _invalidateCache();

      if (kDebugMode) {
        print('✅ PlantTasksLocalDatasource: Task $id marcada como deletada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksLocalDatasource: Erro ao deletar task: $e');
      }
      throw CacheFailure(
        'Erro ao deletar tarefa do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deletePlantTasksByPlantId(String plantId) async {
    try {
      if (kDebugMode) {
        print(
          '🗑️ PlantTasksLocalDatasource: Deletando todas as tasks da planta $plantId',
        );
      }

      final deleted = await _driftRepo.deletePlantTasksByPlantId(plantId);
      _invalidateCache();

      if (kDebugMode) {
        print(
          '✅ PlantTasksLocalDatasource: $deleted tasks da planta $plantId deletadas',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ PlantTasksLocalDatasource: Erro ao deletar tasks por plantId: $e',
        );
      }
      throw CacheFailure(
        'Erro ao deletar tarefas por planta do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PlantTask>> getPendingPlantTasks() async {
    try {
      final allTasks = await getPlantTasks();
      return allTasks
          .where((task) => task.status == TaskStatus.pending)
          .toList();
    } catch (e) {
      throw CacheFailure(
        'Erro ao buscar tarefas pendentes do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PlantTask>> getOverduePlantTasks() async {
    try {
      final allTasks = await getPlantTasks();
      return allTasks
          .where((task) => task.status == TaskStatus.overdue)
          .toList();
    } catch (e) {
      throw CacheFailure(
        'Erro ao buscar tarefas atrasadas do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PlantTask>> getTodayPlantTasks() async {
    try {
      final allTasks = await getPlantTasks();
      return allTasks.where((task) => task.isDueToday).toList();
    } catch (e) {
      throw CacheFailure(
        'Erro ao buscar tarefas de hoje do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PlantTask>> getUpcomingPlantTasks() async {
    try {
      final allTasks = await getPlantTasks();
      return allTasks.where((task) => task.isDueSoon).toList();
    } catch (e) {
      throw CacheFailure(
        'Erro ao buscar tarefas próximas do cache local: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _driftRepo.clearAll();
      _invalidateCache();

      if (kDebugMode) {
        print('✅ PlantTasksLocalDatasource: Cache limpo com sucesso');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksLocalDatasource: Erro ao limpar cache: $e');
      }
      throw CacheFailure('Erro ao limpar cache local: ${e.toString()}');
    }
  }

  /// Invalidate memory cache
  void _invalidateCache() {
    _cachedTasks = null;
    _cacheTimestamp = null;
  }

  /// Get cache statistics for monitoring
  Map<String, dynamic> getCacheStats() {
    return {
      'tasksCache': {
        'cached': _cachedTasks != null,
        'cacheSize': _cachedTasks?.length ?? 0,
        'cacheAge': _cacheTimestamp != null
            ? DateTime.now().difference(_cacheTimestamp!).inMinutes
            : null,
      },
    };
  }
}
