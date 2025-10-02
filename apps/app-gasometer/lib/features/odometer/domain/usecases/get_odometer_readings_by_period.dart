import 'package:core/core.dart';

import '../../data/repositories/odometer_repository.dart';
import '../entities/odometer_entity.dart';

/// Parâmetros para buscar leituras por período
class OdometerPeriodParams {
  const OdometerPeriodParams({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;
}

/// UseCase para buscar leituras de odômetro por período
///
/// Responsável por:
/// - Buscar leituras dentro de um intervalo de datas
/// - Retornar ordenadas por data (mais recente primeiro)
/// - Filtrar registros deletados
@injectable
class GetOdometerReadingsByPeriodUseCase implements UseCase<List<OdometerEntity>, OdometerPeriodParams> {
  const GetOdometerReadingsByPeriodUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, List<OdometerEntity>>> call(OdometerPeriodParams params) async {
    try {
      final readings = await _repository.getOdometerReadingsByPeriod(
        params.startDate,
        params.endDate,
      );
      return Right(readings);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar leituras por período: ${e.toString()}'),
      );
    }
  }
}
