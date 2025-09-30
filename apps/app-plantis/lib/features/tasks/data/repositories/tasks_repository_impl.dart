import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/adapters/network_info_adapter.dart';
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
  final IAuthRepository authService;

  TasksRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.authService,
  });

  Future<String?> get _currentUserId async {
    return await _getCurrentUserIdWithRetry();
  }

  /// Get current user ID with retry logic to handle auth race conditions
  Future<String?> _getCurrentUserIdWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Wait for user with increasing timeout per attempt
        final timeoutDuration = Duration(seconds: 2 * attempt);
        final user =
            await authService.currentUser.timeout(timeoutDuration).first;

        if (user != null && user.id.isNotEmpty) {
          return user.id;
        }

        // If user is null or has empty ID, wait and retry (except on last attempt)
        if (attempt < maxRetries) {
          await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
          continue;
        }

        return null;
      } catch (e) {
        // Log error for debugging with attempt number
        print('Auth attempt $attempt/$maxRetries failed: $e');

        // If it's the last attempt, return null
        if (attempt >= maxRetries) {
          return null;
        }

        // Wait before retrying, with exponential backoff
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
        // CRITICAL FIX: Return proper error instead of empty list for unauthenticated users
        return const Left(
          ServerFailure(
            'Usuário não autenticado. Aguarde a inicialização ou faça login.',
          ),
        );
      }

      // Always get from local first for instant UI response
      final localTasks = await localDataSource.getTasks();

      // If we have local data, return it immediately
      if (localTasks.isNotEmpty) {
        // Sync in background if connected (fire and forget)
        if (await networkInfo.isConnected) {
          _syncTasksInBackground(userId);
        }
        return Right(localTasks.cast<Task>());
      }

      // If no local data, try remote as fallback
      if (await networkInfo.isConnected) {
        try {
          final remoteTasks = await remoteDataSource.getTasks(userId);
          await localDataSource.cacheTasks(remoteTasks);
          return Right(remoteTasks.cast<Task>());
        } catch (e) {
          // CRITICAL FIX: Provide proper error reporting instead of silent failure
          if (kDebugMode) {
            print('❌ TasksRepository: Remote fetch failed: $e');
          }
          return Left(
            ServerFailure('Falha ao sincronizar tarefas: ${e.toString()}'),
          );
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

  // Background sync method (fire and forget) - ENHANCED with connection type optimization
  void _syncTasksInBackground(String userId) async {
    try {
      // ENHANCED FEATURE: Optimize sync based on connection type
      final syncStrategy = await _determineSyncStrategy();

      // Apply connection-specific optimizations
      switch (syncStrategy) {
        case SyncStrategy.aggressive:
          // WiFi/Ethernet: Full sync with all optimizations
          _performAggressiveSync(userId);
          break;
        case SyncStrategy.conservative:
          // Mobile data: Reduce frequency, smaller batches
          _performConservativeSync(userId);
          break;
        case SyncStrategy.minimal:
          // Slow connection: Only critical updates
          _performMinimalSync(userId);
          break;
        case SyncStrategy.disabled:
          // Offline or unstable: Skip sync
          if (kDebugMode) {
            print('🚫 TasksRepository: Sync skipped due to poor connection');
          }
          return;
      }
    } catch (e) {
      // Fallback to basic sync if enhanced features fail
      _performBasicSync(userId);
    }
  }

  /// ENHANCED FEATURE: Determine optimal sync strategy based on connection type and stability
  Future<SyncStrategy> _determineSyncStrategy() async {
    try {
      // Check if we have enhanced NetworkInfo (backward compatible)
      final enhanced = networkInfo.asEnhanced;
      if (enhanced == null) {
        return SyncStrategy.conservative; // Fallback for basic NetworkInfo
      }

      // Check connection stability first
      final isStable = await enhanced.isStable;
      if (!isStable) {
        return SyncStrategy.disabled;
      }

      // Determine strategy based on connection type
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
      // TODO: Implement batched sync for mobile connections
      // For now, use basic sync with timeout
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
      // TODO: Implement delta sync for minimal data transfer
      // For now, skip sync on slow connections to preserve UX
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
        .catchError((e) {
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

      // Always get from local first for instant UI response
      final localTasks = await localDataSource.getTasksByPlantId(plantId);

      // If we have local data, return it immediately
      if (localTasks.isNotEmpty) {
        // Sync in background if connected (fire and forget)
        if (await networkInfo.isConnected) {
          _syncTasksByPlantInBackground(plantId, userId);
        }
        return Right(localTasks.cast<Task>());
      }

      // If no local data, try remote as fallback
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
        .catchError((e) {
          // Ignore sync errors in background
        });
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

      // Always get from local first for instant UI response
      final localTasks = await localDataSource.getTasksByStatus(status);

      // Start background sync if connected (fire and forget)
      if (await networkInfo.isConnected) {
        _syncTasksByStatusInBackground(status, userId);
      }

      // Return local data immediately (empty list is fine)
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
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, List<Task>>> getOverdueTasks() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      // Always get from local first for instant UI response
      final localTasks = await localDataSource.getOverdueTasks();

      // If we have local data, return it immediately
      if (localTasks.isNotEmpty) {
        // Sync in background if connected (fire and forget)
        if (await networkInfo.isConnected) {
          _syncOverdueTasksInBackground(userId);
        }
        return Right(localTasks.cast<Task>());
      }

      // If no local data, try remote as fallback
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
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, List<Task>>> getTodayTasks() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      // Always get from local first for instant UI response
      final localTasks = await localDataSource.getTodayTasks();

      // If we have local data, return it immediately
      if (localTasks.isNotEmpty) {
        // Sync in background if connected (fire and forget)
        if (await networkInfo.isConnected) {
          _syncTodayTasksInBackground(userId);
        }
        return Right(localTasks.cast<Task>());
      }

      // If no local data, try remote as fallback
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
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, List<Task>>> getUpcomingTasks() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      // Always get from local first for instant UI response
      final localTasks = await localDataSource.getUpcomingTasks();

      // Start background sync if connected (fire and forget)
      if (await networkInfo.isConnected) {
        _syncUpcomingTasksInBackground(userId);
      }

      // Return local data immediately (empty list is fine)
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
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      // Always get from local first for instant response
      final localTask = await localDataSource.getTaskById(id);

      // Start background sync if connected (fire and forget)
      if (await networkInfo.isConnected) {
        _syncTaskByIdInBackground(id, userId);
      }

      // Return local data immediately (or error if not found)
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
        .catchError((e) {
          // Ignore sync errors in background
        });
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
        // Offline: marca como dirty para sincronizar depois
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
        // Offline: marca como dirty para sincronizar depois
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
}

/// ENHANCED FEATURE: Sync strategies based on connection type and quality
enum SyncStrategy {
  /// Full sync with all optimizations - for WiFi/Ethernet connections
  aggressive,

  /// Reduced frequency sync - for mobile data connections
  conservative,

  /// Only critical updates - for slow connections
  minimal,

  /// Skip sync - for offline or unstable connections
  disabled,
}
