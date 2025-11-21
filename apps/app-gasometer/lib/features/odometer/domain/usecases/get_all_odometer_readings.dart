import 'package:core/core.dart';

import '../entities/odometer_entity.dart';
import '../repositories/odometer_repository.dart';

/// UseCase para buscar todas as leituras de odômetro
///
/// Responsável por:
/// - Buscar todas as leituras não-deletadas
/// - Retornar ordenadas por data (mais recente primeiro)
/// - Utilizar cache quando disponível

class GetAllOdometerReadingsUseCase
    implements UseCase<List<OdometerEntity>, NoParams> {
  const GetAllOdometerReadingsUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, List<OdometerEntity>>> call(NoParams params) async {
    try {
      final result = await _repository.getAllOdometerReadings();
      return result.fold((failure) => Left(failure), (readings) {
        readings.sort(
          (a, b) => b.registrationDate.compareTo(a.registrationDate),
        );
        return Right(readings);
      });
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar leituras de odômetro: ${e.toString()}'),
      );
    }
  }
}
