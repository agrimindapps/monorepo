import 'dart:developer' as developer;
import 'package:core/core.dart';

import '../../../../core/interfaces/i_id_reconciliation_service.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Serviço especializado em reconciliação de IDs de veículos
///
/// **Responsabilidades:**
/// - Reconciliar ID local → ID remoto de veículos
/// - Detectar e resolver duplicações
/// - Atualizar referências dependentes (FuelRecords, Maintenances)
/// - Apenas operações de reconciliação de veículos
///
/// **Princípio SOLID:**
/// - Single Responsibility: Apenas reconciliação de veículos
/// - Dependency Injection via constructor
/// - Error handling via Either<Failure, T>
/// - Interface Segregation: Implementa IIdReconciliationService
///
/// **Contexto:**
/// Quando um usuário cria um veículo offline:
/// 1. Cria com ID local (ex: "local_abc123")
/// 2. Sincroniza com Firebase
/// 3. Firebase retorna novo ID permanente (ex: "firebase_xyz789")
/// 4. Este serviço detecta mudança e reconcilia
/// 5. Atualiza todas as referências (abastecimentos, manutenções, etc)
///
/// **Exemplo:**
/// ```dart
/// final service = VehicleIdReconciliationService(localStorage);
/// final result = await service.reconcileId(
///   'local_abc123',   // ID temporário offline
///   'firebase_xyz789', // ID permanente do Firebase
/// );
/// ```
class VehicleIdReconciliationService implements IIdReconciliationService {
  VehicleIdReconciliationService(this._localStorage);

  final ILocalStorageRepository _localStorage;

  /// Reconcilia ID de veículo local com ID remoto
  ///
  /// **Processo:**
  /// 1. Verifica se IDs são diferentes
  /// 2. Se sim, busca veículo com ID local
  /// 3. Verifica se remoteId já existe (duplicação)
  /// 4. Remove entrada antiga
  /// 5. Salva com ID novo
  /// 6. Atualiza referências dependentes
  ///
  /// **Retorna:**
  /// - Right(null): Reconciliação concluída
  /// - Left(failure): Erro no processo
  @override
  Future<Either<Failure, void>> reconcileId(
    String localId,
    String remoteId,
  ) async {
    if (localId == remoteId) {
      return const Right(null);
    }

    try {
      developer.log(
        '🔄 Vehicle ID Reconciliation:\n'
        '   Local: $localId\n'
        '   Remote: $remoteId',
        name: 'VehicleReconciliation',
      );

      // 1. Busca veículo com ID local
      final localResult = await _localStorage.get<Map<String, dynamic>>(
        key: localId,
        box: 'vehicles',
      );

      final vehicleMap = localResult.fold((failure) {
        developer.log(
          '⚠️ Vehicle not found with local ID: $localId',
          name: 'VehicleReconciliation',
        );
        return null;
      }, (data) => data);

      if (vehicleMap == null) {
        return const Right(null);
      }

      // 2. Verifica duplicação
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
          '⚠️ Duplicate detected - keeping remote, deleting local',
          name: 'VehicleReconciliation',
        );
        await _localStorage.remove(key: localId, box: 'vehicles');
        return const Right(null);
      }

      // 3. Atualiza ID e salva com novo ID
      final updatedMap = Map<String, dynamic>.from(vehicleMap);
      updatedMap['id'] = remoteId;

      final saveResult = await _localStorage.save<Map<String, dynamic>>(
        key: remoteId,
        data: updatedMap,
        box: 'vehicles',
      );

      if (saveResult.isLeft()) {
        return saveResult.fold(
          (failure) => Left(failure),
          (_) => const Right(null),
        );
      }

      // 4. Remove entrada antiga
      await _localStorage.remove(key: localId, box: 'vehicles');

      // 5. Atualiza referências dependentes
      await _updateReferences(localId, remoteId);

      final vehicle = VehicleEntity.fromFirebaseMap(updatedMap);

      developer.log(
        '✅ Vehicle reconciliation completed:\n'
        '   ${vehicle.name} (${vehicle.licensePlate})\n'
        '   $localId → $remoteId',
        name: 'VehicleReconciliation',
      );

      return const Right(null);
    } catch (e) {
      developer.log(
        '❌ Vehicle reconciliation failed: $e',
        name: 'VehicleReconciliation',
      );
      return Left(CacheFailure('Failed to reconcile vehicle ID: $e'));
    }
  }

  /// Atualiza referências de veículo em outras entidades
  Future<void> _updateReferences(
    String oldVehicleId,
    String newVehicleId,
  ) async {
    try {
      // Update fuel records
      final fuelResult = await _localStorage.getValues<Map<String, dynamic>>(
        box: 'fuel_records',
      );

      fuelResult.fold((_) {}, (records) {
        for (final record in records) {
          if (record['vehicle_id'] == oldVehicleId) {
            record['vehicle_id'] = newVehicleId;
            _localStorage.save<Map<String, dynamic>>(
              key: record['id'] as String,
              data: record,
              box: 'fuel_records',
            );
          }
        }
      });

      // Update maintenance records
      final maintenanceResult = await _localStorage
          .getValues<Map<String, dynamic>>(box: 'maintenance_records');

      maintenanceResult.fold((_) {}, (records) {
        for (final record in records) {
          if (record['vehicle_id'] == oldVehicleId) {
            record['vehicle_id'] = newVehicleId;
            _localStorage.save<Map<String, dynamic>>(
              key: record['id'] as String,
              data: record,
              box: 'maintenance_records',
            );
          }
        }
      });

      developer.log(
        '✅ Updated dependent references for vehicle ID change',
        name: 'VehicleReconciliation',
      );
    } catch (e) {
      developer.log(
        '⚠️ Error updating dependent references: $e',
        name: 'VehicleReconciliation',
      );
    }
  }

  /// Verifica se há reconciliações pendentes
  ///
  /// **Retorna:**
  /// - Right(count): Número de reconciliações pendentes
  /// - Left(failure): Erro ao verificar
  @override
  Future<Either<Failure, int>> getPendingCount() async {
    try {
      // Para veículos, verificamos se há veículos com isDirty = true
      // que não foram sincronizados ainda
      // Por simplicidade, retornamos 0 pois a reconciliação
      // é feita automaticamente durante sync
      return const Right(0);
    } catch (e) {
      developer.log(
        '❌ Error getting pending reconciliation count: $e',
        name: 'VehicleReconciliation',
      );
      return Left(CacheFailure('Failed to get pending count: $e'));
    }
  }
}
