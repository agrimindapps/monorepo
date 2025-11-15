import 'dart:developer' as developer;

import 'package:core/core.dart';

import 'data_integrity_facade.dart';

/// Service responsável por garantir integridade de dados durante sincronização
///
/// Principais responsabilidades:
/// - Delega ID Reconciliation para DataIntegrityFacade
/// - Auditoria de operações críticas
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
/// 4. Delega para DataIntegrityFacade que gerencia as 3 reconciliações
/// 5. Atualiza referências (ex: FuelRecord.vehicleId)
class DataIntegrityService {
  DataIntegrityService(this._facade);

  final DataIntegrityFacade _facade;

  /// Reconcilia ID local com ID remoto de veículo
  ///
  /// **Quando usar:**
  /// - Após criar entidade localmente e sincronizar com Firebase
  /// - Quando Firebase retorna ID diferente do local
  ///
  /// **Delega para:** DataIntegrityFacade.reconcileVehicleId()
  Future<Either<Failure, void>> reconcileVehicleId(
    String localId,
    String remoteId,
  ) async {
    try {
      developer.log(
        '🔄 ID Reconciliation - Vehicle (delegating to facade)',
        name: 'DataIntegrity',
      );

      return await _facade.reconcileVehicleId(localId, remoteId);
    } catch (e) {
      developer.log(
        '❌ ID Reconciliation failed: $e',
        name: 'DataIntegrity',
      );
      return Left(CacheFailure('Failed to reconcile vehicle ID: $e'));
    }
  }

  /// Reconcilia ID de FuelRecord (operação crítica - dados financeiros)
  ///
  /// **Delega para:** DataIntegrityFacade.reconcileFuelSupplyId()
  Future<Either<Failure, void>> reconcileFuelRecordId(
    String localId,
    String remoteId,
  ) async {
    try {
      developer.log(
        '🔄 ID Reconciliation - FuelRecord (delegating to facade)',
        name: 'DataIntegrity',
      );

      return await _facade.reconcileFuelSupplyId(localId, remoteId);
    } catch (e) {
      developer.log(
        '❌ ID Reconciliation failed (FuelRecord): $e',
        name: 'DataIntegrity',
      );
      return Left(CacheFailure('Failed to reconcile fuel record ID: $e'));
    }
  }

  /// Reconcilia ID de Maintenance (operação crítica - dados financeiros)
  ///
  /// **Delega para:** DataIntegrityFacade.reconcileMaintenanceId()
  Future<Either<Failure, void>> reconcileMaintenanceId(
    String localId,
    String remoteId,
  ) async {
    try {
      developer.log(
        '🔄 ID Reconciliation - Maintenance (delegating to facade)',
        name: 'DataIntegrity',
      );

      return await _facade.reconcileMaintenanceId(localId, remoteId);
    } catch (e) {
      developer.log(
        '❌ ID Reconciliation failed (Maintenance): $e',
        name: 'DataIntegrity',
      );
      return Left(CacheFailure('Failed to reconcile maintenance ID: $e'));
    }
  }

  /// Verifica integridade de dados após sincronização
  ///
  /// **Validações:**
  /// - Sem registros órfãos
  /// - Sem duplicações de ID
  /// - Valores financeiros consistentes
  ///
  /// **Delega para:** DataIntegrityFacade.verifyDataIntegrity()
  Future<Either<Failure, Map<String, dynamic>>> verifyDataIntegrity() async {
    try {
      developer.log(
        '🔍 Starting data integrity verification (delegating to facade)',
        name: 'DataIntegrity',
      );

      return await _facade.verifyDataIntegrity();
    } catch (e) {
      developer.log(
        '❌ Data integrity verification failed: $e',
        name: 'DataIntegrity',
      );
      return Left(CacheFailure('Failed to verify data integrity: $e'));
    }
  }
}
