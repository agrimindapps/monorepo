import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/plant_task.dart';
import '../../models/plant_task_model.dart';

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
  static const String _boxName = 'plant_tasks';
  Box<String>? _box;

  // Cache for performance optimization
  List<PlantTask>? _cachedTasks;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(minutes: 5);

  Future<Box<String>> get box async {
    _box ??= await Hive.openBox<String>(_boxName);
    return _box!;
  }

  @override
  Future<List<PlantTask>> getPlantTasks() async {
    try {
      // Check if cache is still valid
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

      final hiveBox = await box;
      final tasks = <PlantTask>[];

      if (kDebugMode) {
        print(
          '📥 PlantTasksLocalDatasource: Carregando ${hiveBox.length} tasks do Hive',
        );
      }

      for (final key in hiveBox.keys) {
        try {
          final taskJson = hiveBox.get(key);
          if (taskJson != null) {
            final taskData = jsonDecode(taskJson) as Map<String, dynamic>;
            final taskModel = PlantTaskModel.fromJson(taskData);
            if (!taskModel.isDeleted) {
              tasks.add(taskModel.toEntity());
            }
          }
        } catch (e) {
          // Log corrupted data and remove from Hive
          if (kDebugMode) {
            print(
              '❌ PlantTasksLocalDatasource: Dados corrompidos para key $key: $e',
            );
          }
          try {
            await hiveBox.delete(key);
            if (kDebugMode) {
              print(
                '🗑️ PlantTasksLocalDatasource: Dados corrompidos removidos para key: $key',
              );
            }
          } catch (deleteError) {
            if (kDebugMode) {
              print(
                '❌ PlantTasksLocalDatasource: Falha ao remover dados corrompidos para key $key: $deleteError',
              );
            }
          }
          continue;
        }
      }

      // Sort by scheduled date
      tasks.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

      // Update cache
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
      final allTasks = await getPlantTasks();
      final plantTasks =
          allTasks.where((task) => task.plantId == plantId).toList();

      if (kDebugMode) {
        print(
          '📥 PlantTasksLocalDatasource: ${plantTasks.length} tasks encontradas para planta $plantId',
        );
      }

      return plantTasks;
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
      final hiveBox = await box;
      final taskJson = hiveBox.get(id);

      if (taskJson == null) {
        return null;
      }

      try {
        final taskData = jsonDecode(taskJson) as Map<String, dynamic>;
        final taskModel = PlantTaskModel.fromJson(taskData);

        return taskModel.isDeleted ? null : taskModel.toEntity();
      } catch (corruptionError) {
        // Handle corrupted individual task data
        if (kDebugMode) {
          print(
            '❌ PlantTasksLocalDatasource: Dados corrompidos para ID $id: $corruptionError',
          );
        }
        try {
          await hiveBox.delete(id);
          if (kDebugMode) {
            print(
              '🗑️ PlantTasksLocalDatasource: Dados corrompidos removidos para ID: $id',
            );
          }
        } catch (deleteError) {
          if (kDebugMode) {
            print(
              '❌ PlantTasksLocalDatasource: Falha ao remover dados corrompidos para ID $id: $deleteError',
            );
          }
        }
        return null;
      }
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

      final hiveBox = await box;
      final taskModel = PlantTaskModel.fromEntity(task);
      final taskJson = jsonEncode(taskModel.toJson());

      await hiveBox.put(task.id, taskJson);

      // Invalidate cache
      _invalidateCache();

      if (kDebugMode) {
        print('✅ PlantTasksLocalDatasource: Task ${task.id} salva com sucesso');
      }
    } catch (e) {
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

      final hiveBox = await box;

      for (final task in tasks) {
        final taskModel = PlantTaskModel.fromEntity(task);
        final taskJson = jsonEncode(taskModel.toJson());
        await hiveBox.put(task.id, taskJson);
      }

      // Invalidate cache
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
      final hiveBox = await box;
      final taskModel = PlantTaskModel.fromEntity(task).markAsDirty();
      final taskJson = jsonEncode(taskModel.toJson());
      await hiveBox.put(task.id, taskJson);

      // Invalidate cache
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
      final hiveBox = await box;

      // Get existing task first for soft delete
      final taskJson = hiveBox.get(id);
      if (taskJson != null) {
        final taskData = jsonDecode(taskJson) as Map<String, dynamic>;
        final taskModel = PlantTaskModel.fromJson(taskData);

        // Soft delete - mark as deleted
        final deletedTask = taskModel.markAsDeleted();

        final updatedJson = jsonEncode(deletedTask.toJson());
        await hiveBox.put(id, updatedJson);

        // Invalidate cache
        _invalidateCache();

        if (kDebugMode) {
          print('✅ PlantTasksLocalDatasource: Task $id marcada como deletada');
        }
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

      final tasks = await getPlantTasksByPlantId(plantId);

      for (final task in tasks) {
        await deletePlantTask(task.id);
      }

      if (kDebugMode) {
        print(
          '✅ PlantTasksLocalDatasource: ${tasks.length} tasks da planta $plantId deletadas',
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
      final hiveBox = await box;
      await hiveBox.clear();

      // Clear memory cache
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
        'cacheAge':
            _cacheTimestamp != null
                ? DateTime.now().difference(_cacheTimestamp!).inMinutes
                : null,
      },
    };
  }
}
