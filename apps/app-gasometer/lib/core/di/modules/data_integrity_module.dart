import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../features/data_management/domain/services/data_integrity_service.dart';
import '../../../features/data_management/domain/services/data_integrity_facade.dart';
import '../../../features/vehicles/domain/services/vehicle_id_reconciliation_service.dart';
import '../../../features/fuel/domain/services/fuel_supply_id_reconciliation_service.dart';
import '../../../features/maintenance/domain/services/maintenance_id_reconciliation_service.dart';

/// DI Module para Data Integrity Services
///
/// Registra os serviços de integridade de dados (refatorados em componentes especializados):
/// - VehicleIdReconciliationService: Reconciliação de IDs de veículos
/// - FuelSupplyIdReconciliationService: Reconciliação de IDs de abastecimentos
/// - MaintenanceIdReconciliationService: Reconciliação de IDs de manutenções
/// - DataIntegrityFacade: Orquestra os 3 serviços acima
/// - DataIntegrityService: Legado (mantido para compatibilidade)
class DataIntegrityModule {
  static void init(GetIt getIt) {
    if (kDebugMode) {
      print('📦 Initializing data integrity module...');
    }

    // Skip data integrity services on web - ILocalStorageRepository não está disponível
    if (kIsWeb) {
      if (kDebugMode) {
        print('⚠️  [DataIntegrityModule] Skipping on web');
      }
      return;
    }

    final localStorage = getIt<ILocalStorageRepository>();

    // Register specialized reconciliation services (SRP)
    getIt.registerLazySingleton<VehicleIdReconciliationService>(
      () => VehicleIdReconciliationService(localStorage),
    );

    getIt.registerLazySingleton<FuelSupplyIdReconciliationService>(
      () => FuelSupplyIdReconciliationService(localStorage),
    );

    getIt.registerLazySingleton<MaintenanceIdReconciliationService>(
      () => MaintenanceIdReconciliationService(localStorage),
    );

    // Register facade that coordinates the 3 services
    getIt.registerLazySingleton<DataIntegrityFacade>(
      () => DataIntegrityFacade(
        vehicleService: getIt<VehicleIdReconciliationService>(),
        fuelService: getIt<FuelSupplyIdReconciliationService>(),
        maintenanceService: getIt<MaintenanceIdReconciliationService>(),
        localStorage: localStorage,
      ),
    );

    // Register legacy service for backwards compatibility
    getIt.registerLazySingleton<DataIntegrityService>(
      () => DataIntegrityService(getIt<DataIntegrityFacade>()),
    );
  }
}
