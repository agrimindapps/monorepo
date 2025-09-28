import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/adapters/network_info_adapter.dart';
import '../../../../core/interfaces/network_info.dart';
import '../../domain/entities/plant.dart';
import '../../domain/repositories/plants_repository.dart';
import '../datasources/local/plants_local_datasource.dart';
import '../datasources/remote/plants_remote_datasource.dart';
import '../models/plant_model.dart';

class PlantsRepositoryImpl implements PlantsRepository {
  final PlantsLocalDatasource localDatasource;
  final PlantsRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;
  final IAuthRepository authService;

  // ENHANCED FEATURE: Real-time connectivity monitoring
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isMonitoringConnectivity = false;

  PlantsRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.networkInfo,
    required this.authService,
  }) {
    // ENHANCED FEATURE: Start real-time connectivity monitoring
    _initializeConnectivityMonitoring();
  }

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

  /// ENHANCED FEATURE: Initialize real-time connectivity monitoring
  void _initializeConnectivityMonitoring() {
    try {
      // Check if we have enhanced NetworkInfo capabilities
      final enhanced = networkInfo.asEnhanced;
      if (enhanced == null) {
        if (kDebugMode) {
          print(
            'ℹ️ PlantsRepository: Basic NetworkInfo - real-time monitoring unavailable',
          );
        }
        return;
      }

      // Start monitoring connectivity changes
      _connectivitySubscription = enhanced.connectivityStream.listen(
        _onConnectivityChanged,
        onError: (error) {
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
        // When connection is restored, trigger background sync
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
        // When connection is lost, log for monitoring
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
        // CRITICAL FIX: Return proper error instead of empty list for unauthenticated users
        return const Left(
          AuthFailure(
            'Usuário não autenticado. Aguarde a inicialização ou faça login.',
          ),
        );
      }

      // ALWAYS return local data first for instant UI response
      final localPlants = await localDatasource.getPlants();

      // Start background sync immediately (fire and forget)
      // This ensures local-first approach with background updates
      if (await networkInfo.isConnected) {
        _syncPlantsInBackground(userId);
      }

      // Return local data immediately (empty list is fine for authenticated users)
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

  // Background sync method (fire and forget) - ENHANCED with connectivity awareness
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
          // Update local cache with remote data
          for (final plant in remotePlants) {
            localDatasource.updatePlant(plant);
          }

          // ENHANCED FEATURE: Log detailed sync info if monitoring is active
          if (_isMonitoringConnectivity && connectionRestored) {
            _logSyncMetrics(remotePlants.length, syncType);
          }
        })
        .catchError((e) {
          // CRITICAL FIX: Log background sync errors for debugging
          if (kDebugMode) {
            print('⚠️ PlantsRepository: Background sync failed: $e');
          }
        });
  }

  // Background sync method for single plant (fire and forget)
  void _syncSinglePlantInBackground(String plantId, String userId) {
    remoteDatasource
        .getPlantById(plantId, userId)
        .then((remotePlant) {
          // Update local cache with remote data
          localDatasource.updatePlant(remotePlant);
        })
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, Plant>> getPlantById(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      // ALWAYS get from local first for instant response
      final localPlant = await localDatasource.getPlantById(id);

      // Start background sync if connected (fire and forget)
      if (await networkInfo.isConnected) {
        _syncSinglePlantInBackground(id, userId);
      }

      // Return local data immediately (or error if not found)
      if (localPlant != null) {
        return Right(localPlant);
      } else {
        return const Left(NotFoundFailure('Planta não encontrada'));
      }
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
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

      // Always save locally first
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
          // Try to save remotely
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

          // Se o ID mudou (local vs remoto), remover o registro local antigo para evitar duplicação
          if (plantModel.id != remotePlant.id) {
            if (kDebugMode) {
              print(
                '🌱 PlantsRepositoryImpl.addPlant() - IDs diferentes, removendo registro local antigo',
              );
              print('   - ID local: ${plantModel.id}');
              print('   - ID remoto: ${remotePlant.id}');
            }
            await localDatasource.hardDeletePlant(plantModel.id);

            if (kDebugMode) {
              print(
                '✅ PlantsRepositoryImpl.addPlant() - Registro local antigo removido',
              );
            }
          }

          // Update/add local with remote ID and sync status
          await localDatasource.updatePlant(remotePlant);

          if (kDebugMode) {
            print(
              '✅ PlantsRepositoryImpl.addPlant() - Local atualizado com dados remotos',
            );
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
          // If remote fails, return local version (will sync later)
          return Right(plantModel);
        }
      } else {
        if (kDebugMode) {
          print(
            '🌱 PlantsRepositoryImpl.addPlant() - Offline, retornando versão local',
          );
        }
        // Offline - return local version
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

      // Always save locally first
      await localDatasource.updatePlant(plantModel);

      if (await networkInfo.isConnected) {
        try {
          // Try to update remotely
          final remotePlant = await remoteDatasource.updatePlant(
            plantModel,
            userId,
          );

          // Update local with sync status
          await localDatasource.updatePlant(remotePlant);

          return Right(remotePlant);
        } catch (e) {
          // If remote fails, return local version (will sync later)
          return Right(plantModel);
        }
      } else {
        // Offline - return local version
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

      // Always delete locally first
      await localDatasource.deletePlant(id);

      if (await networkInfo.isConnected) {
        try {
          // Try to delete remotely
          await remoteDatasource.deletePlant(id, userId);
        } catch (e) {
          // If remote fails, the local soft delete will sync later
        }
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
        // For anonymous users still initializing, return empty search results
        return const Right([]);
      }

      if (await networkInfo.isConnected) {
        try {
          // Try to search remotely first
          final remotePlants = await remoteDatasource.searchPlants(
            query,
            userId,
          );

          // Cache results locally
          for (final plant in remotePlants) {
            await localDatasource.updatePlant(plant);
          }

          return Right(remotePlants);
        } catch (e) {
          // If remote fails, fallback to local search
          final localPlants = await localDatasource.searchPlants(query);
          return Right(localPlants);
        }
      } else {
        // Offline - search locally
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
          // Try to get from remote first
          final remotePlants = await remoteDatasource.getPlantsBySpace(
            spaceId,
            userId,
          );

          // Cache locally
          for (final plant in remotePlants) {
            await localDatasource.updatePlant(plant);
          }

          return Right(remotePlants);
        } catch (e) {
          // If remote fails, fallback to local
          final localPlants = await localDatasource.getPlantsBySpace(spaceId);
          return Right(localPlants);
        }
      } else {
        // Offline - get from local
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
    // For now, return a simple stream that emits current plants
    // In a more advanced implementation, you might use Firestore snapshots
    // or a local database with reactive queries
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

      // Get all local plants that need sync
      final localPlants = await localDatasource.getPlants();
      final plantsToSync = localPlants.where((plant) => plant.isDirty).toList();

      if (plantsToSync.isNotEmpty) {
        try {
          await remoteDatasource.syncPlants(
            plantsToSync.map((plant) => PlantModel.fromEntity(plant)).toList(),
            userId,
          );

          // Update local plants to mark as synced
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
