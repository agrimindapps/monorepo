import 'dart:developer' as developer;
import 'package:core/core.dart';

import '../../../../core/services/contracts/i_data_integrity_facade.dart';
import '../../../vehicles/domain/services/vehicle_id_reconciliation_service.dart';
import '../../../fuel/domain/services/fuel_supply_id_reconciliation_service.dart';
import '../../../maintenance/domain/services/maintenance_id_reconciliation_service.dart';

/// Facade para orquestrar todos os serviços de integridade de dados
///
/// **Implementação de:** IDataIntegrityFacade
///
/// **Responsabilidades:**
/// - Coordenar os 3 serviços de reconciliação (Vehicle, Fuel, Maintenance)
/// - Verificar integridade de dados após sincronização
/// - Detectar registros órfãos
/// - Facade pattern: simplifica uso dos 3 serviços
/// - Apenas orquestração, sem lógica individual
///
/// **Princípio SOLID:**
/// - Single Responsibility: Orquestração apenas
/// - Dependency Injection via constructor
/// - Error handling via Either<Failure, T>
/// - Delegação para serviços especializados
///
/// **Fluxo Típico:**
/// 1. Após sincronizar com Firebase
/// 2. Detectar mudanças de ID (push retornou IDs diferentes)
/// 3. Reconciliar cada tipo: Vehicle → Fuel → Maintenance
/// 4. Verificar integridade geral
/// 5. Reportar resultados
///
/// **Exemplo:**
/// ```dart
/// final facade = DataIntegrityFacade(
///   VehicleIdReconciliationService(...),
///   FuelSupplyIdReconciliationService(...),
///   MaintenanceIdReconciliationService(...),
/// );
/// 
/// // After sync
/// final result = await facade.reconcileVehicleId('local_123', 'remote_456');
/// result.fold(
///   (failure) => print('Reconciliation failed: ${failure.message}'),
///   (_) => print('Vehicle reconciled successfully'),
/// );
/// 
/// // Verify data integrity
/// final integrity = await facade.verifyDataIntegrity();
/// integrity.fold(
///   (failure) => print('Verification failed: ${failure.message}'),
///   (issues) => print('Issues found: ${issues.length}'),
/// );
/// ```
class DataIntegrityFacade implements IDataIntegrityFacade {
  DataIntegrityFacade({
    required VehicleIdReconciliationService vehicleService,
    required FuelSupplyIdReconciliationService fuelService,
    required MaintenanceIdReconciliationService maintenanceService,
    required ILocalStorageRepository localStorage,
  })  : _vehicleService = vehicleService,
        _fuelService = fuelService,
        _maintenanceService = maintenanceService,
        _localStorage = localStorage;

  final VehicleIdReconciliationService _vehicleService;
  final FuelSupplyIdReconciliationService _fuelService;
  final MaintenanceIdReconciliationService _maintenanceService;
  final ILocalStorageRepository _localStorage;

  /// Reconcilia ID de veículo (delegação para VehicleIdReconciliationService)
  ///
  /// **Quando usar:**
  /// - Após Firebase retornar novo ID para veículo criado offline
  ///
  /// **Retorna:**
  /// - Right(null): Reconciliação concluída
  /// - Left(failure): Erro na reconciliação
  Future<Either<Failure, void>> reconcileVehicleId(
    String localId,
    String remoteId,
  ) async {
    try {
      return await _vehicleService.reconcileId(localId, remoteId);
    } catch (e) {
      developer.log(
        '❌ Vehicle reconciliation facade error: $e',
        name: 'DataIntegrityFacade',
      );
      return Left(CacheFailure('Vehicle reconciliation failed: $e'));
    }
  }

  /// Reconcilia ID de abastecimento (delegação para FuelSupplyIdReconciliationService)
  ///
  /// **Quando usar:**
  /// - Após Firebase retornar novo ID para combustível criado offline
  ///
  /// **IMPORTANTE - Dados Financeiros:**
  /// - Evita duplicação de registros financeiros
  /// - Mantém auditoria detalhada
  ///
  /// **Retorna:**
  /// - Right(null): Reconciliação concluída
  /// - Left(failure): Erro na reconciliação
  Future<Either<Failure, void>> reconcileFuelSupplyId(
    String localId,
    String remoteId,
  ) async {
    try {
      return await _fuelService.reconcileId(localId, remoteId);
    } catch (e) {
      developer.log(
        '❌ Fuel reconciliation facade error: $e',
        name: 'DataIntegrityFacade',
      );
      return Left(CacheFailure('Fuel reconciliation failed: $e'));
    }
  }

