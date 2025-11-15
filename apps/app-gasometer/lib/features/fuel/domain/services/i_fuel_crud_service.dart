import 'package:core/core.dart';
import '../entities/fuel_record_entity.dart';

/// Interface para operações CRUD de combustível
///
/// **Responsabilidades (Single Responsibility):**
/// - Adicionar novos registros de combustível
/// - Atualizar registros existentes
/// - Deletar registros
/// - Apenas operações CRUD diretas, sem lógica complexa
///
/// **Princípio ISP:**
/// - ≤ 5 métodos (apenas CRUD necessários)
/// - Segregado de query e sync operations
///
/// **Exemplo:**
/// ```dart
/// final result = await crudService.addFuel(record);
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (record) => print('Added: ${record.id}'),
/// );
/// ```
abstract class IFuelCrudService {
  /// Adiciona um novo registro de combustível
  Future<Either<Failure, FuelRecordEntity>> addFuel(FuelRecordEntity record);

  /// Atualiza um registro de combustível existente
  Future<Either<Failure, FuelRecordEntity>> updateFuel(FuelRecordEntity record);

  /// Deleta um registro de combustível
  Future<Either<Failure, void>> deleteFuel(String recordId);
}
