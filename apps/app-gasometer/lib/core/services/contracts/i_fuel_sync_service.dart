import 'package:core/core.dart';
import '../../../features/fuel/domain/entities/fuel_record_entity.dart';

/// Interface para sincronização de combustível
/// 
/// Segregada conforme ISP - apenas responsável por operações de sync
abstract class IFuelSyncService {
  /// Sincroniza registros pendentes
  Future<Either<Failure, void>> syncPendingRecords();

  /// Obtém registros pendentes de sincronização
  Future<Either<Failure, List<FuelRecordEntity>>> getPendingRecords();

  /// Marca registro como sincronizado
  Future<Either<Failure, void>> markAsSynced(String fuelId);
}
