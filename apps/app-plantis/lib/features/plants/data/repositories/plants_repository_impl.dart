import 'dart:async';

import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../core/data/adapters/network_info_adapter.dart';
import '../../../../core/interfaces/network_info.dart';
import '../../domain/entities/plant.dart';
import '../../domain/repositories/plant_comments_repository.dart';
import '../../domain/repositories/plant_tasks_repository.dart';
import '../../domain/repositories/plants_repository.dart';
import '../datasources/local/plants_local_datasource.dart';
import '../datasources/remote/plants_remote_datasource.dart';
import '../models/plant_model.dart';

@LazySingleton(as: PlantsRepository)
class PlantsRepositoryImpl implements PlantsRepository {
  PlantsRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.networkInfo,
    required this.authService,
    required this.taskRepository,
    required this.commentsRepository,
  }) {
    _initializeConnectivityMonitoring();
  }

  final PlantsLocalDatasource localDatasource;
  final PlantsRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;
  final IAuthRepository authService;
  final PlantTasksRepository taskRepository;
  final PlantCommentsRepository commentsRepository;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isMonitoringConnectivity = false;

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
        print('Auth attempt $attempt/$maxRetries failed: $e');
        if (attempt >= maxRetries) {
          return null;
        }
        await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
      }
    }

    return null;
  }

  /// ENHANCED FEATURE: Initialize real-time connectivity monitoring
  void _initializeConnectivityMonitoring() {
    try {
      final enhanced = networkInfo.asEnhanced;
      if (enhanced == null) {
        if (kDebugMode) {
          print(
            'ℹ️ PlantsRepository: Basic NetworkInfo - real-time monitoring unavailable',
          );
        }
        return;
      }
      _connectivitySubscription = enhanced.connectivityStream.listen(
        _onConnectivityChanged,
        onError: (Object error) {
          if (kDebugMode) {
            print('⚠️ PlantsRepository: Connectivity monitoring error: $error');
          }
        },
      );

      _isMonitoringConnectivity = true;

      if (kDebugMode) {
        print('✅ PlantsRepository: Real-time connectivity monitoring started');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ PlantsRepository: Failed to start connectivity monitoring: $e',
        );
      }
    }
  }

  /// ENHANCED FEATURE: Handle real-time connectivity changes
  void _onConnectivityChanged(bool isConnected) async {
    try {
      if (kDebugMode) {
        print(
          '🔄 PlantsRepository: Connectivity changed - ${isConnected ? 'Online' : 'Offline'}',
        );
      }

      if (isConnected) {
        final userId = await _currentUserId;
        if (userId != null) {
          if (kDebugMode) {
            print(
              '🚀 PlantsRepository: Connection restored - starting auto-sync',
            );
          }
          _syncPlantsInBackground(userId, connectionRestored: true);
        }
      } else {
        if (kDebugMode) {
          print(
            '📱 PlantsRepository: Connection lost - switching to offline mode',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantsRepository: Error handling connectivity change: $e');
      }
    }
  }

  @override
  Future<Either<Failure, List<Plant>>> getPlants() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Right([]);
      }

      // Use local datasource for both web and native
      // UnifiedSyncManager is not being populated correctly in web mode
      final localPlants = await localDatasource.getPlants();

      if (kDebugMode) {
        print('📱 PlantsRepository.getPlants - Loaded ${localPlants.length} plants from local datasource');
      }

      if (await networkInfo.isConnected) {
        _syncPlantsInBackground(userId);
      }

      return Right(localPlants);
    } on CacheFailure catch (e) {
      if (kDebugMode) {
        print('❌ PlantsRepository: Cache failure: ${e.message}');
      }
      return Left(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantsRepository: Unexpected error: $e');
      }
      return Left(
        UnknownFailure('Erro inesperado ao buscar plantas: ${e.toString()}'),
      );
    }
  }
  void _syncPlantsInBackground(
    String userId, {
    bool connectionRestored = false,
  }) {
    remoteDatasource
        .getPlants(userId)
        .then((remotePlants) {
          final syncType =
              connectionRestored
                  ? 'Connection restored sync'
                  : 'Background sync';
          if (kDebugMode) {
            print(
              '✅ PlantsRepository: $syncType completed - ${remotePlants.length} plants',
            );
          }
          for (final plant in remotePlants) {
            localDatasource.updatePlant(plant);
          }
          if (_isMonitoringConnectivity && connectionRestored) {
            _logSyncMetrics(remotePlants.length, syncType);
          }
        })
        .catchError((Object e) {
          if (kDebugMode) {
            print('⚠️ PlantsRepository: Background sync failed: $e');
          }
        });
  }
  void _syncSinglePlantInBackground(String plantId, String userId) {
    remoteDatasource
        .getPlantById(plantId, userId)
        .then((remotePlant) {
          localDatasource.updatePlant(remotePlant);
        })
        .catchError((e) {
        });
  }

  @override
  Future<Either<Failure, Plant>> getPlantById(String id) async {
    try {
      if (kDebugMode) {
        print('📥 PlantsRepositoryImpl.getPlantById - id: $id');
      }

      final userId = await _currentUserId;
      if (userId == null) {
        if (kDebugMode) {
          print('❌ PlantsRepositoryImpl.getPlantById - User not authenticated');
        }
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      if (kDebugMode) {
        print('👤 PlantsRepositoryImpl.getPlantById - userId: $userId');
      }

      final localPlant = await localDatasource.getPlantById(id);

      if (kDebugMode) {
        print(
          '💾 PlantsRepositoryImpl.getPlantById - localPlant: ${localPlant != null ? localPlant.name : 'null'}',
        );
      }

      if (await networkInfo.isConnected) {
        _syncSinglePlantInBackground(id, userId);
      }

      if (localPlant != null) {
        if (kDebugMode) {
          print('✅ PlantsRepositoryImpl.getPlantById - Returning plant: ${localPlant.name}');
        }
        return Right(localPlant);
      } else {
        if (kDebugMode) {
          print('❌ PlantsRepositoryImpl.getPlantById - Plant not found in local datasource');
        }
        return const Left(NotFoundFailure('Planta não encontrada'));
      }
    } on CacheFailure catch (e) {
      if (kDebugMode) {
        print('❌ PlantsRepositoryImpl.getPlantById - CacheFailure: $e');
      }
      return Left(e);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('💥 PlantsRepositoryImpl.getPlantById - Exception: $e');
        print('Stack trace: $stackTrace');
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
        print('🌱 PlantsRepositoryImpl.addPlant() - Iniciando');
        print('🌱 PlantsRepositoryImpl.addPlant() - plant.id: ${plant.id}');
        print('🌱 PlantsRepositoryImpl.addPlant() - plant.name: ${plant.name}');
      }

      final userId = await _currentUserId;
      if (userId == null) {
        if (kDebugMode) {
          print('❌ PlantsRepositoryImpl.addPlant() - Usuário não autenticado');
        }
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      if (kDebugMode) {
        print('🌱 PlantsRepositoryImpl.addPlant() - userId: $userId');
      }

      final plantModel = PlantModel.fromEntity(plant);

      if (kDebugMode) {
        print(
          '🌱 PlantsRepositoryImpl.addPlant() - Salvando localmente primeiro',
        );
      }
      await localDatasource.addPlant(plantModel);

      if (kDebugMode) {
        print(
          '✅ PlantsRepositoryImpl.addPlant() - Salvo localmente com sucesso',
        );
      }

      if (await networkInfo.isConnected) {
        if (kDebugMode) {
          print(
            '🌱 PlantsRepositoryImpl.addPlant() - Conectado, tentando salvar remotamente',
          );
        }
        try {
          final remotePlant = await remoteDatasource.addPlant(
            plantModel,
            userId,
          );

          if (kDebugMode) {
            print(
              '✅ PlantsRepositoryImpl.addPlant() - Salvo remotamente com sucesso',
            );
            print(
              '🌱 PlantsRepositoryImpl.addPlant() - remotePlant.id: ${remotePlant.id}',
            );
          }
          if (plantModel.id != remotePlant.id) {
            if (kDebugMode) {
              print(
                '🌱 PlantsRepositoryImpl.addPlant() - IDs diferentes, iniciando transição segura',
              );
              print('   - ID local: ${plantModel.id}');
              print('   - ID remoto: ${remotePlant.id}');
            }

            try {
              await localDatasource.updatePlant(remotePlant);

              if (kDebugMode) {
                print('✅ Versão remota salva localmente');
              }
              try {
                await localDatasource.hardDeletePlant(plantModel.id);
                if (kDebugMode) {
                  print('✅ Registro local antigo removido');
                }
              } catch (deleteError) {
                if (kDebugMode) {
                  print(
                    '⚠️ Falha ao deletar ID local ${plantModel.id}: $deleteError',
                  );
                  print('   Mas versão remota foi salva com sucesso');
                }
              }
            } catch (updateError) {
              if (kDebugMode) {
                print('❌ Falha ao salvar versão remota: $updateError');
              }
              throw CacheFailure(
                'Falha ao atualizar planta localmente: ${updateError.toString()}',
              );
            }
          } else {
            await localDatasource.updatePlant(remotePlant);

            if (kDebugMode) {
              print(
                '✅ PlantsRepositoryImpl.addPlant() - Local atualizado com dados remotos',
              );
            }
          }

          return Right(remotePlant);
        } catch (e) {
          if (kDebugMode) {
            print(
              '⚠️ PlantsRepositoryImpl.addPlant() - Falha ao salvar remotamente: $e',
            );
            print(
              '🌱 PlantsRepositoryImpl.addPlant() - Retornando versão local',
            );
          }
          return Right(plantModel);
        }
      } else {
        if (kDebugMode) {
          print(
            '🌱 PlantsRepositoryImpl.addPlant() - Offline, retornando versão local',
          );
        }
        return Right(plantModel);
      }
    } on CacheFailure catch (e) {
      if (kDebugMode) {
        print('❌ PlantsRepositoryImpl.addPlant() - CacheFailure: ${e.message}');
      }
      return Left(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ PlantsRepositoryImpl.addPlant() - Erro inesperado: $e');
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

      final plantModel = PlantModel.fromEntity(plant);
      await localDatasource.updatePlant(plantModel);

      if (await networkInfo.isConnected) {
        try {
          final remotePlant = await remoteDatasource.updatePlant(
            plantModel,
            userId,
          );
          await localDatasource.updatePlant(remotePlant);

          return Right(remotePlant);
        } catch (e) {
          return Right(plantModel);
        }
      } else {
        return Right(plantModel);
      }
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
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
        print('🗑️ Deleting plant: $id');
      }
      if (kDebugMode) {
        print('🗑️ Deleting tasks for plant: $id');
      }
      final tasksResult = await taskRepository.deletePlantTasksByPlantId(id);
      if (tasksResult.isLeft()) {
        if (kDebugMode) {
          print(
            '⚠️ Failed to delete tasks for plant $id: ${tasksResult.fold((f) => f.message, (_) => '')}',
          );
        }
      }
      if (kDebugMode) {
        print('🗑️ Deleting comments for plant: $id');
      }
      final commentsResult = await commentsRepository.deleteCommentsForPlant(
        id,
      );
      if (commentsResult.isLeft()) {
        if (kDebugMode) {
          print(
            '⚠️ Failed to delete comments for plant $id: ${commentsResult.fold((f) => f.message, (_) => '')}',
          );
        }
      }
      if (kDebugMode) {
        print('🗑️ Deleting plant locally: $id');
      }
      await localDatasource.deletePlant(id);
      if (await networkInfo.isConnected) {
        try {
          if (kDebugMode) {
            print('🗑️ Deleting plant remotely: $id');
          }
          await remoteDatasource.deletePlant(id, userId);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Remote deletion failed, will sync later: $e');
          }
        }
      }

      if (kDebugMode) {
        print('✅ Plant deleted successfully: $id');
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

  /// ENHANCED FEATURE: Log sync metrics for monitoring and debugging
  void _logSyncMetrics(int plantsCount, String syncType) {
    try {
      final enhanced = networkInfo.asEnhanced;
      if (enhanced != null) {
        enhanced.detailedStatus.then((status) {
          if (status != null && kDebugMode) {
            print('📊 PlantsRepository Sync Metrics:');
            print('   Type: $syncType');
            print('   Plants synced: $plantsCount');
            print('   Connection: ${status['connectivity_type']}');
            print('   Timestamp: ${status['timestamp']}');
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ PlantsRepository: Error logging sync metrics: $e');
      }
    }
  }

  /// ENHANCED FEATURE: Get current connectivity status for debugging
  Future<Map<String, dynamic>> getConnectivityStatus() async {
    try {
      final enhanced = networkInfo.asEnhanced;
      if (enhanced != null) {
        final status = await enhanced.detailedStatus;
        return {
          ...?status,
          'monitoring_active': _isMonitoringConnectivity,
          'repository': 'PlantsRepository',
        };
      } else {
        final isConnected = await networkInfo.isConnected;
        return {
          'is_online': isConnected,
          'monitoring_active': false,
          'repository': 'PlantsRepository',
          'adapter_type': 'basic',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      return {
        'error': e.toString(),
        'monitoring_active': _isMonitoringConnectivity,
        'repository': 'PlantsRepository',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// ENHANCED FEATURE: Cleanup connectivity monitoring resources
  Future<void> dispose() async {
    try {
      if (_connectivitySubscription != null) {
        await _connectivitySubscription!.cancel();
        _connectivitySubscription = null;
        _isMonitoringConnectivity = false;

        if (kDebugMode) {
          print('✅ PlantsRepository: Connectivity monitoring disposed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          '❌ PlantsRepository: Error disposing connectivity monitoring: $e',
        );
      }
    }
  }
}
