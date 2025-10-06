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
        final timeoutDuration = Duration(seconds: 2 * attempt);
        final user =
            await authService.currentUser.timeout(timeoutDuration).first;

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
          print(
            'PlantTasksRepository: Auth attempt $attempt/$maxRetries failed: $e',
          );
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
      final localTasks = await localDatasource.getPlantTasks();
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
      final localTasks = await localDatasource.getPlantTasksByPlantId(plantId);
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
      await localDatasource.addPlantTask(task);

      if (await networkInfo.isConnected) {
        try {
          final remoteTask = await remoteDatasource.addPlantTask(
            taskModel,
            userId,
          );
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
          return Right(task);
        }
      } else {
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
      await localDatasource.addPlantTasks(tasks);

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
      await localDatasource.updatePlantTask(task);

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
      await localDatasource.deletePlantTask(id);

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
          final plantTasks =
              allTasks
                  .where((task) => task.plantId == plantId && !task.isDeleted)
                  .toList();

          if (kDebugMode) {
            print(
              '🗑️ Encontradas ${plantTasks.length} tasks para deletar da planta $plantId',
            );
          }
          for (final task in plantTasks) {
            final deleteResult = await UnifiedSyncManager.instance.delete<Task>(
              'plantis',
              task.id,
            );

            if (deleteResult.isLeft()) {
              if (kDebugMode) {
                print('⚠️ Erro ao deletar task ${task.id}');
              }
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
  void _syncPlantTasksInBackground(String userId) {
    remoteDatasource
        .getPlantTasks(userId)
        .then((remoteTasks) {
          if (kDebugMode) {
            print(
              '✅ PlantTasksRepository: Background sync completed - ${remoteTasks.length} plant tasks',
            );
          }
          for (final task in remoteTasks) {
            localDatasource.updatePlantTask(task.toEntity());
          }
        })
        .catchError((Object e) {
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
          for (final task in remoteTasks) {
            localDatasource.updatePlantTask(task.toEntity());
          }
        })
        .catchError((Object e) {
          if (kDebugMode) {
            print(
              '⚠️ PlantTasksRepository: Background sync for plant $plantId failed: $e',
            );
          }
        });
  }

  @override
  Stream<List<PlantTask>> watchPlantTasks() {
    return Stream.fromFuture(
      getPlantTasks().then(
        (result) => result.fold((failure) => <PlantTask>[], (tasks) => tasks),
      ),
    );
  }

  @override
  Stream<List<PlantTask>> watchPlantTasksByPlantId(String plantId) {
    return Stream.fromFuture(
      getPlantTasksByPlantId(plantId).then(
        (result) => result.fold((failure) => <PlantTask>[], (tasks) => tasks),
      ),
    );
  }
}
