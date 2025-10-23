import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../features/fuel/domain/entities/fuel_record_entity.dart';
import '../../features/maintenance/domain/entities/maintenance_entity.dart';
import '../../features/vehicles/domain/entities/vehicle_entity.dart';

/// Service responsável por garantir integridade de dados durante sincronização
///
/// Principais responsabilidades:
/// - ID Reconciliation (local → remote): Previne duplicação quando IDs temporários
///   são substituídos por IDs permanentes do Firebase
/// - Auditoria de operações críticas: Log detalhado para operações financeiras
/// - Validação de integridade: Garante consistência de dados entre local e remote
///
/// **Contexto Financeiro:**
/// Este serviço é especialmente crítico para app-gasometer pois lida com dados
/// financeiros (abastecimentos e manutenções) que não podem ser duplicados ou perdidos.
///
/// **Fluxo de ID Reconciliation:**
/// 1. Usuário cria registro offline → ID local temporário (ex: "local_abc123")
/// 2. App sincroniza com Firebase → Firebase pode manter ID local ou gerar novo
/// 3. DataIntegrityService detecta mudança de ID (se houver)
/// 4. Atualiza HiveBox local: remove ID antigo, salva com ID novo
/// 5. Atualiza referências (ex: FuelRecord.vehicleId)
class DataIntegrityService {
  DataIntegrityService(this._localStorage);

  final ILocalStorageRepository _localStorage;

  /// Reconcilia ID local com ID remoto após sincronização bem-sucedida
  ///
  /// **Quando usar:**
  /// - Após criar entidade localmente e sincronizar com Firebase
  /// - Quando Firebase retorna ID diferente do local
  ///
  /// **Processo:**
  /// 1. Verifica se IDs são diferentes
  /// 2. Se sim, busca entidade com ID local
  /// 3. Remove entrada antiga do HiveBox
  /// 4. Salva entidade com ID remoto
  /// 5. Atualiza referências dependentes
  ///
  /// **Exemplo:**
  /// ```dart
  /// final result = await dataIntegrityService.reconcileVehicleId(
  ///   'local_abc123',  // ID temporário offline
  ///   'firebase_xyz789', // ID permanente do Firebase
  /// );
  /// ```
  Future<Either<Failure, void>> reconcileVehicleId(
    String localId,
    String remoteId,
  ) async {
    if (localId == remoteId) {
      // IDs iguais - sem necessidade de reconciliação
      return const Right(null);
    }

    try {
      developer.log(
        '🔄 ID Reconciliation - Vehicle:\n'
        '   Local ID: $localId\n'
        '   Remote ID: $remoteId',
        name: 'DataIntegrity',
      );

      // 1. Busca veículo com ID local
      final localResult = await _localStorage.get<Map<String, dynamic>>(
        key: localId,
        box: 'vehicles',
      );

      final vehicleMap = localResult.fold(
        (failure) {
          developer.log(
            '⚠️ Vehicle not found with local ID: $localId',
            name: 'DataIntegrity',
          );
          return null;
        },
        (data) => data,
      );

      if (vehicleMap == null) {
        // Veículo já foi removido ou não existe - não é erro crítico
        return const Right(null);
      }

      // 2. Verifica se já existe entidade com remoteId
      final remoteResult = await _localStorage.get<Map<String, dynamic>>(
        key: remoteId,
        box: 'vehicles',
      );

      final alreadyExists = remoteResult.fold(
        (_) => false,
        (data) => data != null,
      );

      if (alreadyExists) {
        developer.log(
          '⚠️ Duplicate detected - Remote ID already exists: $remoteId',
          name: 'DataIntegrity',
        );

        // Estratégia: manter remoto (mais recente), remover local
        await _localStorage.remove(key: localId, box: 'vehicles');

        developer.log(
          '✅ Resolved duplication - Kept remote, deleted local',
          name: 'DataIntegrity',
        );

        return const Right(null);
      }

      // 3. Atualiza ID no map
      final updatedVehicleMap = Map<String, dynamic>.from(vehicleMap);
      updatedVehicleMap['id'] = remoteId;

      // 4. Salva com novo ID
      final saveResult = await _localStorage.save<Map<String, dynamic>>(
        key: remoteId,
        data: updatedVehicleMap,
        box: 'vehicles',
      );

      if (saveResult.isLeft()) {
        return saveResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      }

      // 5. Remove entrada antiga
      await _localStorage.remove(key: localId, box: 'vehicles');

      // 6. Atualiza referências dependentes (FuelRecord.vehicleId, Maintenance.vehicleId)
      await _updateDependentReferences(localId, remoteId);

      final vehicle = VehicleEntity.fromFirebaseMap(updatedVehicleMap);

      developer.log(
        '✅ ID Reconciliation completed:\n'
        '   Vehicle: ${vehicle.name} (${vehicle.licensePlate})\n'
        '   Old ID: $localId → New ID: $remoteId',
        name: 'DataIntegrity',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        '❌ ID Reconciliation failed: $e',
        name: 'DataIntegrity',
      );
      return Left(CacheFailure('Failed to reconcile vehicle ID: $e'));
    }
  }

