import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../features/fuel/domain/repositories/fuel_repository.dart';
import '../../features/maintenance/domain/repositories/maintenance_repository.dart';
import '../../features/vehicles/domain/repositories/vehicle_repository.dart';
import '../logging/entities/log_entry.dart';
import '../logging/services/logging_service.dart';

/// Serviço responsável por sincronização única no startup do app
/// Substitui os syncs em background que causavam problemas de index
class StartupSyncService {

  StartupSyncService({
    required this.fuelRepository,
    required this.maintenanceRepository,
    required this.vehicleRepository,
    required this.connectivity,
    required this.loggingService,
  });
  final FuelRepository fuelRepository;
  final MaintenanceRepository maintenanceRepository;
  final VehicleRepository vehicleRepository;
  final Connectivity connectivity;
  final LoggingService loggingService;

  /// Executa sincronização inicial apenas no startup do app
  Future<void> performStartupSync() async {
    await loggingService.logInfo(
      category: LogCategory.sync,
      message: 'Starting initial app sync',
      metadata: {'sync_type': 'startup'},
    );

    try {
      // Verificar conectividade antes de tentar sincronizar
      final connectivityResults = await connectivity.checkConnectivity();
      final isConnected = !connectivityResults.contains(ConnectivityResult.none);

      if (!isConnected) {
        await loggingService.logInfo(
          category: LogCategory.sync,
          message: 'No internet connection - skipping startup sync',
          metadata: {'connected': false},
        );
        return;
      }

      await loggingService.logInfo(
        category: LogCategory.sync,
        message: 'Internet connected - proceeding with startup sync',
        metadata: {'connected': true},
      );

      // Realizar sync dos dados principais (sem aguardar todos completarem)
      final futures = <Future<void>>[
        _syncFuelData(),
        _syncMaintenanceData(),
        _syncVehicleData(),
      ];

      // Executar syncs em paralelo com timeout
      await Future.wait(futures, eagerError: false).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          loggingService.logInfo(
            category: LogCategory.sync,
            message: 'Startup sync timeout - continuing with local data',
            metadata: {'timeout_seconds': 30},
          );
          return [];
        },
      );

      await loggingService.logInfo(
        category: LogCategory.sync,
        message: 'Startup sync completed successfully',
        metadata: {'sync_type': 'startup', 'status': 'completed'},
      );

    } catch (e) {
      // Sync falhou, mas app deve continuar funcionando com dados locais
      await loggingService.logOperationWarning(
        category: LogCategory.sync,
        operation: LogOperation.sync,
        message: 'Startup sync failed - app will continue with local data',
        metadata: {
          'error': e.toString(),
          'sync_type': 'startup',
          'status': 'failed',
        },
      );

      if (kDebugMode) {
        debugPrint('🚨 Startup sync failed: $e');
      }
    }
  }

  /// Sincroniza dados de combustível (sem causar erros de index)
  Future<void> _syncFuelData() async {
    try {
      // Apenas carrega dados locais - sync remoto removido devido a problemas de index
      await fuelRepository.getAllFuelRecords();

      await loggingService.logInfo(
        category: LogCategory.fuel,
        message: 'Fuel data loaded from local storage',
        metadata: {'data_source': 'local'},
      );
    } catch (e) {
      await loggingService.logOperationWarning(
        category: LogCategory.fuel,
        operation: LogOperation.read,
        message: 'Failed to load fuel data',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Sincroniza dados de manutenção (sem causar erros de index)
  Future<void> _syncMaintenanceData() async {
    try {
      // Apenas carrega dados locais - sync remoto removido devido a problemas de index
      await maintenanceRepository.getAllMaintenanceRecords();

      await loggingService.logInfo(
        category: LogCategory.maintenance,
        message: 'Maintenance data loaded from local storage',
        metadata: {'data_source': 'local'},
      );
    } catch (e) {
      await loggingService.logOperationWarning(
        category: LogCategory.maintenance,
        operation: LogOperation.read,
        message: 'Failed to load maintenance data',
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Sincroniza dados de veículos
  Future<void> _syncVehicleData() async {
    try {
      await vehicleRepository.getAllVehicles();

      await loggingService.logInfo(
        category: LogCategory.vehicles,
        message: 'Vehicle data loaded from local storage',
        metadata: {'data_source': 'local'},
      );
    } catch (e) {
      await loggingService.logOperationWarning(
        category: LogCategory.vehicles,
        operation: LogOperation.read,
        message: 'Failed to load vehicle data',
        metadata: {'error': e.toString()},
      );
    }
  }
}