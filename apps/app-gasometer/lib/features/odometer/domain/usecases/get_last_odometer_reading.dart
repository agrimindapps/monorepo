import 'package:core/core.dart';

import '../../data/repositories/odometer_repository.dart';
import '../entities/odometer_entity.dart';

/// UseCase para buscar a última leitura de odômetro de um veículo
///
/// Responsável por:
/// - Buscar a leitura mais recente de um veículo
/// - Retornar null se não houver leituras
@injectable
class GetLastOdometerReadingUseCase implements UseCase<OdometerEntity?, String> {
  const GetLastOdometerReadingUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, OdometerEntity?>> call(String vehicleId) async {
    try {
      if (vehicleId.trim().isEmpty) {
        return const Left(
          ValidationFailure('ID do veículo é obrigatório'),
        );
      }

      final lastReading = await _repository.getLastOdometerReading(vehicleId);

      return Right(lastReading);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar última leitura: ${e.toString()}'),
      );
    }
  }
}
