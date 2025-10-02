import 'package:core/core.dart';

import '../../data/repositories/odometer_repository.dart';
import '../entities/odometer_entity.dart';

/// UseCase para buscar leituras de odômetro por texto
///
/// Responsável por:
/// - Buscar leituras que contenham o texto na descrição
/// - Retornar ordenadas por data (mais recente primeiro)
/// - Filtrar registros deletados
@injectable
class SearchOdometerReadingsUseCase implements UseCase<List<OdometerEntity>, String> {
  const SearchOdometerReadingsUseCase(this._repository);

  final OdometerRepository _repository;

  @override
  Future<Either<Failure, List<OdometerEntity>>> call(String query) async {
    try {
      final readings = await _repository.searchOdometerReadings(query);
      return Right(readings);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro ao buscar leituras: ${e.toString()}'),
      );
    }
  }
}
