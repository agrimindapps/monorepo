import 'package:core/core.dart' hide Column;

import '../entities/defensivo_entity.dart';
import '../repositories/i_defensivos_repository.dart';

/// Use case para obter defensivos agrupados por categoria
/// Aplica princípio de responsabilidade única (SRP)
@injectable
class GetDefensivosAgrupadosUseCase {
  final IDefensivosRepository _repository;

  const GetDefensivosAgrupadosUseCase(this._repository);

  /// Executa busca de defensivos agrupados por tipo
  Future<Either<Failure, List<DefensivoEntity>>> call({
    required String tipoAgrupamento,
    String? filtroTexto,
  }) async {
    return await _repository.getDefensivosAgrupados(
      tipoAgrupamento: tipoAgrupamento,
      filtroTexto: filtroTexto,
    );
  }
}
