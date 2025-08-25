import 'package:core/core.dart';
import 'package:dartz/dartz.dart' hide Task;

import '../../../../core/interfaces/network_info.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../../domain/repositories/tasks_repository.dart';
import '../datasources/local/tasks_local_datasource.dart';
import '../datasources/remote/tasks_remote_datasource.dart';
import '../models/task_model.dart';

// Type alias for easier reference
typedef Task = task_entity.Task;
typedef TaskStatus = task_entity.TaskStatus;

class TasksRepositoryImpl implements TasksRepository {
  final TasksRemoteDataSource remoteDataSource;
  final TasksLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TasksRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      // Always get from local first for instant UI response
      final localTasks = await localDataSource.getTasks();

      // If we have local data, return it immediately
      if (localTasks.isNotEmpty) {
        // Sync in background if connected (fire and forget)
        if (await networkInfo.isConnected) {
          _syncTasksInBackground();
        }
        return Right(localTasks.cast<Task>());
      }

      // If no local data, try remote as fallback
      if (await networkInfo.isConnected) {
        try {
          final remoteTasks = await remoteDataSource.getTasks();
          await localDataSource.cacheTasks(remoteTasks);
          return Right(remoteTasks.cast<Task>());
        } catch (e) {
          return Right(
            localTasks.cast<Task>(),
          ); // Return empty list if both fail
        }
      } else {
        return Right(
          localTasks.cast<Task>(),
        ); // Return empty list if offline and no cache
      }
    } on Exception {
      final localTasks = await localDataSource.getTasks();
      return Right(localTasks.cast<Task>());
    }
  }

  // Background sync method (fire and forget)
  void _syncTasksInBackground() {
    remoteDataSource
        .getTasks()
        .then((remoteTasks) {
          // Update local cache with remote data
          localDataSource.cacheTasks(remoteTasks);
        })
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByPlantId(String plantId) async {
    try {
      // Always get from local first for instant UI response
      final localTasks = await localDataSource.getTasksByPlantId(plantId);

      // If we have local data, return it immediately
      if (localTasks.isNotEmpty) {
        // Sync in background if connected (fire and forget)
        if (await networkInfo.isConnected) {
          _syncTasksByPlantInBackground(plantId);
        }
        return Right(localTasks.cast<Task>());
      }

      // If no local data, try remote as fallback
      if (await networkInfo.isConnected) {
        try {
          final remoteTasks = await remoteDataSource.getTasksByPlantId(plantId);
          for (final task in remoteTasks) {
            await localDataSource.cacheTask(task);
          }
          return Right(remoteTasks.cast<Task>());
        } catch (e) {
          return Right(localTasks.cast<Task>());
        }
      } else {
        return Right(localTasks.cast<Task>());
      }
    } on Exception {
      final localTasks = await localDataSource.getTasksByPlantId(plantId);
      return Right(localTasks.cast<Task>());
    }
  }

  void _syncTasksByPlantInBackground(String plantId) {
    remoteDataSource
        .getTasksByPlantId(plantId)
        .then((remoteTasks) {
          for (final task in remoteTasks) {
            localDataSource.cacheTask(task);
          }
        })
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByStatus(
    TaskStatus status,
  ) async {
    try {
      // Always get from local first for instant UI response
      final localTasks = await localDataSource.getTasksByStatus(status);

      // Start background sync if connected (fire and forget)
      if (await networkInfo.isConnected) {
        _syncTasksByStatusInBackground(status);
      }

      // Return local data immediately (empty list is fine)
      return Right(localTasks.cast<Task>());
    } on Exception {
      final localTasks = await localDataSource.getTasksByStatus(status);
      return Right(localTasks.cast<Task>());
    }
  }

  void _syncTasksByStatusInBackground(TaskStatus status) {
    remoteDataSource
        .getTasksByStatus(status)
        .then((remoteTasks) {
          for (final task in remoteTasks) {
            localDataSource.cacheTask(task);
          }
        })
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, List<Task>>> getOverdueTasks() async {
    try {
      // Always get from local first for instant UI response
      final localTasks = await localDataSource.getOverdueTasks();

      // If we have local data, return it immediately
      if (localTasks.isNotEmpty) {
        // Sync in background if connected (fire and forget)
        if (await networkInfo.isConnected) {
          _syncOverdueTasksInBackground();
        }
        return Right(localTasks.cast<Task>());
      }

      // If no local data, try remote as fallback
      if (await networkInfo.isConnected) {
        try {
          final remoteTasks = await remoteDataSource.getOverdueTasks();
          for (final task in remoteTasks) {
            await localDataSource.cacheTask(task);
          }
          return Right(remoteTasks.cast<Task>());
        } catch (e) {
          return Right(localTasks.cast<Task>());
        }
      } else {
        return Right(localTasks.cast<Task>());
      }
    } on Exception {
      final localTasks = await localDataSource.getOverdueTasks();
      return Right(localTasks.cast<Task>());
    }
  }

  void _syncOverdueTasksInBackground() {
    remoteDataSource
        .getOverdueTasks()
        .then((remoteTasks) {
          for (final task in remoteTasks) {
            localDataSource.cacheTask(task);
          }
        })
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, List<Task>>> getTodayTasks() async {
    try {
      // Always get from local first for instant UI response
      final localTasks = await localDataSource.getTodayTasks();

      // If we have local data, return it immediately
      if (localTasks.isNotEmpty) {
        // Sync in background if connected (fire and forget)
        if (await networkInfo.isConnected) {
          _syncTodayTasksInBackground();
        }
        return Right(localTasks.cast<Task>());
      }

      // If no local data, try remote as fallback
      if (await networkInfo.isConnected) {
        try {
          final remoteTasks = await remoteDataSource.getTodayTasks();
          for (final task in remoteTasks) {
            await localDataSource.cacheTask(task);
          }
          return Right(remoteTasks.cast<Task>());
        } catch (e) {
          return Right(localTasks.cast<Task>());
        }
      } else {
        return Right(localTasks.cast<Task>());
      }
    } on Exception {
      final localTasks = await localDataSource.getTodayTasks();
      return Right(localTasks.cast<Task>());
    }
  }

  void _syncTodayTasksInBackground() {
    remoteDataSource
        .getTodayTasks()
        .then((remoteTasks) {
          for (final task in remoteTasks) {
            localDataSource.cacheTask(task);
          }
        })
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, List<Task>>> getUpcomingTasks() async {
    try {
      // Always get from local first for instant UI response
      final localTasks = await localDataSource.getUpcomingTasks();

      // Start background sync if connected (fire and forget)
      if (await networkInfo.isConnected) {
        _syncUpcomingTasksInBackground();
      }

      // Return local data immediately (empty list is fine)
      return Right(localTasks.cast<Task>());
    } on Exception {
      final localTasks = await localDataSource.getUpcomingTasks();
      return Right(localTasks.cast<Task>());
    }
  }

  void _syncUpcomingTasksInBackground() {
    remoteDataSource
        .getUpcomingTasks()
        .then((remoteTasks) {
          for (final task in remoteTasks) {
            localDataSource.cacheTask(task);
          }
        })
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    try {
      // Always get from local first for instant response
      final localTask = await localDataSource.getTaskById(id);

      // Start background sync if connected (fire and forget)
      if (await networkInfo.isConnected) {
        _syncTaskByIdInBackground(id);
      }

      // Return local data immediately (or error if not found)
      if (localTask != null) {
        return Right(localTask);
      } else {
        return const Left(NotFoundFailure('Tarefa não encontrada'));
      }
    } on Exception {
      final localTask = await localDataSource.getTaskById(id);
      if (localTask != null) {
        return Right(localTask);
      }
      return const Left(ServerFailure('Erro ao buscar tarefa'));
    }
  }

  void _syncTaskByIdInBackground(String id) {
    remoteDataSource
        .getTaskById(id)
        .then((remoteTask) {
          if (remoteTask != null) {
            localDataSource.cacheTask(remoteTask);
          }
        })
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, Task>> addTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);

      if (await networkInfo.isConnected) {
        final remoteTask = await remoteDataSource.addTask(taskModel);
        await localDataSource.cacheTask(remoteTask);
        return Right(remoteTask);
      } else {
        // Offline: marca como dirty para sincronizar depois
        final offlineTask = taskModel.markAsDirty();
        await localDataSource.cacheTask(offlineTask);
        return Right(offlineTask);
      }
    } on Exception {
      return const Left(ServerFailure('Erro ao adicionar tarefa'));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);

      if (await networkInfo.isConnected) {
        final remoteTask = await remoteDataSource.updateTask(taskModel);
        await localDataSource.updateTask(remoteTask);
        return Right(remoteTask);
      } else {
        // Offline: marca como dirty para sincronizar depois
        final offlineTask = taskModel.markAsDirty();
        await localDataSource.updateTask(offlineTask);
        return Right(offlineTask);
      }
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao atualizar tarefa: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteTask(id);
        await localDataSource.deleteTask(id);
      } else {
        // Offline: marca como deletado localmente
        await localDataSource.deleteTask(id);
      }

      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao deletar tarefa: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Task>> completeTask(String id, {String? notes}) async {
    try {
      final taskResult = await getTaskById(id);

      return taskResult.fold((failure) => Left(failure), (task) async {
        final completedTask = task.copyWithTaskData(
          status: TaskStatus.completed,
          completedAt: DateTime.now(),
          completionNotes: notes,
        );

        return await updateTask(completedTask);
      });
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao completar tarefa: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markTaskAsOverdue(String id) async {
    try {
      final taskResult = await getTaskById(id);

      return taskResult.fold((failure) => Left(failure), (task) async {
        final overdueTask = task.copyWithTaskData(status: TaskStatus.overdue);

        final updateResult = await updateTask(overdueTask);
        return updateResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      });
    } on Exception catch (e) {
      return Left(
        ServerFailure('Erro ao marcar tarefa como atrasada: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Task>> createRecurringTask(Task completedTask) async {
    try {
      if (!completedTask.isRecurring ||
          completedTask.recurringIntervalDays == null) {
        return const Left(
          ValidationFailure(
            'Tarefa não é recorrente ou não tem intervalo definido',
          ),
        );
      }

      final nextDueDate =
          completedTask.nextDueDate ??
          completedTask.dueDate.add(
            Duration(days: completedTask.recurringIntervalDays!),
          );

      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        title: completedTask.title,
        description: completedTask.description,
        plantId: completedTask.plantId,
        plantName: completedTask.plantName,
        type: completedTask.type,
        status: TaskStatus.pending,
        priority: completedTask.priority,
        dueDate: nextDueDate,
        isRecurring: true,
        recurringIntervalDays: completedTask.recurringIntervalDays,
        nextDueDate: nextDueDate.add(
          Duration(days: completedTask.recurringIntervalDays!),
        ),
      );

      return await addTask(newTask);
    } on Exception catch (e) {
      return Left(
        ServerFailure('Erro ao criar tarefa recorrente: ${e.toString()}'),
      );
    }
  }
}
