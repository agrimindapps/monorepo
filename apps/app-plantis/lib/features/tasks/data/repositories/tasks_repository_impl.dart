import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../core/data/adapters/network_info_adapter.dart';
import '../../../../core/interfaces/network_info.dart';
import '../../../plants/domain/repositories/plants_repository.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../../domain/repositories/tasks_repository.dart';
import '../datasources/local/tasks_local_datasource.dart';
import '../datasources/remote/tasks_remote_datasource.dart';
import '../models/task_model.dart';

typedef Task = task_entity.Task;
typedef TaskStatus = task_entity.TaskStatus;

class TasksRepositoryImpl implements TasksRepository {
  final TasksRemoteDataSource remoteDataSource;
  final TasksLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final IAuthRepository authService;
  final PlantsRepository plantsRepository;

  TasksRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.authService,
    required this.plantsRepository,
  });

  Future<String?> get _currentUserId async {
    return await _getCurrentUserIdWithRetry();
  }

  /// Get current user ID with retry logic to handle auth race conditions
  Future<String?> _getCurrentUserIdWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final timeoutDuration = Duration(seconds: 2 * attempt);
        final user = await authService.currentUser
            .timeout(timeoutDuration)
            .first;

        if (user != null && user.id.isNotEmpty) {
          return user.id;
        }
        if (attempt < maxRetries) {
          await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
          continue;
        }

        return null;
      } catch (e) {
        if (kDebugMode) {
          print('Auth attempt $attempt/$maxRetries failed: $e');
        }
        if (attempt >= maxRetries) {
          return null;
        }
        await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
      }
    }

    return null;
  }

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(
          ServerFailure(
            'Usuário não autenticado. Aguarde a inicialização ou faça login.',
          ),
        );
      }

      // Get all tasks
      final localTasks = await localDataSource.getTasks();
      List<Task> tasksToReturn = localTasks.cast<Task>();

      // Get all plants to filter out tasks from deleted plants
      final plantsResult = await plantsRepository.getPlants();
      final activePlantIds = plantsResult.fold(
        (failure) =>
            <
              String
            >{}, // If we can't get plants, return empty set (no filtering)
        (plants) => plants
            .where((plant) => !plant.isDeleted)
            .map((plant) => plant.id)
            .toSet(),
      );

      // Filter tasks to only include those from active (non-deleted) plants
      if (activePlantIds.isNotEmpty) {
        tasksToReturn = tasksToReturn
            .where((task) => activePlantIds.contains(task.plantId))
            .toList();
      }

      if (tasksToReturn.isNotEmpty) {
        if (await networkInfo.isConnected) {
          _syncTasksInBackground(userId);
        }
        return Right(tasksToReturn);
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteTasks = await remoteDataSource.getTasks(userId);
          // Also filter remote tasks
          final filteredRemoteTasks = activePlantIds.isNotEmpty
              ? remoteTasks
                    .where((task) => activePlantIds.contains(task.plantId))
                    .toList()
              : remoteTasks;
          await localDataSource.cacheTasks(filteredRemoteTasks);
          return Right(filteredRemoteTasks.cast<Task>());
        } catch (e) {
          if (kDebugMode) {
            print('❌ TasksRepository: Remote fetch failed: $e');
          }
          return Left(
            ServerFailure('Falha ao sincronizar tarefas: ${e.toString()}'),
          );
        }
      } else {
        return Right(tasksToReturn); // Return filtered local tasks if offline
      }
    } on Exception {
      final localTasks = await localDataSource.getTasks();
      // Also filter in exception case
      final plantsResult = await plantsRepository.getPlants();
      final activePlantIds = plantsResult.fold(
        (failure) => <String>{},
        (plants) => plants
            .where((plant) => !plant.isDeleted)
            .map((plant) => plant.id)
            .toSet(),
      );
      final filteredTasks = activePlantIds.isNotEmpty
          ? localTasks
                .where((task) => activePlantIds.contains(task.plantId))
                .toList()
          : localTasks;
      return Right(filteredTasks.cast<Task>());
    }
  }

  void _syncTasksInBackground(String userId) async {
    try {
      final syncStrategy = await _determineSyncStrategy();
      switch (syncStrategy) {
        case SyncStrategy.aggressive:
          _performAggressiveSync(userId);
          break;
        case SyncStrategy.conservative:
          _performConservativeSync(userId);
          break;
        case SyncStrategy.minimal:
          _performMinimalSync(userId);
          break;
        case SyncStrategy.disabled:
          if (kDebugMode) {
            print('🚫 TasksRepository: Sync skipped due to poor connection');
          }
          return;
      }
    } catch (e) {
      _performBasicSync(userId);
    }
  }

  /// ENHANCED FEATURE: Determine optimal sync strategy based on connection type and stability
  Future<SyncStrategy> _determineSyncStrategy() async {
    try {
      final enhanced = networkInfo.asEnhanced;
      if (enhanced == null) {
        return SyncStrategy.conservative; // Fallback for basic NetworkInfo
      }
      final isStable = await enhanced.isStable;
      if (!isStable) {
        return SyncStrategy.disabled;
      }
      final connectionType = await enhanced.connectionType;
      switch (connectionType) {
        case ConnectivityType.wifi:
        case ConnectivityType.ethernet:
          return SyncStrategy.aggressive;
        case ConnectivityType.mobile:
          return SyncStrategy.conservative;
        case ConnectivityType.bluetooth:
        case ConnectivityType.vpn:
          return SyncStrategy.minimal;
        case ConnectivityType.none:
        case ConnectivityType.offline:
        case null:
          return SyncStrategy.disabled;
        default:
          return SyncStrategy.conservative;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ TasksRepository: Error determining sync strategy: $e');
      }
      return SyncStrategy.conservative; // Safe fallback
    }
  }

  /// Aggressive sync for fast, stable connections (WiFi/Ethernet)
  void _performAggressiveSync(String userId) async {
    try {
      final stopwatch = Stopwatch()..start();
      final remoteTasks = await remoteDataSource.getTasks(userId);
      await localDataSource.cacheTasks(remoteTasks);
      stopwatch.stop();

      if (kDebugMode) {
        print(
          '✅ TasksRepository: Aggressive sync completed in ${stopwatch.elapsedMilliseconds}ms',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ TasksRepository: Aggressive sync failed: $e');
      }
    }
  }

  /// Conservative sync for mobile data - smaller batches, less frequent
  void _performConservativeSync(String userId) async {
    try {
      final remoteTasks = await remoteDataSource
          .getTasks(userId)
          .timeout(const Duration(seconds: 10));
      await localDataSource.cacheTasks(remoteTasks);

      if (kDebugMode) {
        print('✅ TasksRepository: Conservative sync completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ TasksRepository: Conservative sync failed: $e');
      }
    }
  }

  /// Minimal sync for slow connections - only critical updates
  void _performMinimalSync(String userId) async {
    try {
      if (kDebugMode) {
        print('⏸️ TasksRepository: Minimal sync - skipping for better UX');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ TasksRepository: Minimal sync failed: $e');
      }
    }
  }

  /// Fallback to basic sync when enhanced features are unavailable
  void _performBasicSync(String userId) {
    remoteDataSource
        .getTasks(userId)
        .then((remoteTasks) {
          localDataSource.cacheTasks(remoteTasks);
          if (kDebugMode) {
            print('✅ TasksRepository: Basic sync completed');
          }
        })
        .catchError((Object e) {
          if (kDebugMode) {
            print('❌ TasksRepository: Basic sync failed: $e');
          }
        });
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByPlantId(String plantId) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }
      final localTasks = await localDataSource.getTasksByPlantId(plantId);
      if (localTasks.isNotEmpty) {
        if (await networkInfo.isConnected) {
          _syncTasksByPlantInBackground(plantId, userId);
        }
        return Right(localTasks.cast<Task>());
      }
      if (await networkInfo.isConnected) {
        try {
          final remoteTasks = await remoteDataSource.getTasksByPlantId(
            plantId,
            userId,
          );
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

  void _syncTasksByPlantInBackground(String plantId, String userId) {
    remoteDataSource
        .getTasksByPlantId(plantId, userId)
        .then((remoteTasks) {
          for (final task in remoteTasks) {
            localDataSource.cacheTask(task);
          }
        })
        .catchError((Object e) {});
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByStatus(
    TaskStatus status,
  ) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }
      final localTasks = await localDataSource.getTasksByStatus(status);
      if (await networkInfo.isConnected) {
        _syncTasksByStatusInBackground(status, userId);
      }
      return Right(localTasks.cast<Task>());
    } on Exception {
      final localTasks = await localDataSource.getTasksByStatus(status);
      return Right(localTasks.cast<Task>());
    }
  }

  void _syncTasksByStatusInBackground(TaskStatus status, String userId) {
    remoteDataSource
        .getTasksByStatus(status, userId)
        .then((remoteTasks) {
          for (final task in remoteTasks) {
            localDataSource.cacheTask(task);
          }
        })
        .catchError((e) {});
  }

  @override
  Future<Either<Failure, List<Task>>> getOverdueTasks() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }
      final localTasks = await localDataSource.getOverdueTasks();
      if (localTasks.isNotEmpty) {
        if (await networkInfo.isConnected) {
          _syncOverdueTasksInBackground(userId);
        }
        return Right(localTasks.cast<Task>());
      }
      if (await networkInfo.isConnected) {
        try {
          final remoteTasks = await remoteDataSource.getOverdueTasks(userId);
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

  void _syncOverdueTasksInBackground(String userId) {
    remoteDataSource
        .getOverdueTasks(userId)
        .then((remoteTasks) {
          for (final task in remoteTasks) {
            localDataSource.cacheTask(task);
          }
        })
        .catchError((e) {});
  }

  @override
  Future<Either<Failure, List<Task>>> getTodayTasks() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }
      final localTasks = await localDataSource.getTodayTasks();
      if (localTasks.isNotEmpty) {
        if (await networkInfo.isConnected) {
          _syncTodayTasksInBackground(userId);
        }
        return Right(localTasks.cast<Task>());
      }
      if (await networkInfo.isConnected) {
        try {
          final remoteTasks = await remoteDataSource.getTodayTasks(userId);
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

  void _syncTodayTasksInBackground(String userId) {
    remoteDataSource
        .getTodayTasks(userId)
        .then((remoteTasks) {
          for (final task in remoteTasks) {
            localDataSource.cacheTask(task);
          }
        })
        .catchError((e) {});
  }

  @override
  Future<Either<Failure, List<Task>>> getUpcomingTasks() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }
      final localTasks = await localDataSource.getUpcomingTasks();
      if (await networkInfo.isConnected) {
        _syncUpcomingTasksInBackground(userId);
      }
      return Right(localTasks.cast<Task>());
    } on Exception {
      final localTasks = await localDataSource.getUpcomingTasks();
      return Right(localTasks.cast<Task>());
    }
  }

  void _syncUpcomingTasksInBackground(String userId) {
    remoteDataSource
        .getUpcomingTasks(userId)
        .then((remoteTasks) {
          for (final task in remoteTasks) {
            localDataSource.cacheTask(task);
          }
        })
        .catchError((e) {});
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }
      final localTask = await localDataSource.getTaskById(id);
      if (await networkInfo.isConnected) {
        _syncTaskByIdInBackground(id, userId);
      }
      if (localTask != null) {
        return Right(localTask as Task);
      } else {
        return const Left(ServerFailure('Tarefa não encontrada'));
      }
    } on Exception {
      final localTask = await localDataSource.getTaskById(id);
      if (localTask != null) {
        return Right(localTask as Task);
      }
      return const Left(ServerFailure('Erro ao buscar tarefa'));
    }
  }

  void _syncTaskByIdInBackground(String id, String userId) {
    remoteDataSource
        .getTaskById(id, userId)
        .then((remoteTask) {
          if (remoteTask != null) {
            localDataSource.cacheTask(remoteTask);
          }
        })
        .catchError((e) {});
  }

  @override
  Future<Either<Failure, Task>> addTask(Task task) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      final taskModel = TaskModel.fromEntity(task);

      if (await networkInfo.isConnected) {
        final remoteTask = await remoteDataSource.addTask(taskModel, userId);
        await localDataSource.cacheTask(remoteTask);
        return Right(remoteTask as Task);
      } else {
        final offlineTask = taskModel.markAsDirty();
        await localDataSource.cacheTask(offlineTask);
        return Right(offlineTask as Task);
      }
    } on Exception {
      return const Left(ServerFailure('Erro ao adicionar tarefa'));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      final taskModel = TaskModel.fromEntity(task);

      if (await networkInfo.isConnected) {
        final remoteTask = await remoteDataSource.updateTask(taskModel, userId);
        await localDataSource.updateTask(remoteTask);
        return Right(remoteTask as Task);
      } else {
        final offlineTask = taskModel.markAsDirty();
        await localDataSource.updateTask(offlineTask);
        return Right(offlineTask as Task);
      }
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao atualizar tarefa: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteTask(id, userId);
        await localDataSource.deleteTask(id);
      } else {
        await localDataSource.deleteTask(id);
      }

      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao deletar tarefa: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Task>> completeTask(
    String id, {
    String? notes,
    DateTime? nextDueDate,
  }) async {
    try {
      final taskResult = await getTaskById(id);

      return taskResult.fold((failure) => Left(failure), (task) async {
        final completedTask = task.copyWithTaskData(
          status: TaskStatus.completed,
          completedAt: DateTime.now(),
          completionNotes: notes,
          // Se o usuário informou uma próxima data, usa ela
          nextDueDate: nextDueDate,
        );

        // Atualiza a tarefa atual como concluída
        final updateResult = await updateTask(completedTask);

        // Se é uma tarefa recorrente, cria a próxima com a data informada
        if (task.isRecurring && nextDueDate != null) {
          await _createNextRecurringTaskWithDate(task, nextDueDate);
        }

        return updateResult;
      });
    } on Exception catch (e) {
      return Left(ServerFailure('Erro ao completar tarefa: ${e.toString()}'));
    }
  }

  /// Cria a próxima tarefa recorrente com a data informada pelo usuário
  Future<void> _createNextRecurringTaskWithDate(
    Task completedTask,
    DateTime nextDueDate,
  ) async {
    try {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        title: completedTask.title,
        description: completedTask.description,
        plantId: completedTask.plantId,
        type: completedTask.type,
        status: TaskStatus.pending,
        priority: completedTask.priority,
        dueDate: nextDueDate,
        isRecurring: true,
        recurringIntervalDays: completedTask.recurringIntervalDays,
        nextDueDate: completedTask.recurringIntervalDays != null
            ? nextDueDate.add(
                Duration(days: completedTask.recurringIntervalDays!),
              )
            : null,
      );

      await addTask(newTask);
    } catch (e) {
      debugPrint('⚠️ Erro ao criar próxima tarefa recorrente: $e');
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
          ServerFailure(
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

  /// ISP: Search tasks by query
  @override
  Future<Either<Failure, List<Task>>> searchTasks(String query) async {
    final result = await getTasks();
    return result.fold(
      (failure) => Left(failure),
      (tasks) => Right(
        tasks
            .where(
              (t) =>
                  t.title.toLowerCase().contains(query.toLowerCase()) ||
                  (t.description?.toLowerCase().contains(query.toLowerCase()) ??
                      false),
            )
            .toList(),
      ),
    );
  }

  /// ISP: Filter tasks by plant ID
  @override
  Future<Either<Failure, List<Task>>> filterByPlantId(String plantId) =>
      getTasksByPlantId(plantId);

  /// ISP: Filter tasks by status
  @override
  Future<Either<Failure, List<Task>>> filterByStatus(TaskStatus status) =>
      getTasksByStatus(status);

  /// ISP: Get statistics
  @override
  Future<Either<Failure, Map<String, dynamic>>> getStatistics() async {
    final result = await getTasks();
    return result.fold((failure) => Left(failure), (tasks) {
      final totalCount = tasks.length;
      final completedCount = tasks
          .where((t) => t.status == TaskStatus.completed)
          .length;
      final pendingCount = tasks
          .where((t) => t.status == TaskStatus.pending)
          .length;
      final overdueCount = tasks
          .where(
            (t) =>
                t.dueDate.isBefore(DateTime.now()) &&
                t.status != TaskStatus.completed,
          )
          .length;

      return Right({
        'total': totalCount,
        'completed': completedCount,
        'pending': pendingCount,
        'overdue': overdueCount,
        'completionRate': totalCount > 0
            ? completedCount / totalCount * 100
            : 0,
      });
    });
  }
}

/// ENHANCED FEATURE: Sync strategies based on connection type and quality
enum SyncStrategy { aggressive, conservative, minimal, disabled }