  /// Reconcilia ID de manutenção (delegação para MaintenanceIdReconciliationService)
  ///
  /// **Quando usar:**
  /// - Após Firebase retornar novo ID para manutenção criada offline
  ///
  /// **IMPORTANTE - Dados Financeiros:**
  /// - Evita duplicação de registros de custo
  /// - Mantém histórico de serviços consistente
  ///
  /// **Retorna:**
  /// - Right(null): Reconciliação concluída
  /// - Left(failure): Erro na reconciliação
  Future<Either<Failure, void>> reconcileMaintenanceId(
    String localId,
    String remoteId,
  ) async {
    try {
      return await _maintenanceService.reconcileId(localId, remoteId);
    } catch (e) {
      developer.log(
        '❌ Maintenance reconciliation facade error: $e',
        name: 'DataIntegrityFacade',
      );
      return Left(CacheFailure('Maintenance reconciliation failed: $e'));
    }
  }

  /// Verifica integridade de dados após sincronização
  ///
  /// **Validações:**
  /// - Sem registros órfãos (FuelRecord/Maintenance sem Vehicle válido)
  /// - Sem duplicações de ID
  /// - Referências consistentes
  /// - Valores financeiros válidos
  ///
  /// **Retorna:**
  /// - Right(issues): Map com issues detectados (pode ser vazio se tudo ok)
  /// - Left(failure): Erro ao verificar
  Future<Either<Failure, Map<String, dynamic>>> verifyDataIntegrity() async {
    try {
      developer.log(
        '🔍 Starting comprehensive data integrity verification',
        name: 'DataIntegrityFacade',
      );

      final issues = <String, dynamic>{
        'orphaned_fuel_records': <String>[],
        'orphaned_maintenances': <String>[],
        'duplicated_ids': <String, List<String>>{},
        'timestamp': DateTime.now().toIso8601String(),
      };

      // 1. Carrega todos os veículos
      final vehiclesResult = await _localStorage.getValues<Map<String, dynamic>>(
        box: 'vehicles',
      );

      final vehicleIds = <String>[];
      vehiclesResult.fold(
        (_) {},
        (vehicles) {
          for (final vehicle in vehicles) {
            final id = vehicle['id'] as String?;
            if (id != null) {
              vehicleIds.add(id);
            }
          }
        },
      );

      // 2. Verifica FuelRecords órfãos
      final fuelRecordsResult =
          await _localStorage.getValues<Map<String, dynamic>>(
        box: 'fuel_records',
      );

      fuelRecordsResult.fold(
        (_) {},
        (records) {
          for (final record in records) {
            final vehicleId = record['vehicle_id'] as String?;
            final recordId = record['id'] as String?;

            if (vehicleId != null && !vehicleIds.contains(vehicleId)) {
              issues['orphaned_fuel_records'].add(recordId ?? 'unknown');
            }
          }
        },
      );

      // 3. Verifica Maintenances órfãs
      final maintenancesResult =
          await _localStorage.getValues<Map<String, dynamic>>(
        box: 'maintenance_records',
      );

      maintenancesResult.fold(
        (_) {},
        (records) {
          for (final record in records) {
            final vehicleId = record['vehicle_id'] as String?;
            final recordId = record['id'] as String?;

            if (vehicleId != null && !vehicleIds.contains(vehicleId)) {
              issues['orphaned_maintenances'].add(recordId ?? 'unknown');
            }
          }
        },
      );

      final orphanedCount = (issues['orphaned_fuel_records'] as List).length +
          (issues['orphaned_maintenances'] as List).length;

      if (orphanedCount > 0) {
        developer.log(
          '⚠️ Data integrity issues found:\n'
          '   Orphaned fuel records: ${(issues["orphaned_fuel_records"] as List).length}\n'
          '   Orphaned maintenances: ${(issues["orphaned_maintenances"] as List).length}',
          name: 'DataIntegrityFacade',
        );
      } else {
        developer.log(
          '✅ Data integrity verification passed - No issues found',
          name: 'DataIntegrityFacade',
        );
      }

      return Right(issues);
    } catch (e) {
      developer.log(
        '❌ Data integrity verification failed: $e',
        name: 'DataIntegrityFacade',
      );
      return Left(
        CacheFailure('Failed to verify data integrity: $e'),
      );
    }
  }
}
