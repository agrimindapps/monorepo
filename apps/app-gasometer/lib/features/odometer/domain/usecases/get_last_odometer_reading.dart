import 'package:core/core.dart';

import '../entities/odometer_entity.dart';
import '../repositories/odometer_repository.dart';

/// UseCase para buscar a última leitura de odômetro de um veículo
///
/// Responsável por:
/// - Buscar a leitura mais recente de um veículo
/// - Retornar null se não houver leituras

class GetLastOdometerReadingUseCase
    implements UseCase<OdometerEntity?, String> {
  const GetLastOdometerReadingUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, OdometerEntity?>> call(String vehicleId) async {
    try {
      if (vehicleId.trim().isEmpty) {
        return const Left(ValidationFailure('ID do veículo é obrigatório'));
      }

      final result = await _repository.getLastOdometerReading(vehicleId);
      return result.fold(
        (failure) => Left(failure),
        (lastReading) => Right(lastReading),
      );
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar última leitura: ${e.toString()}'),
      );
    }
  }
}
