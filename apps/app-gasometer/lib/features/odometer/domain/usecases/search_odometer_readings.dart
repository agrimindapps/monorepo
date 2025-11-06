import 'package:core/core.dart';

import '../repositories/odometer_repository.dart';
import '../entities/odometer_entity.dart';

/// UseCase para buscar leituras de odômetro por texto
///
/// Responsável por:
/// - Buscar leituras que contenham o texto na descrição
/// - Retornar ordenadas por data (mais recente primeiro)
/// - Filtrar registros deletados
@injectable
class SearchOdometerReadingsUseCase
    implements UseCase<List<OdometerEntity>, String> {
  const SearchOdometerReadingsUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, List<OdometerEntity>>> call(String query) async {
    try {
      final result = await _repository.searchOdometerReadings(query);
      return result.fold(
        (failure) => Left(failure),
        (readings) => Right(readings),
      );
    } catch (e) {
      return Left(UnknownFailure('Erro ao buscar leituras: ${e.toString()}'));
    }
  }
}
