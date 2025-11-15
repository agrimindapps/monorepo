import 'package:core/core.dart';
import '../entities/fuel_record_entity.dart';

/// Interface para operações de consulta e filtragem de combustível
///
/// **Responsabilidades (Single Responsibility):**
/// - Carregar todos os registros
/// - Filtrar registros por veículo
/// - Buscar/pesquisar registros
/// - Apenas operações de leitura, sem modificações
///
/// **Princípio ISP:**
/// - ≤ 5 métodos (apenas queries necessárias)
/// - Segregado de CRUD e sync operations
///
/// **Exemplo:**
/// ```dart
/// final result = await queryService.loadAllRecords();
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (records) => print('Loaded ${records.length} records'),
/// );
/// ```
abstract class IFuelQueryService {
  /// Carrega todos os registros de combustível
  Future<Either<Failure, List<FuelRecordEntity>>> loadAllRecords({
    bool forceRefresh = false,
  });

  /// Filtra registros por ID de veículo
  Future<Either<Failure, List<FuelRecordEntity>>> filterByVehicle(String vehicleId);
}
