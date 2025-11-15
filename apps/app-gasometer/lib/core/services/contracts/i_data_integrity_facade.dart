import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

/// Interface para operações de reconciliação de IDs
/// 
/// Segregada conforme ISP - apenas responsável por reconciliação
abstract class IDataIntegrityFacade {
  /// Reconcilia ID de veículo (local vs remoto)
  Future<Either<Failure, void>> reconcileVehicleId(
    String localId,
    String remoteId,
  );

  /// Reconcilia ID de abastecimento (local vs remoto)
  Future<Either<Failure, void>> reconcileFuelSupplyId(
    String localId,
    String remoteId,
  );

  /// Reconcilia ID de manutenção (local vs remoto)
  Future<Either<Failure, void>> reconcileMaintenanceId(
    String localId,
    String remoteId,
  );

  /// Verifica integridade de dados
  Future<Either<Failure, Map<String, dynamic>>> verifyDataIntegrity();
}
