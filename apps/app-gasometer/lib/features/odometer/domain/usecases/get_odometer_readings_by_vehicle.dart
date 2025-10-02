import 'package:core/core.dart';

import '../../data/repositories/odometer_repository.dart';
import '../entities/odometer_entity.dart';

/// UseCase para buscar leituras de odômetro por veículo
///
/// Responsável por:
/// - Buscar leituras de um veículo específico
/// - Retornar ordenadas por data (mais recente primeiro)
/// - Utilizar cache quando disponível
@injectable
class GetOdometerReadingsByVehicleUseCase implements UseCase<List<OdometerEntity>, String> {
  const GetOdometerReadingsByVehicleUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, List<OdometerEntity>>> call(String vehicleId) async {
    try {
      if (vehicleId.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID do veículo é obrigatório'),
        );
      }

      final readings = await _repository.getOdometerReadingsByVehicle(vehicleId);

      // As leituras já vêm ordenadas do repositório
      return Right(readings);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar leituras do veículo: ${e.toString()}'),
      );
    }
  }
}
