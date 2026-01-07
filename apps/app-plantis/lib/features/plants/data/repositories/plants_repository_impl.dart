import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/interfaces/network_info.dart';
import '../../domain/entities/plant.dart';
import '../../domain/repositories/plant_comments_repository.dart';
import '../../domain/repositories/plant_tasks_repository.dart';
import '../../domain/repositories/plants_repository.dart';
import '../../domain/services/plant_sync_service.dart';
import '../../domain/services/plants_connectivity_service.dart';
import '../datasources/local/plants_local_datasource.dart';
import '../datasources/remote/plants_remote_datasource.dart';
import '../models/plant_model.dart';

class PlantsRepositoryImpl implements PlantsRepository {
  PlantsRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.networkInfo,
    required this.authService,
    required this.taskRepository,
    required this.commentsRepository,
    required this.connectivityService,
    required this.syncService,
  });

  final PlantsLocalDatasource localDatasource;
  final PlantsRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;
  final IAuthRepository authService;
  final PlantTasksRepository taskRepository;
  final PlantCommentsRepository commentsRepository;
  final PlantsConnectivityService connectivityService;
  final PlantSyncService syncService;

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
          debugPrint('Auth attempt $attempt/$maxRetries failed: $e');
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
  Future<Either<Failure, List<Plant>>> getPlants() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      var localPlants = await localDatasource.getPlants();

      if (kDebugMode) {
        debugPrint(
          '📱 PlantsRepository.getPlants - Loaded ${localPlants.length} plants from local datasource',
        );
      }

      if (await networkInfo.isConnected) {
        await syncService.syncPlantsInBackground(userId);
        // Re-fetch local data after sync to ensure we return the latest data
        localPlants = await localDatasource.getPlants();
      }

      return Right(localPlants);
    } on CacheFailure catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsRepository: Cache failure: ${e.message}');
      }
      return Left(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsRepository: Unexpected error: $e');
      }
      return Left(
        UnknownFailure('Erro inesperado ao buscar plantas: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Plant>> getPlantById(String id) async {
    try {
      if (kDebugMode) {
        debugPrint('📥 PlantsRepositoryImpl.getPlantById - id: $id');
      }

      final userId = await _currentUserId;
      if (userId == null) {
        if (kDebugMode) {
          debugPrint(
            '❌ PlantsRepositoryImpl.getPlantById - User not authenticated',
          );
        }
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      if (kDebugMode) {
        debugPrint('👤 PlantsRepositoryImpl.getPlantById - userId: $userId');
      }

      final localPlant = await localDatasource.getPlantById(id);

      if (kDebugMode) {
        debugPrint(
          '💾 PlantsRepositoryImpl.getPlantById - localPlant: ${localPlant != null ? localPlant.name : 'null'}',
        );
      }

      if (await networkInfo.isConnected) {
        await syncService.syncSinglePlantInBackground(id, userId);
      }

      Plant? resolved = localPlant;
      if (resolved == null) {
        for (var i = 0; i < 3; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          resolved = await localDatasource.getPlantById(id);
          if (resolved != null) break;
        }
      }

      if (resolved != null) {
        if (kDebugMode) {
          debugPrint(
            '✅ PlantsRepositoryImpl.getPlantById - Returning plant: ${resolved.name}',
          );
        }
        return Right(resolved);
      } else {
        if (kDebugMode) {
          debugPrint(
            '❌ PlantsRepositoryImpl.getPlantById - Plant not found in local datasource',
          );
        }
        return const Left(NotFoundFailure('Planta não encontrada'));
      }
    } on CacheFailure catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsRepositoryImpl.getPlantById - CacheFailure: $e');
      }
      return Left(e);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('💥 PlantsRepositoryImpl.getPlantById - Exception: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return Left(
        UnknownFailure('Erro inesperado ao buscar planta: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Plant>> addPlant(Plant plant) async {
    try {
      if (kDebugMode) {
        debugPrint('🌱 PlantsRepositoryImpl.addPlant() - Iniciando');
        debugPrint(
          '🌱 PlantsRepositoryImpl.addPlant() - plant.id: ${plant.id}',
        );
        debugPrint(
          '🌱 PlantsRepositoryImpl.addPlant() - plant.name: ${plant.name}',
        );
      }

      final userId = await _currentUserId;
      if (userId == null) {
        if (kDebugMode) {
          debugPrint(
            '❌ PlantsRepositoryImpl.addPlant() - Usuário não autenticado',
          );
        }
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      if (kDebugMode) {
        debugPrint('🌱 PlantsRepositoryImpl.addPlant() - userId: $userId');
      }

      final plantModel = PlantModel.fromEntity(plant);

      if (kDebugMode) {
        debugPrint(
          '🌱 PlantsRepositoryImpl.addPlant() - Salvando localmente primeiro',
        );
      }
      await localDatasource.addPlant(plantModel);

      if (kDebugMode) {
        debugPrint(
          '✅ PlantsRepositoryImpl.addPlant() - Salvo localmente com sucesso',
        );
      }

      if (await networkInfo.isConnected) {
        if (kDebugMode) {
          debugPrint(
            '🌱 PlantsRepositoryImpl.addPlant() - Conectado, tentando salvar remotamente',
          );
        }
        try {
          final remotePlant = await remoteDatasource.addPlant(
            plantModel,
            userId,
          );

          if (kDebugMode) {
            debugPrint(
              '✅ PlantsRepositoryImpl.addPlant() - Salvo remotamente com sucesso',
            );
            debugPrint(
              '🌱 PlantsRepositoryImpl.addPlant() - remotePlant.id: ${remotePlant.id}',
            );
          }
          if (plantModel.id != remotePlant.id) {
            if (kDebugMode) {
              debugPrint(
                '🌱 PlantsRepositoryImpl.addPlant() - IDs diferentes, iniciando transição segura',
              );
              debugPrint('   - ID local: ${plantModel.id}');
              debugPrint('   - ID remoto: ${remotePlant.id}');
            }

            try {
              // Inserir a versão remota como novo registro (id remoto)
              await localDatasource.addPlant(remotePlant);

              if (kDebugMode) {
                debugPrint('✅ Versão remota INSERIDA localmente');
              }
              try {
                await localDatasource.hardDeletePlant(plantModel.id);
                if (kDebugMode) {
                  debugPrint('✅ Registro local antigo removido');
                }
              } catch (deleteError) {
                if (kDebugMode) {
                  if (kDebugMode) {
                    debugPrint(
                      '⚠️ Falha ao deletar ID local ${plantModel.id}: $deleteError',
                    );
                  }
                  if (kDebugMode) {
                    debugPrint('   Mas versão remota foi salva com sucesso');
                  }
                }
              }
            } catch (updateError) {
              if (kDebugMode) {
                debugPrint('❌ Falha ao inserir versão remota: $updateError');
              }
              throw Exception(
                'Falha ao atualizar planta localmente: ${updateError.toString()}',
              );
            }
          } else {
            await localDatasource.updatePlant(remotePlant);

            if (kDebugMode) {
              debugPrint(
                '✅ PlantsRepositoryImpl.addPlant() - Local atualizado com dados remotos',
              );
            }
          }

          return Right(remotePlant);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ PlantsRepositoryImpl.addPlant() - Falha ao salvar remotamente: $e',
            );
            debugPrint(
              '🌱 PlantsRepositoryImpl.addPlant() - Retornando versão local',
            );
          }
          return Right(plantModel);
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            '🌱 PlantsRepositoryImpl.addPlant() - Offline, retornando versão local',
          );
        }
        return Right(plantModel);
      }
    } on CacheFailure catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ PlantsRepositoryImpl.addPlant() - CacheFailure: ${e.message}',
        );
      }
      return Left(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsRepositoryImpl.addPlant() - Erro inesperado: $e');
      }
      return Left(
        UnknownFailure('Erro inesperado ao adicionar planta: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Plant>> updatePlant(Plant plant) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      if (kDebugMode) {
        debugPrint('🔄 PlantsRepositoryImpl.updatePlant() - Iniciando');
        debugPrint('   plant.id: ${plant.id}');
        debugPrint('   plant.name: ${plant.name}');
        debugPrint('   plant.spaceId: ${plant.spaceId}');
        debugPrint('   plant.config: ${plant.config}');
        if (plant.config != null) {
          debugPrint(
            '   config.wateringIntervalDays: ${plant.config!.wateringIntervalDays}',
          );
          debugPrint(
            '   config.fertilizingIntervalDays: ${plant.config!.fertilizingIntervalDays}',
          );
          debugPrint(
            '   config.pruningIntervalDays: ${plant.config!.pruningIntervalDays}',
          );
        }
      }

      final plantModel = PlantModel.fromEntity(plant);

      if (kDebugMode) {
        debugPrint('🔄 PlantsRepositoryImpl.updatePlant() - PlantModel criado');
        debugPrint('   plantModel.spaceId: ${plantModel.spaceId}');
        debugPrint('   plantModel.config: ${plantModel.config}');
      }

      await localDatasource.updatePlant(plantModel);

      if (kDebugMode) {
        debugPrint('✅ PlantsRepositoryImpl.updatePlant() - Salvo localmente');
      }

      if (await networkInfo.isConnected) {
        try {
          final remotePlant = await remoteDatasource.updatePlant(
            plantModel,
            userId,
          );
          await localDatasource.updatePlant(remotePlant);

          if (kDebugMode) {
            debugPrint(
              '✅ PlantsRepositoryImpl.updatePlant() - Salvo remotamente',
            );
            debugPrint('   remotePlant.spaceId: ${remotePlant.spaceId}');
          }

          return Right(remotePlant);
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ PlantsRepositoryImpl.updatePlant() - Erro remoto: $e',
            );
          }
          return Right(plantModel);
        }
      } else {
        return Right(plantModel);
      }
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlantsRepositoryImpl.updatePlant() - Erro: $e');
      }
      return Left(
        UnknownFailure('Erro inesperado ao atualizar planta: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deletePlant(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      if (kDebugMode) {
        debugPrint('🗑️ Deleting plant: $id');
      }

      // Track failures but don't block plant deletion
      final List<String> partialFailures = [];

      // Delete tasks (cascading)
      if (kDebugMode) {
        debugPrint('🗑️ Deleting tasks for plant: $id');
      }
      final tasksResult = await taskRepository.deletePlantTasksByPlantId(id);
      tasksResult.fold(
        (failure) {
          final errorMsg = 'Failed to delete tasks: ${failure.message}';
          partialFailures.add(errorMsg);
          if (kDebugMode) {
            debugPrint('⚠️ $errorMsg');
          }
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ Tasks deleted successfully');
          }
        },
      );

      // Delete comments (cascading)
      if (kDebugMode) {
        debugPrint('🗑️ Deleting comments for plant: $id');
      }
      final commentsResult = await commentsRepository.deleteCommentsForPlant(
        id,
      );
      commentsResult.fold(
        (failure) {
          final errorMsg = 'Failed to delete comments: ${failure.message}';
          partialFailures.add(errorMsg);
          if (kDebugMode) {
            debugPrint('⚠️ $errorMsg');
          }
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ Comments deleted successfully');
          }
        },
      );

      // Delete plant locally
      if (kDebugMode) {
        debugPrint('🗑️ Deleting plant locally: $id');
      }
      await localDatasource.deletePlant(id);

      // Delete plant remotely if online
      if (await networkInfo.isConnected) {
        try {
          if (kDebugMode) {
            debugPrint('🗑️ Deleting plant remotely: $id');
          }
          await remoteDatasource.deletePlant(id, userId);
        } catch (e) {
          final errorMsg = 'Remote deletion failed, will sync later: $e';
          partialFailures.add(errorMsg);
          if (kDebugMode) {
            debugPrint('⚠️ $errorMsg');
          }
        }
      }

      // Log partial failures but still return success
      if (partialFailures.isNotEmpty && kDebugMode) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ Plant deleted with ${partialFailures.length} partial failure(s):',
          );
        }
        for (final failure in partialFailures) {
          if (kDebugMode) {
            debugPrint('   - $failure');
          }
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Plant deleted successfully: $id');
      }

      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao deletar planta: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Plant>>> searchPlants(String query) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      if (await networkInfo.isConnected) {
        try {
          final remotePlants = await remoteDatasource.searchPlants(
            query,
            userId,
          );
          for (final plant in remotePlants) {
            await localDatasource.updatePlant(plant);
          }

          return Right(remotePlants);
        } catch (e) {
          final localPlants = await localDatasource.searchPlants(query);
          return Right(localPlants);
        }
      } else {
        final localPlants = await localDatasource.searchPlants(query);
        return Right(localPlants);
      }
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao buscar plantas: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Plant>>> getPlantsBySpace(String spaceId) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      if (await networkInfo.isConnected) {
        try {
          final remotePlants = await remoteDatasource.getPlantsBySpace(
            spaceId,
            userId,
          );
          for (final plant in remotePlants) {
            await localDatasource.updatePlant(plant);
          }

          return Right(remotePlants);
        } catch (e) {
          final localPlants = await localDatasource.getPlantsBySpace(spaceId);
          return Right(localPlants);
        }
      } else {
        final localPlants = await localDatasource.getPlantsBySpace(spaceId);
        return Right(localPlants);
      }
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure(
          'Erro inesperado ao buscar plantas por espaço: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getPlantsCount() async {
    try {
      final result = await getPlants();
      return result.fold(
        (failure) => Left(failure),
        (plants) => Right(plants.length),
      );
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao contar plantas: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<List<Plant>> watchPlants() {
    return Stream.fromFuture(
      getPlants().then(
        (result) => result.fold((failure) => <Plant>[], (plants) => plants),
      ),
    );
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
      final localPlants = await localDatasource.getPlants();
      final plantsToSync = localPlants.where((plant) => plant.isDirty).toList();

      if (plantsToSync.isNotEmpty) {
        try {
          await remoteDatasource.syncPlants(
            plantsToSync.map((plant) => PlantModel.fromEntity(plant)).toList(),
            userId,
          );
          for (final plant in plantsToSync) {
            final syncedPlant = plant.copyWith(isDirty: false);
            await localDatasource.updatePlant(syncedPlant);
          }
        } catch (e) {
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
}
