import 'package:core/core.dart';

import '../../data/repositories/odometer_repository.dart';
import '../entities/odometer_entity.dart';

/// UseCase para buscar todas as leituras de odômetro
///
/// Responsável por:
/// - Buscar todas as leituras não-deletadas
/// - Retornar ordenadas por data (mais recente primeiro)
/// - Utilizar cache quando disponível
@injectable
class GetAllOdometerReadingsUseCase implements UseCase<List<OdometerEntity>, NoParams> {
  const GetAllOdometerReadingsUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, List<OdometerEntity>>> call(NoParams params) async {
    try {
      final readings = await _repository.getAllOdometerReadings();

      // Ordenar por data (mais recente primeiro)
      readings.sort((a, b) => b.registrationDate.compareTo(a.registrationDate));

      return Right(readings);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar leituras de odômetro: ${e.toString()}'),
      );
    }
  }
}
