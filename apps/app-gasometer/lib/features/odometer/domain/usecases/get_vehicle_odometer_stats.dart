import 'package:core/core.dart';

import '../../data/repositories/odometer_repository.dart';

/// UseCase para buscar estatísticas de odômetro de um veículo
///
/// Responsável por:
/// - Buscar total de registros
/// - Calcular odômetro atual
/// - Identificar primeira e última leitura
/// - Calcular distância total percorrida
@injectable
class GetVehicleOdometerStatsUseCase implements UseCase<Map<String, dynamic>, String> {
  const GetVehicleOdometerStatsUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String vehicleId) async {
    try {
      final stats = await _repository.getVehicleStats(vehicleId);
      return Right(stats);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar estatísticas do veículo: ${e.toString()}'),
      );
    }
  }
}
