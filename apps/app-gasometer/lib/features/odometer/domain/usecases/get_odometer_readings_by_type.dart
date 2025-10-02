import 'package:core/core.dart';

import '../../data/repositories/odometer_repository.dart';
import '../entities/odometer_entity.dart';

/// UseCase para buscar leituras de odômetro por tipo
///
/// Responsável por:
/// - Buscar leituras filtradas por tipo (viagem, manutenção, etc)
/// - Retornar ordenadas por data (mais recente primeiro)
/// - Filtrar registros deletados
@injectable
class GetOdometerReadingsByTypeUseCase implements UseCase<List<OdometerEntity>, OdometerType> {
  const GetOdometerReadingsByTypeUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, List<OdometerEntity>>> call(OdometerType type) async {
    try {
      final readings = await _repository.getOdometerReadingsByType(type);
      return Right(readings);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar leituras por tipo: ${e.toString()}'),
      );
    }
  }
}
