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
    required TaskRemoteDataSource remoteDataSource,
    required TaskLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final TaskRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;

  @override
  ResultFuture<String> createTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final taskId = await _remoteDataSource.createTask(taskModel);
      
      final updatedTask = taskModel.copyWith(id: taskId);
      await _localDataSource.cacheTask(updatedTask);
      
      return Right(taskId);
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

      final remoteTask = await _remoteDataSource.getTask(id);
      await _localDataSource.cacheTask(remoteTask);
      
      return Right(remoteTask);
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
      try {
        final localTasks = await _localDataSource.getTasks(
          listId: listId,
          userId: userId,
          status: status,
          priority: priority,
          isStarred: isStarred,
        );
        return Right(localTasks);
      } catch (localError) {
        return Left(CacheFailure(localError.toString()));
      }
    }
  }

  @override
  ResultFuture<void> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await _remoteDataSource.updateTask(taskModel);
      await _localDataSource.updateTask(taskModel);
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteTask(String id) async {
    try {
      await _remoteDataSource.deleteTask(id);
      await _localDataSource.deleteTask(id);
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> updateTaskStatus(String id, TaskStatus status) async {
    try {
      await _remoteDataSource.updateTaskStatus(id, status);
      
      final localTask = await _localDataSource.getTask(id);
      if (localTask != null) {
        final updatedTask = localTask.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        await _localDataSource.updateTask(updatedTask);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> toggleTaskStar(String id) async {
    try {
      await _remoteDataSource.toggleTaskStar(id);
      
      final localTask = await _localDataSource.getTask(id);
      if (localTask != null) {
        final updatedTask = localTask.copyWith(
          isStarred: !localTask.isStarred,
          updatedAt: DateTime.now(),
        );
        await _localDataSource.updateTask(updatedTask);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> reorderTasks(List<String> taskIds) async {
    try {
      await _remoteDataSource.reorderTasks(taskIds);
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
    return _remoteDataSource.watchTasks(
      listId: listId,
      userId: userId,
      status: status,
      priority: priority,
      isStarred: isStarred,
    );
  }

  @override
  ResultFuture<List<TaskEntity>> searchTasks(String query) async {
    try {
      final tasks = await _remoteDataSource.searchTasks(query);
      return Right(tasks);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}