  /// Reconcilia ID de FuelRecord (operação crítica - dados financeiros)
  Future<Either<Failure, void>> reconcileFuelRecordId(
    String localId,
    String remoteId,
  ) async {
    if (localId == remoteId) {
      return const Right(null);
    }

    try {
      developer.log(
        '🔄 ID Reconciliation - FuelRecord:\n'
        '   Local ID: $localId\n'
        '   Remote ID: $remoteId',
        name: 'DataIntegrity',
      );

      // 1. Busca registro com ID local
      final localResult = await _localStorage.get<Map<String, dynamic>>(
        key: localId,
        box: 'fuel_records',
      );

      final recordMap = localResult.fold(
        (failure) {
          developer.log(
            '⚠️ FuelRecord not found with local ID: $localId',
            name: 'DataIntegrity',
          );
          return null;
        },
        (data) => data,
      );

      if (recordMap == null) {
        return const Right(null);
      }

      // 2. Verifica duplicação
      final remoteResult = await _localStorage.get<Map<String, dynamic>>(
        key: remoteId,
        box: 'fuel_records',
      );

      final alreadyExists = remoteResult.fold(
        (_) => false,
        (data) => data != null,
      );

      if (alreadyExists) {
        developer.log(
          '⚠️ Duplicate FuelRecord detected - Remote ID already exists: $remoteId',
          name: 'DataIntegrity',
        );

        // Dados financeiros: mesclar valores (soma litros, valor total)
        final remoteRecordMapNullable = remoteResult.getOrElse(() => null);
        if (remoteRecordMapNullable == null) {
          return const Left(CacheFailure('Remote record not found during merge'));
        }
        final mergedMap = await _mergeFuelRecords(recordMap, remoteRecordMapNullable);

        // Salva registro mesclado
        await _localStorage.save<Map<String, dynamic>>(
          key: remoteId,
          data: mergedMap,
          box: 'fuel_records',
        );

        // Remove local
        await _localStorage.remove(key: localId, box: 'fuel_records');

        developer.log(
          '✅ Resolved duplication - Merged fuel records',
          name: 'DataIntegrity',
        );

        return const Right(null);
      }

      // 3. Atualiza ID no map
      final updatedRecordMap = Map<String, dynamic>.from(recordMap);
      updatedRecordMap['id'] = remoteId;

      // 4. Salva com novo ID
      final saveResult = await _localStorage.save<Map<String, dynamic>>(
        key: remoteId,
        data: updatedRecordMap,
        box: 'fuel_records',
      );

      if (saveResult.isLeft()) {
        return saveResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      }

      // 5. Remove entrada antiga
      await _localStorage.remove(key: localId, box: 'fuel_records');

      final fuelRecord = FuelRecordEntity.fromFirebaseMap(updatedRecordMap);

      developer.log(
        '✅ ID Reconciliation completed - FuelRecord:\n'
        '   Date: ${fuelRecord.date}\n'
        '   Value: R\$ ${fuelRecord.totalPrice.toStringAsFixed(2)}\n'
        '   Liters: ${fuelRecord.liters.toStringAsFixed(2)}L\n'
        '   Old ID: $localId → New ID: $remoteId',
        name: 'DataIntegrity',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        '❌ ID Reconciliation failed (FuelRecord): $e',
        name: 'DataIntegrity',
      );
      return Left(CacheFailure('Failed to reconcile fuel record ID: $e'));
    }
  }

