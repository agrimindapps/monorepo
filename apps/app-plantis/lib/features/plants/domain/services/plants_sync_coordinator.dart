import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../data/datasources/local/plants_local_datasource.dart';
import '../../data/datasources/remote/plants_remote_datasource.dart';
import '../../data/models/plant_model.dart';
import '../entities/plant.dart';

/// Service responsible for coordinating synchronization between local and remote data sources
/// Extracted from PlantsRepository to follow Single Responsibility Principle (SRP)
@injectable
class PlantsSyncCoordinator {
  PlantsSyncCoordinator({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.networkInfo,
    required this.logger,
  });

  final PlantsLocalDatasource localDatasource;
  final PlantsRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;
  final ILoggingRepository logger;

  /// Schedule background sync if online
  Future<void> scheduleSyncIfOnline(String userId) async {
    if (await networkInfo.isConnected) {
      await _syncPlantsInBackground(userId);
    }
  }

  /// Sync all plants in background
  Future<void> _syncPlantsInBackground(
    String userId, {
    bool connectionRestored = false,
  }) async {
    try {
      final remotePlants = await remoteDatasource.getPlants(userId);

      final syncType =
          connectionRestored ? 'Connection restored sync' : 'Background sync';

      logger.info(
        '$syncType completed - ${remotePlants.length} plants',
        data: {'plant_count': remotePlants.length, 'sync_type': syncType},
      );

      for (final plant in remotePlants) {
        await localDatasource.updatePlant(plant);
      }
    } catch (e) {
      logger.warning(
        'Background sync failed',
        error: e,
        data: {'user_id': userId},
      );
    }
  }

  /// Sync single plant in background
  Future<void> syncSinglePlant(String plantId, String userId) async {
    try {
      final remotePlant = await remoteDatasource.getPlantById(plantId, userId);
      await localDatasource.updatePlant(remotePlant);
      
      logger.debug(
        'Single plant synced successfully',
        data: {'plant_id': plantId},
      );
    } catch (e) {
      logger.warning(
        'Single plant sync failed',
        error: e,
        data: {'plant_id': plantId, 'user_id': userId},
      );
    }
  }

  /// Sync pending local changes to remote
  Future<Either<Failure, void>> syncPendingChanges(String userId) async {
    try {
      if (!(await networkInfo.isConnected)) {
        return const Left(NetworkFailure('Sem conexão com a internet'));
      }

      final localPlants = await localDatasource.getPlants();
      final plantsToSync = localPlants.where((plant) => plant.isDirty).toList();

      if (plantsToSync.isEmpty) {
        logger.debug('No pending changes to sync');
        return const Right(null);
      }

      logger.info('Syncing ${plantsToSync.length} pending changes');

      await remoteDatasource.syncPlants(
        plantsToSync.map((plant) => PlantModel.fromEntity(plant)).toList(),
        userId,
      );

      // Mark plants as synced locally
      for (final plant in plantsToSync) {
        final syncedPlant = plant.copyWith(isDirty: false);
        await localDatasource.updatePlant(syncedPlant);
      }

      logger.info('Successfully synced ${plantsToSync.length} plants');
      return const Right(null);
    } catch (e) {
      logger.error(
        'Failed to sync pending changes',
        error: e,
        data: {'user_id': userId},
      );
      return Left(
        ServerFailure('Erro ao sincronizar mudanças: ${e.toString()}'),
      );
    }
  }

  /// Handle connectivity change event
  Future<void> onConnectivityChanged(bool isConnected, String? userId) async {
    if (isConnected && userId != null) {
      logger.info('Connection restored - starting auto-sync');
      await _syncPlantsInBackground(userId, connectionRestored: true);
    } else {
      logger.info('Connection lost - switching to offline mode');
    }
  }
}
