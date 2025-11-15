import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/services/plant_sync_service.dart';
import '../datasources/local/plants_local_datasource.dart';
import '../datasources/remote/plants_remote_datasource.dart';

@lazySingleton
class PlantSyncServiceImpl implements PlantSyncService {
  PlantSyncServiceImpl({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  final PlantsLocalDatasource localDatasource;
  final PlantsRemoteDatasource remoteDatasource;

  @override
  Future<void> syncPlantsInBackground(
    String userId, {
    bool connectionRestored = false,
  }) async {
    try {
      final remotePlants = await remoteDatasource.getPlants(userId);

      final syncType = connectionRestored ? 'Connection restored sync' : 'Background sync';
      if (kDebugMode) {
        print(
          '✅ PlantSyncService: $syncType completed - ${remotePlants.length} plants',
        );
      }

      for (final plant in remotePlants) {
        await localDatasource.updatePlant(plant);
      }

      if (kDebugMode) {
        print('✅ PlantSyncService: All plants synced to local datasource');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ PlantSyncService: Background sync failed: $e');
      }
    }
  }

  @override
  Future<void> syncSinglePlantInBackground(String plantId, String userId) async {
    try {
      final remotePlant = await remoteDatasource.getPlantById(plantId, userId);
      await localDatasource.updatePlant(remotePlant);

      if (kDebugMode) {
        print('✅ PlantSyncService: Plant $plantId synced');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ PlantSyncService: Failed to sync plant $plantId: $e');
      }
    }
  }
}