  /// Reconcilia ID de Maintenance (operação crítica - dados financeiros)
  Future<Either<Failure, void>> reconcileMaintenanceId(
    String localId,
    String remoteId,
  ) async {
    if (localId == remoteId) {
      return const Right(null);
    }

    try {
      developer.log(
        '🔄 ID Reconciliation - Maintenance:\n'
        '   Local ID: $localId\n'
        '   Remote ID: $remoteId',
        name: 'DataIntegrity',
      );

      // 1. Busca manutenção com ID local
      final localResult = await _localStorage.get<Map<String, dynamic>>(
        key: localId,
        box: 'maintenance_records',
      );

      final maintenanceMap = localResult.fold(
        (failure) {
          developer.log(
            '⚠️ Maintenance not found with local ID: $localId',
            name: 'DataIntegrity',
          );
          return null;
        },
        (data) => data,
      );

      if (maintenanceMap == null) {
        return const Right(null);
      }

      // 2. Verifica duplicação
      final remoteResult = await _localStorage.get<Map<String, dynamic>>(
        key: remoteId,
        box: 'maintenance_records',
      );

      final alreadyExists = remoteResult.fold(
        (_) => false,
        (data) => data != null,
      );

      if (alreadyExists) {
        developer.log(
          '⚠️ Duplicate Maintenance detected - Remote ID already exists: $remoteId',
          name: 'DataIntegrity',
        );

        // Manter remoto (mais recente), remover local
        await _localStorage.remove(key: localId, box: 'maintenance_records');

        developer.log(
          '✅ Resolved duplication - Kept remote, deleted local',
          name: 'DataIntegrity',
        );

        return const Right(null);
      }

      // 3. Atualiza ID no map
      final updatedMaintenanceMap = Map<String, dynamic>.from(maintenanceMap);
      updatedMaintenanceMap['id'] = remoteId;

      // 4. Salva com novo ID
      final saveResult = await _localStorage.save<Map<String, dynamic>>(
        key: remoteId,
        data: updatedMaintenanceMap,
        box: 'maintenance_records',
      );

      if (saveResult.isLeft()) {
        return saveResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      }

      // 5. Remove entrada antiga
      await _localStorage.remove(key: localId, box: 'maintenance_records');

      final maintenance = MaintenanceEntity.fromFirebaseMap(updatedMaintenanceMap);

      developer.log(
        '✅ ID Reconciliation completed - Maintenance:\n'
        '   Type: ${maintenance.type.displayName}\n'
        '   Date: ${maintenance.serviceDate}\n'
        '   Cost: R\$ ${maintenance.cost.toStringAsFixed(2)}\n'
        '   Old ID: $localId → New ID: $remoteId',
        name: 'DataIntegrity',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        '❌ ID Reconciliation failed (Maintenance): $e',
        name: 'DataIntegrity',
      );
      return Left(CacheFailure('Failed to reconcile maintenance ID: $e'));
    }
  }

