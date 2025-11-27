import 'package:core/core.dart';
import '../../../features/fuel/domain/entities/fuel_record_entity.dart';

/// Interface para operações CRUD de combustível
/// 
/// Segregada conforme ISP - apenas responsável por Create/Update/Delete
/// Não inclui queries ou sincronização
abstract class IFuelCrudService {
  /// Adiciona novo registro de abastecimento
  Future<Either<Failure, void>> addFuel(FuelRecordEntity record);

  /// Atualiza registro de abastecimento existente
  Future<Either<Failure, void>> updateFuel(FuelRecordEntity record);

  /// Deleta registro de abastecimento
  Future<Either<Failure, void>> deleteFuel(String fuelId);

  /// Marca registro como pendente de sincronização
  Future<Either<Failure, void>> markPending(String fuelId);
}
