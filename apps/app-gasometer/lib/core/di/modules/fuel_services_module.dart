import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../features/fuel/domain/services/fuel_crud_service.dart';
import '../../../features/fuel/domain/services/fuel_query_service.dart';
import '../../../features/fuel/domain/services/fuel_sync_service.dart';
import '../../../features/fuel/data/datasources/fuel_supply_local_datasource.dart';
import '../../../features/fuel/domain/usecases/add_fuel_record.dart';
import '../../../features/fuel/domain/usecases/delete_fuel_record.dart';
import '../../../features/fuel/domain/usecases/get_all_fuel_records.dart';
import '../../../features/fuel/domain/usecases/get_fuel_records_by_vehicle.dart';
import '../../../features/fuel/domain/usecases/update_fuel_record.dart';

/// Módulo de Dependency Injection para serviços de combustível
/// Registra serviços especializados seguindo SRP:
/// - FuelCrudService: Add/Update/Delete operations
/// - FuelQueryService: Read/Query/Filter/Search operations
/// - FuelSyncService: Sync pending records operations
abstract class FuelServicesModule {
  static void init(GetIt sl) {
    if (kDebugMode) {
      print('📦 Registering Fuel Services...');
    }

    try {
      // Register CRUD service (Add/Update/Delete)
      sl.registerLazySingleton<FuelCrudService>(
        () => FuelCrudService(
          addFuelRecord: sl<AddFuelRecord>(),
          updateFuelRecord: sl<UpdateFuelRecord>(),
          deleteFuelRecord: sl<DeleteFuelRecord>(),
        ),
      );

      // Register Query service (Read/Filter/Search)
      sl.registerLazySingleton<FuelQueryService>(
        () => FuelQueryService(
          getAllFuelRecords: sl<GetAllFuelRecords>(),
          getFuelRecordsByVehicle: sl<GetFuelRecordsByVehicle>(),
        ),
      );

      // Register Sync service (Sync pending records)
      sl.registerLazySingleton<FuelSyncService>(
        () => FuelSyncService(
          localDataSource: sl<FuelSupplyLocalDataSource>(),
        ),
      );

      if (kDebugMode) {
        print('✅ Fuel Services registered successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to register Fuel Services: $e');
      }
    }
  }
}
