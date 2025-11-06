import 'package:core/core.dart';

import '../repositories/odometer_repository.dart';
import '../entities/odometer_entity.dart';

/// UseCase para encontrar leituras de odômetro duplicadas
///
/// Responsável por:
/// - Detectar leituras potencialmente duplicadas
/// - Considerar mesma veículo, valores próximos e datas próximas
/// - Retornar lista de duplicatas para revisão
@injectable
class FindDuplicateOdometerReadingsUseCase
    implements UseCase<List<OdometerEntity>, NoParams> {
  const FindDuplicateOdometerReadingsUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, List<OdometerEntity>>> call(NoParams params) async {
    try {
      final result = await _repository.findDuplicates();
      return result.fold(
        (failure) => Left(failure),
        (duplicates) => Right(duplicates),
      );
    } catch (e) {
      return Left(UnknownFailure('Erro ao buscar duplicatas: ${e.toString()}'));
    }
  }
}