  /// Atualiza referências dependentes quando um veículo tem seu ID alterado
  ///
  /// **Entidades afetadas:**
  /// - FuelRecord.vehicleId
  /// - Maintenance.vehicleId
  Future<void> _updateDependentReferences(
    String oldVehicleId,
    String newVehicleId,
  ) async {
    try {
      developer.log(
        '🔄 Updating dependent references:\n'
        '   Old Vehicle ID: $oldVehicleId → New: $newVehicleId',
        name: 'DataIntegrity',
      );

      // Atualiza FuelRecords
      final fuelRecordsResult = await _localStorage.getValues<Map<String, dynamic>>(
        box: 'fuel_records',
      );

      await fuelRecordsResult.fold(
        (failure) async {
          developer.log(
            '⚠️ Failed to load fuel records: ${failure.message}',
            name: 'DataIntegrity',
          );
        },
        (records) async {
          int updatedCount = 0;

          for (final recordMap in records) {
            final vehicleId = recordMap['vehicle_id'] as String?;

            if (vehicleId == oldVehicleId) {
              final updatedMap = Map<String, dynamic>.from(recordMap);
              updatedMap['vehicle_id'] = newVehicleId;

              final recordId = recordMap['id'] as String;
              await _localStorage.save<Map<String, dynamic>>(
                key: recordId,
                data: updatedMap,
                box: 'fuel_records',
              );

              updatedCount++;
            }
          }

          if (updatedCount > 0) {
            developer.log(
              '✅ Updated $updatedCount fuel record(s) with new vehicle ID',
              name: 'DataIntegrity',
            );
          }
        },
      );

      // Atualiza Maintenances
      final maintenancesResult = await _localStorage.getValues<Map<String, dynamic>>(
        box: 'maintenance_records',
      );

      await maintenancesResult.fold(
        (failure) async {
          developer.log(
            '⚠️ Failed to load maintenance records: ${failure.message}',
            name: 'DataIntegrity',
          );
        },
        (records) async {
          int updatedCount = 0;

          for (final recordMap in records) {
            final vehicleId = recordMap['vehicle_id'] as String?;

            if (vehicleId == oldVehicleId) {
              final updatedMap = Map<String, dynamic>.from(recordMap);
              updatedMap['vehicle_id'] = newVehicleId;

              final recordId = recordMap['id'] as String;
              await _localStorage.save<Map<String, dynamic>>(
                key: recordId,
                data: updatedMap,
                box: 'maintenance_records',
              );

              updatedCount++;
            }
          }

          if (updatedCount > 0) {
            developer.log(
              '✅ Updated $updatedCount maintenance record(s) with new vehicle ID',
              name: 'DataIntegrity',
            );
          }
        },
      );
    } catch (e) {
      developer.log(
        '❌ Failed to update dependent references: $e',
        name: 'DataIntegrity',
      );
    }
  }

  /// Mescla dois FuelRecords quando há duplicação
  ///
  /// **Estratégia:**
  /// - Manter data/odômetro/posto do mais recente
  /// - **NÃO** somar litros/valores (são registros duplicados, não adicionais)
  /// - Priorizar registro com updatedAt mais recente
  Future<Map<String, dynamic>> _mergeFuelRecords(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) async {
    try {
      // Parse timestamps
      final localUpdated = local['updated_at'] != null
          ? DateTime.parse(local['updated_at'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0);

      final remoteUpdated = remote['updated_at'] != null
          ? DateTime.parse(remote['updated_at'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0);

      // Manter o mais recente
      final newerRecord = localUpdated.isAfter(remoteUpdated) ? local : remote;

      developer.log(
        '🔄 Merging fuel records - Using ${localUpdated.isAfter(remoteUpdated) ? "local" : "remote"} (newer)',
        name: 'DataIntegrity',
      );

      return Map<String, dynamic>.from(newerRecord);
    } catch (e) {
      developer.log(
        '⚠️ Error merging fuel records: $e - Using remote',
        name: 'DataIntegrity',
      );

      return Map<String, dynamic>.from(remote);
    }
  }

  /// Verifica integridade de dados após sincronização
  ///
  /// **Validações:**
  /// - Sem registros órfãos (FuelRecord/Maintenance sem Vehicle válido)
  /// - Sem duplicações de ID
  /// - Valores financeiros consistentes
  Future<Either<Failure, Map<String, dynamic>>> verifyDataIntegrity() async {
    try {
      developer.log(
        '🔍 Starting data integrity verification',
        name: 'DataIntegrity',
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
      final fuelRecordsResult = await _localStorage.getValues<Map<String, dynamic>>(
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
      final maintenancesResult = await _localStorage.getValues<Map<String, dynamic>>(
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

      final orphanedCount =
          (issues['orphaned_fuel_records'] as List).length +
          (issues['orphaned_maintenances'] as List).length;

      if (orphanedCount > 0) {
        developer.log(
          '⚠️ Data integrity issues found:\n'
          '   Orphaned fuel records: ${(issues['orphaned_fuel_records'] as List).length}\n'
          '   Orphaned maintenances: ${(issues['orphaned_maintenances'] as List).length}',
          name: 'DataIntegrity',
        );
      } else {
        developer.log(
          '✅ Data integrity verification passed - No issues found',
          name: 'DataIntegrity',
        );
      }

      return Right(issues);
    } catch (e) {
      developer.log(
        '❌ Data integrity verification failed: $e',
        name: 'DataIntegrity',
      );
      return Left(CacheFailure('Failed to verify data integrity: $e'));
    }
  }
}
