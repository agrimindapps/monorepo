import 'package:core/core.dart';

import '../repositories/odometer_repository.dart';
import '../entities/odometer_entity.dart';

/// UseCase para buscar leituras de odômetro por tipo
///
/// Responsável por:
/// - Buscar leituras filtradas por tipo (viagem, manutenção, etc)
/// - Retornar ordenadas por data (mais recente primeiro)
/// - Filtrar registros deletados
@injectable
class GetOdometerReadingsByTypeUseCase
    implements UseCase<List<OdometerEntity>, OdometerType> {
  const GetOdometerReadingsByTypeUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, List<OdometerEntity>>> call(OdometerType type) async {
    try {
      final result = await _repository.getOdometerReadingsByType(type);
      return result.fold(
        (failure) => Left(failure),
        (readings) => Right(readings),
      );
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar leituras por tipo: ${e.toString()}'),
      );
    }
  }
}
