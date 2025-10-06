import 'package:core/core.dart';

import '../entities/defensivo_entity.dart';
import '../repositories/i_defensivos_repository.dart';

/// Use case para obter defensivos com filtros avançados
/// Aplica princípio de responsabilidade única (SRP)
class GetDefensivosComFiltrosUseCase {
  final IDefensivosRepository _repository;

  const GetDefensivosComFiltrosUseCase(this._repository);

  /// Executa busca de defensivos com filtros específicos
  Future<Either<Failure, List<DefensivoEntity>>> call({
    String? ordenacao,
    String? filtroToxicidade,
    String? filtroTipo,
    bool apenasComercializados = false,
    bool apenasElegiveis = false,
  }) async {
    return await _repository.getDefensivosComFiltros(
      ordenacao: ordenacao,
      filtroToxicidade: filtroToxicidade,
      filtroTipo: filtroTipo,
      apenasComercializados: apenasComercializados,
      apenasElegiveis: apenasElegiveis,
    );
  }
}
