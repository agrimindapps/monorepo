import 'package:core/core.dart' hide Task;
import 'package:flutter/foundation.dart';

import '../../../../core/interfaces/network_info.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../domain/entities/plant_task.dart';
import '../../domain/repositories/plant_tasks_repository.dart';
import '../datasources/local/plant_tasks_local_datasource.dart';
import '../datasources/remote/plant_tasks_remote_datasource.dart';
import '../models/plant_task_model.dart';

@LazySingleton(as: PlantTasksRepository)
class PlantTasksRepositoryImpl implements PlantTasksRepository {
  final PlantTasksLocalDatasource localDatasource;
  final PlantTasksRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;
  final IAuthRepository authService;

  PlantTasksRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
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
        if (kDebugMode) {
          print(
            'PlantTasksRepository: Auth attempt $attempt/$maxRetries failed: $e',
          );
        }

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
  Future<Either<Failure, List<PlantTask>>> getPlantTasks() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(
          AuthFailure(
            'Usuário não autenticado. Aguarde a inicialização ou faça login.',
          ),
        );
      }

      // ALWAYS return local data first for instant UI response
      final localTasks = await localDatasource.getPlantTasks();

      // Start background sync immediately (fire and forget)
      if (await networkInfo.isConnected) {
        _syncPlantTasksInBackground(userId);
      }

      if (kDebugMode) {
        print(
          '✅ PlantTasksRepository: Retornando ${localTasks.length} plant tasks do cache local',
        );
      }

      return Right(localTasks);
    } on CacheFailure catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRepository: Cache failure: ${e.message}');
      }
      return Left(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRepository: Unexpected error: $e');
      }
      return Left(
        UnknownFailure(
          'Erro inesperado ao buscar tarefas de plantas: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PlantTask>>> getPlantTasksByPlantId(
    String plantId,
  ) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // ALWAYS get from local first for instant response
      final localTasks = await localDatasource.getPlantTasksByPlantId(plantId);

      // Start background sync for this plant if connected (fire and forget)
      if (await networkInfo.isConnected) {
        _syncPlantTasksByPlantIdInBackground(plantId, userId);
      }

      if (kDebugMode) {
        print(
          '✅ PlantTasksRepository: Retornando ${localTasks.length} tasks para planta $plantId',
        );
      }

      return Right(localTasks);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure(
          'Erro inesperado ao buscar tarefas da planta: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PlantTask>> getPlantTaskById(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      // ALWAYS get from local first for instant response
      final localTask = await localDatasource.getPlantTaskById(id);

      if (localTask != null) {
        return Right(localTask);
      } else {
        return const Left(NotFoundFailure('Tarefa não encontrada'));
      }
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao buscar tarefa: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, PlantTask>> addPlantTask(PlantTask task) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      if (kDebugMode) {
        print(
          '💾 PlantTasksRepository: Adicionando task ${task.id} - ${task.title}',
        );
      }

      final taskModel = PlantTaskModel.fromEntity(task);

      // Always save locally first
      await localDatasource.addPlantTask(task);

      if (await networkInfo.isConnected) {
        try {
          // Try to save remotely
          final remoteTask = await remoteDatasource.addPlantTask(
            taskModel,
            userId,
          );

          // Update local with remote data (with Firebase ID)
          await localDatasource.updatePlantTask(remoteTask.toEntity());

          if (kDebugMode) {
            print(
              '✅ PlantTasksRepository: Task ${task.id} salva remotamente com ID ${remoteTask.id}',
            );
          }

          return Right(remoteTask.toEntity());
        } catch (e) {
          if (kDebugMode) {
            print(
              '⚠️ PlantTasksRepository: Falha ao salvar remotamente, será sincronizada depois: $e',
            );
          }
          // If remote fails, return local version (will sync later)
          return Right(task);
        }
      } else {
        // Offline - return local version
        if (kDebugMode) {
          print(
            '📴 PlantTasksRepository: Offline, task salva apenas localmente',
          );
        }
        return Right(task);
      }
    } on CacheFailure catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRepository: CacheFailure: ${e.message}');
      }
      return Left(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRepository: Erro inesperado: $e');
      }
      return Left(
        UnknownFailure('Erro inesperado ao adicionar tarefa: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<PlantTask>>> addPlantTasks(
    List<PlantTask> tasks,
  ) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      if (kDebugMode) {
        print(
          '💾 PlantTasksRepository: Adicionando ${tasks.length} tasks em lote',
        );
      }

      // Always save locally first
      await localDatasource.addPlantTasks(tasks);

      // TODO: Implementar sync com remote quando disponível

      if (kDebugMode) {
        print(
          '✅ PlantTasksRepository: ${tasks.length} tasks adicionadas em lote com sucesso',
        );
      }

      return Right(tasks);
    } on CacheFailure catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRepository: CacheFailure: ${e.message}');
      }
      return Left(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantTasksRepository: Erro inesperado: $e');
      }
      return Left(
        UnknownFailure('Erro inesperado ao adicionar tarefas: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, PlantTask>> updatePlantTask(PlantTask task) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      // Always save locally first
      await localDatasource.updatePlantTask(task);

      // TODO: Implementar sync com remote quando disponível

      return Right(task);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao atualizar tarefa: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deletePlantTask(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      // Always delete locally first
      await localDatasource.deletePlantTask(id);

      // TODO: Implementar sync com remote quando disponível

      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao deletar tarefa: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deletePlantTasksByPlantId(
    String plantId,
  ) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      if (kDebugMode) {
        print(
          '🗑️ PlantTasksRepository: Deletando todas as tasks da planta $plantId usando UnifiedSyncManager',
        );
      }

      // MODERNIZADO: Usar UnifiedSyncManager com Task entity (suporta Firebase sync)
      // 1. Buscar todas as tasks da planta
      final tasksResult = await UnifiedSyncManager.instance.findAll<Task>(
        'plantis',
      );

      return tasksResult.fold(
        (failure) {
          if (kDebugMode) {
            print('❌ Erro ao buscar tasks: ${failure.message}');
          }
          return Left(failure);
        },
        (allTasks) async {
          // 2. Filtrar tasks desta planta específica que não estão deletadas
          final plantTasks =
              allTasks
                  .where(
                    (task) => task.plantId == plantId && !task.isDeleted,
                  )
                  .toList();

          if (kDebugMode) {
            print(
              '🗑️ Encontradas ${plantTasks.length} tasks para deletar da planta $plantId',
            );
          }

          // 3. Deletar cada task (soft delete + sync Firebase automático)
          for (final task in plantTasks) {
            final deleteResult = await UnifiedSyncManager.instance
                .delete<Task>('plantis', task.id);

            if (deleteResult.isLeft()) {
              if (kDebugMode) {
                print('⚠️ Erro ao deletar task ${task.id}');
              }
              // Continue deletando outras tasks mesmo se uma falhar
            }
          }

          if (kDebugMode) {
            print(
              '✅ PlantTasksRepository: ${plantTasks.length} tasks da planta $plantId deletadas com sucesso',
            );
          }

          return const Right(null);
        },
      );
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure(
          'Erro inesperado ao deletar tarefas da planta: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PlantTask>>> getPendingPlantTasks() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      final pendingTasks = await localDatasource.getPendingPlantTasks();
      return Right(pendingTasks);
    } catch (e) {
      return Left(
        UnknownFailure(
          'Erro inesperado ao buscar tarefas pendentes: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PlantTask>>> getOverduePlantTasks() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      final overdueTasks = await localDatasource.getOverduePlantTasks();
      return Right(overdueTasks);
    } catch (e) {
      return Left(
        UnknownFailure(
          'Erro inesperado ao buscar tarefas atrasadas: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PlantTask>>> getTodayPlantTasks() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      final todayTasks = await localDatasource.getTodayPlantTasks();
      return Right(todayTasks);
    } catch (e) {
      return Left(
        UnknownFailure(
          'Erro inesperado ao buscar tarefas de hoje: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<PlantTask>>> getUpcomingPlantTasks() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      final upcomingTasks = await localDatasource.getUpcomingPlantTasks();
      return Right(upcomingTasks);
    } catch (e) {
      return Left(
        UnknownFailure(
          'Erro inesperado ao buscar tarefas próximas: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, PlantTask>> completeTask(
    String id, {
    String? notes,
  }) async {
    try {
      final taskResult = await getPlantTaskById(id);

      return taskResult.fold((failure) => Left(failure), (task) async {
        final completedTask = task.markAsCompleted();

        return await updatePlantTask(completedTask);
      });
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao completar tarefa: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingChanges() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      if (!(await networkInfo.isConnected)) {
        return const Left(NetworkFailure('Sem conexão com a internet'));
      }

      // Get all local tasks that need sync
      final localTasks = await localDatasource.getPlantTasks();
      final tasksToSync =
          localTasks
              .map((task) => PlantTaskModel.fromEntity(task))
              .where((task) => task.isDirty)
              .toList();

      if (tasksToSync.isNotEmpty) {
        if (kDebugMode) {
          print(
            '🔄 PlantTasksRepository: Sincronizando ${tasksToSync.length} plant tasks',
          );
        }

        try {
          await remoteDatasource.syncPlantTasks(tasksToSync, userId);

          // Update local tasks to mark as synced
          for (final task in tasksToSync) {
            final syncedTask = task.markAsSynced();
            await localDatasource.updatePlantTask(syncedTask.toEntity());
          }

          if (kDebugMode) {
            print(
              '✅ PlantTasksRepository: ${tasksToSync.length} plant tasks sincronizadas',
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print(
              '❌ PlantTasksRepository: Erro ao sincronizar plant tasks: $e',
            );
          }
          return Left(
            ServerFailure('Erro ao sincronizar mudanças: ${e.toString()}'),
          );
        }
      }

      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao sincronizar: ${e.toString()}'),
      );
    }
  }

  // Background sync methods (fire and forget)
  void _syncPlantTasksInBackground(String userId) {
    remoteDatasource
        .getPlantTasks(userId)
        .then((remoteTasks) {
          if (kDebugMode) {
            print(
              '✅ PlantTasksRepository: Background sync completed - ${remoteTasks.length} plant tasks',
            );
          }
          // Update local cache with remote data
          for (final task in remoteTasks) {
            localDatasource.updatePlantTask(task.toEntity());
          }
        })
        .catchError((e) {
          // Log background sync errors for debugging
          if (kDebugMode) {
            print('⚠️ PlantTasksRepository: Background sync failed: $e');
          }
        });
  }

  void _syncPlantTasksByPlantIdInBackground(String plantId, String userId) {
    remoteDatasource
        .getPlantTasksByPlantId(plantId, userId)
        .then((remoteTasks) {
          if (kDebugMode) {
            print(
              '✅ PlantTasksRepository: Background sync for plant $plantId completed - ${remoteTasks.length} tasks',
            );
          }
          // Update local cache with remote data
          for (final task in remoteTasks) {
            localDatasource.updatePlantTask(task.toEntity());
          }
        })
        .catchError((e) {
          // Log background sync errors for debugging
          if (kDebugMode) {
            print(
              '⚠️ PlantTasksRepository: Background sync for plant $plantId failed: $e',
            );
          }
        });
  }

  @override
  Stream<List<PlantTask>> watchPlantTasks() {
    // For now, return a simple stream that emits current tasks
    // In a more advanced implementation, you might use Firestore snapshots
    // or a local database with reactive queries
    return Stream.fromFuture(
      getPlantTasks().then(
        (result) => result.fold((failure) => <PlantTask>[], (tasks) => tasks),
      ),
    );
  }

  @override
  Stream<List<PlantTask>> watchPlantTasksByPlantId(String plantId) {
    // For now, return a simple stream that emits current tasks for plant
    return Stream.fromFuture(
      getPlantTasksByPlantId(plantId).then(
        (result) => result.fold((failure) => <PlantTask>[], (tasks) => tasks),
      ),
    );
  }
}
