import 'package:core/core.dart';

import '../../data/repositories/odometer_repository.dart';
import '../entities/odometer_entity.dart';

/// UseCase para encontrar leituras de odômetro duplicadas
///
/// Responsável por:
/// - Detectar leituras potencialmente duplicadas
/// - Considerar mesma veículo, valores próximos e datas próximas
/// - Retornar lista de duplicatas para revisão
@injectable
class FindDuplicateOdometerReadingsUseCase implements UseCase<List<OdometerEntity>, NoParams> {
  const FindDuplicateOdometerReadingsUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, List<OdometerEntity>>> call(NoParams params) async {
    try {
      final duplicates = await _repository.findDuplicates();
      return Right(duplicates);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar duplicatas: ${e.toString()}'),
      );
    }
  }
}
