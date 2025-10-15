import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/failures.dart' as local_failures;
import '../../../core/utils/typedef.dart';
import '../domain/task_entity.dart';
import '../domain/task_repository.dart';
import 'task_local_datasource.dart';
import 'task_model.dart';
import 'task_remote_datasource.dart';

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._localDataSource) : _remoteDataSource = null;

  final TaskRemoteDataSource? _remoteDataSource;
  final TaskLocalDataSource _localDataSource;

  @override
  ResultFuture<String> createTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      if (_remoteDataSource != null) {
        final taskId = await _remoteDataSource.createTask(taskModel);
        final updatedTask = taskModel.copyWith(id: taskId);
        await _localDataSource.cacheTask(updatedTask);
        return Right(taskId);
      } else {
        await _localDataSource.cacheTask(taskModel);
        return Right(taskModel.id);
      }
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<TaskEntity> getTask(String id) async {
    try {
      final localTask = await _localDataSource.getTask(id);
      if (localTask != null) {
        return Right(localTask);
      }
      if (_remoteDataSource != null) {
        final remoteTask = await _remoteDataSource.getTask(id);
        await _localDataSource.cacheTask(remoteTask);
        return Right(remoteTask);
      } else {
        return const Left(
          local_failures.CacheFailure('Task not found locally'),
        );
      }
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
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
      if (_remoteDataSource != null) {
        try {
          final remoteTasks = await _remoteDataSource.getTasks(
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
          // Remote fetch failed, fallback to local cache
          debugPrint('⚠️ TaskRepository.getTasks: Failed to fetch from remote, using local cache: $e');
        }
      }
      final localTasks = await _localDataSource.getTasks(
        listId: listId,
        userId: userId,
        status: status,
        priority: priority,
        isStarred: isStarred,
      );
      final mainTasks =
          localTasks.where((task) => task.parentTaskId == null).toList();
      return Right(mainTasks);
    } catch (e) {
      return Left(local_failures.CacheFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await _localDataSource.updateTask(taskModel);
      if (_remoteDataSource != null) {
        await _remoteDataSource.updateTask(taskModel);
      }

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteTask(String id) async {
    try {
      await _localDataSource.deleteTask(id);
      if (_remoteDataSource != null) {
        await _remoteDataSource.deleteTask(id);
      }

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
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
      if (_remoteDataSource != null) {
        await _remoteDataSource.updateTaskStatus(id, status);
      }

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
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
      if (_remoteDataSource != null) {
        await _remoteDataSource.toggleTaskStar(id);
      }

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> reorderTasks(List<String> taskIds) async {
    try {
      final List<TaskModel> updatedTasks = [];

      for (int i = 0; i < taskIds.length; i++) {
        final taskId = taskIds[i];
        final localTask = await _localDataSource.getTask(taskId);

        if (localTask != null) {
          final updatedTask = localTask.copyWith(
            position: i,
            updatedAt: DateTime.now(),
          );
          updatedTasks.add(updatedTask);
        }
      }
      if (updatedTasks.isNotEmpty) {
        await _localDataSource.cacheTasks(updatedTasks);
      }
      if (_remoteDataSource != null) {
        await _remoteDataSource.reorderTasks(taskIds);
      }

      return const Right(null);
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
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
    if (_remoteDataSource != null) {
      return _remoteDataSource.watchTasks(
        listId: listId,
        userId: userId,
        status: status,
        priority: priority,
        isStarred: isStarred,
      );
    } else {
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
      if (_remoteDataSource != null) {
        final tasks = await _remoteDataSource.searchTasks(query);
        return Right(tasks);
      } else {
        final allTasks = await _localDataSource.getTasks();
        final filteredTasks =
            allTasks.where((task) {
              return task.title.toLowerCase().contains(query.toLowerCase()) ||
                  (task.description?.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ??
                      false) ||
                  task.tags.any(
                    (tag) => tag.toLowerCase().contains(query.toLowerCase()),
                  );
            }).toList();
        return Right(filteredTasks);
      }
    } catch (e) {
      return Left(local_failures.ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<TaskEntity>> getSubtasks(String parentTaskId) async {
    try {
      if (_remoteDataSource != null) {
        try {
          final remoteTasks = await _remoteDataSource.getSubtasks(parentTaskId);
          await _localDataSource.cacheTasks(remoteTasks);
          return Right(remoteTasks);
        } catch (e) {
          // Remote fetch failed, fallback to local cache
          debugPrint('⚠️ TaskRepository.getSubtasks: Failed to fetch from remote, using local cache: $e');
        }
      }
      final allTasks = await _localDataSource.getTasks();
      final subtasks =
          allTasks.where((task) => task.parentTaskId == parentTaskId).toList();
      return Right(subtasks);
    } catch (e) {
      return Left(local_failures.CacheFailure(e.toString()));
    }
  }
}
