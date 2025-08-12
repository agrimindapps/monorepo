import 'package:dartz/dartz.dart' hide Task;
import 'package:core/core.dart';
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
      if (await networkInfo.isConnected) {
        final remoteTasks = await remoteDataSource.getTasks();
        await localDataSource.cacheTasks(remoteTasks);
        return Right(remoteTasks.cast<Task>());
      } else {
        final localTasks = await localDataSource.getTasks();
        return Right(localTasks.cast<Task>());
      }
    } on Exception catch (e) {
      final localTasks = await localDataSource.getTasks();
      if (localTasks.isNotEmpty) {
        return Right(localTasks.cast<Task>());
      }
      return Left(ServerFailure('Erro ao buscar tarefas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByPlantId(String plantId) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteTasks = await remoteDataSource.getTasksByPlantId(plantId);
        // Cache apenas as tarefas desta planta específica
        for (final task in remoteTasks) {
          await localDataSource.cacheTask(task);
        }
        return Right(remoteTasks.cast<Task>());
      } else {
        final localTasks = await localDataSource.getTasksByPlantId(plantId);
        return Right(localTasks.cast<Task>());
      }
    } on Exception catch (e) {
      final localTasks = await localDataSource.getTasksByPlantId(plantId);
      if (localTasks.isNotEmpty) {
        return Right(localTasks.cast<Task>());
      }
      return Left(ServerFailure('Erro ao buscar tarefas por planta: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByStatus(TaskStatus status) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteTasks = await remoteDataSource.getTasksByStatus(status);
        for (final task in remoteTasks) {
          await localDataSource.cacheTask(task);
        }
        return Right(remoteTasks.cast<Task>());
      } else {
        final localTasks = await localDataSource.getTasksByStatus(status);
        return Right(localTasks.cast<Task>());
      }
    } on Exception catch (e) {
      final localTasks = await localDataSource.getTasksByStatus(status);
      if (localTasks.isNotEmpty) {
        return Right(localTasks.cast<Task>());
      }
      return Left(ServerFailure('Erro ao buscar tarefas por status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getOverdueTasks() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteTasks = await remoteDataSource.getOverdueTasks();
        for (final task in remoteTasks) {
          await localDataSource.cacheTask(task);
        }
        return Right(remoteTasks.cast<Task>());
      } else {
        final localTasks = await localDataSource.getOverdueTasks();
        return Right(localTasks.cast<Task>());
      }
    } on Exception catch (e) {
      final localTasks = await localDataSource.getOverdueTasks();
      if (localTasks.isNotEmpty) {
        return Right(localTasks.cast<Task>());
      }
      return Left(ServerFailure('Erro ao buscar tarefas atrasadas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTodayTasks() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteTasks = await remoteDataSource.getTodayTasks();
        for (final task in remoteTasks) {
          await localDataSource.cacheTask(task);
        }
        return Right(remoteTasks.cast<Task>());
      } else {
        final localTasks = await localDataSource.getTodayTasks();
        return Right(localTasks.cast<Task>());
      }
    } on Exception catch (e) {
      final localTasks = await localDataSource.getTodayTasks();
      if (localTasks.isNotEmpty) {
        return Right(localTasks.cast<Task>());
      }
      return Left(ServerFailure('Erro ao buscar tarefas de hoje: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getUpcomingTasks() async {
    try {
      if (await networkInfo.isConnected) {
        final remoteTasks = await remoteDataSource.getUpcomingTasks();
        for (final task in remoteTasks) {
          await localDataSource.cacheTask(task);
        }
        return Right(remoteTasks.cast<Task>());
      } else {
        final localTasks = await localDataSource.getUpcomingTasks();
        return Right(localTasks.cast<Task>());
      }
    } on Exception catch (e) {
      final localTasks = await localDataSource.getUpcomingTasks();
      if (localTasks.isNotEmpty) {
        return Right(localTasks.cast<Task>());
      }
      return Left(ServerFailure('Erro ao buscar tarefas próximas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteTask = await remoteDataSource.getTaskById(id);
        if (remoteTask != null) {
          await localDataSource.cacheTask(remoteTask);
          return Right(remoteTask);
        }
      }
      
      final localTask = await localDataSource.getTaskById(id);
      if (localTask != null) {
        return Right(localTask);
      }
      
      return Left(NotFoundFailure('Tarefa não encontrada'));
    } on Exception catch (e) {
      final localTask = await localDataSource.getTaskById(id);
      if (localTask != null) {
        return Right(localTask);
      }
      return Left(ServerFailure('Erro ao buscar tarefa: ${e.toString()}'));
    }
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
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao adicionar tarefa: ${e.toString()}'));
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
      
      return taskResult.fold(
        (failure) => Left(failure),
        (task) async {
          final completedTask = task.copyWithTaskData(
            status: TaskStatus.completed,
            completedAt: DateTime.now(),
            completionNotes: notes,
          );
          
          return await updateTask(completedTask);
        },
      );
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao completar tarefa: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markTaskAsOverdue(String id) async {
    try {
      final taskResult = await getTaskById(id);
      
      return taskResult.fold(
        (failure) => Left(failure),
        (task) async {
          final overdueTask = task.copyWithTaskData(
            status: TaskStatus.overdue,
          );
          
          final updateResult = await updateTask(overdueTask);
          return updateResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        },
      );
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao marcar tarefa como atrasada: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Task>> createRecurringTask(Task completedTask) async {
    try {
      if (!completedTask.isRecurring || completedTask.recurringIntervalDays == null) {
        return Left(ValidationFailure('Tarefa não é recorrente ou não tem intervalo definido'));
      }

      final nextDueDate = completedTask.nextDueDate ?? 
          completedTask.dueDate.add(Duration(days: completedTask.recurringIntervalDays!));

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
        nextDueDate: nextDueDate.add(Duration(days: completedTask.recurringIntervalDays!)),
      );

      return await addTask(newTask);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao criar tarefa recorrente: ${e.toString()}'));
    }
  }
}