import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/typedef.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl({
    TaskRemoteDataSource? remoteDataSource,
    required TaskLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final TaskRemoteDataSource? _remoteDataSource;
  final TaskLocalDataSource _localDataSource;

  @override
  ResultFuture<String> createTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      
      // Se tiver remote data source, sincronizar
      if (_remoteDataSource != null) {
        final taskId = await _remoteDataSource!.createTask(taskModel);
        final updatedTask = taskModel.copyWith(id: taskId);
        await _localDataSource.cacheTask(updatedTask);
        return Right(taskId);
      } else {
        // Modo offline - salvar apenas localmente
        await _localDataSource.cacheTask(taskModel);
        return Right(taskModel.id);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<TaskEntity> getTask(String id) async {
    try {
      final localTask = await _localDataSource.getTask(id);
      if (localTask != null) {
        return Right(localTask);
      }

      // Se tiver remote data source, buscar remotamente
      if (_remoteDataSource != null) {
        final remoteTask = await _remoteDataSource!.getTask(id);
        await _localDataSource.cacheTask(remoteTask);
        return Right(remoteTask);
      } else {
        // Modo offline - retornar erro se não encontrar localmente
        return const Left(CacheFailure('Task not found locally'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<TaskEntity>> getTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
    DateTime? dueBefore,
    DateTime? dueAfter,
  }) async {
    try {
      // Se tiver remote data source, tentar buscar remotamente primeiro
      if (_remoteDataSource != null) {
        try {
          final remoteTasks = await _remoteDataSource!.getTasks(
            listId: listId,
            userId: userId,
            status: status,
            priority: priority,
            isStarred: isStarred,
            dueBefore: dueBefore,
            dueAfter: dueAfter,
          );
          
          await _localDataSource.cacheTasks(remoteTasks);
          return Right(remoteTasks);
        } catch (e) {
          // Fallback para local se remoto falhar
        }
      }
      
      // Buscar localmente
      final localTasks = await _localDataSource.getTasks(
        listId: listId,
        userId: userId,
        status: status,
        priority: priority,
        isStarred: isStarred,
      );
      // Filtrar subtasks da lista principal (apenas tarefas principais)
      final mainTasks = localTasks.where((task) => task.parentTaskId == null).toList();
      return Right(mainTasks);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      
      // Sempre atualizar localmente
      await _localDataSource.updateTask(taskModel);
      
      // Se tiver remote data source, sincronizar
      if (_remoteDataSource != null) {
        await _remoteDataSource!.updateTask(taskModel);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteTask(String id) async {
    try {
      // Sempre deletar localmente
      await _localDataSource.deleteTask(id);
      
      // Se tiver remote data source, sincronizar
      if (_remoteDataSource != null) {
        await _remoteDataSource!.deleteTask(id);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> updateTaskStatus(String id, TaskStatus status) async {
    try {
      final localTask = await _localDataSource.getTask(id);
      if (localTask != null) {
        final updatedTask = localTask.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        await _localDataSource.updateTask(updatedTask);
      }
      
      // Se tiver remote data source, sincronizar
      if (_remoteDataSource != null) {
        await _remoteDataSource!.updateTaskStatus(id, status);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> toggleTaskStar(String id) async {
    try {
      final localTask = await _localDataSource.getTask(id);
      if (localTask != null) {
        final updatedTask = localTask.copyWith(
          isStarred: !localTask.isStarred,
          updatedAt: DateTime.now(),
        );
        await _localDataSource.updateTask(updatedTask);
      }
      
      // Se tiver remote data source, sincronizar
      if (_remoteDataSource != null) {
        await _remoteDataSource!.toggleTaskStar(id);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> reorderTasks(List<String> taskIds) async {
    try {
      // Atualizar posições localmente
      final List<TaskModel> updatedTasks = [];
      
      for (int i = 0; i < taskIds.length; i++) {
        final taskId = taskIds[i];
        final localTask = await _localDataSource.getTask(taskId);
        
        if (localTask != null) {
          // Atualizar posição da task
          final updatedTask = localTask.copyWith(
            position: i,
            updatedAt: DateTime.now(),
          );
          updatedTasks.add(updatedTask);
        }
      }
      
      // Salvar todas as tasks atualizadas em batch
      if (updatedTasks.isNotEmpty) {
        await _localDataSource.cacheTasks(updatedTasks);
      }
      
      // Se tiver remote data source, sincronizar
      if (_remoteDataSource != null) {
        await _remoteDataSource!.reorderTasks(taskIds);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<TaskEntity>> watchTasks({
    String? listId,
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
    bool? isStarred,
  }) {
    // Se tiver remote data source, usar stream remoto
    if (_remoteDataSource != null) {
      return _remoteDataSource!.watchTasks(
        listId: listId,
        userId: userId,
        status: status,
        priority: priority,
        isStarred: isStarred,
      );
    } else {
      // Modo offline - usar stream local
      return _localDataSource.watchTasks(
        listId: listId,
        userId: userId,
        status: status,
        priority: priority,
        isStarred: isStarred,
      );
    }
  }

  @override
  ResultFuture<List<TaskEntity>> searchTasks(String query) async {
    try {
      // Se tiver remote data source, buscar remotamente
      if (_remoteDataSource != null) {
        final tasks = await _remoteDataSource!.searchTasks(query);
        return Right(tasks);
      } else {
        // Modo offline - buscar localmente
        final allTasks = await _localDataSource.getTasks();
        final filteredTasks = allTasks.where((task) {
          return task.title.toLowerCase().contains(query.toLowerCase()) ||
                 (task.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                 task.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
        }).toList();
        return Right(filteredTasks);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<TaskEntity>> getSubtasks(String parentTaskId) async {
    try {
      // Se tiver remote data source, buscar remotamente primeiro
      if (_remoteDataSource != null) {
        try {
          final remoteTasks = await _remoteDataSource!.getSubtasks(parentTaskId);
          await _localDataSource.cacheTasks(remoteTasks);
          return Right(remoteTasks);
        } catch (e) {
          // Fallback para local se remoto falhar
        }
      }
      
      // Buscar subtasks localmente
      final allTasks = await _localDataSource.getTasks();
      final subtasks = allTasks.where((task) => task.parentTaskId == parentTaskId).toList();
      return Right(subtasks);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}