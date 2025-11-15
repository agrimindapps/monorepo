import 'package:core/core.dart';

import '../../services/data_integrity_service.dart';
import '../../services/data_integrity_facade.dart';
import '../../services/vehicle_id_reconciliation_service.dart';
import '../../services/fuel_supply_id_reconciliation_service.dart';
import '../../services/maintenance_id_reconciliation_service.dart';

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
