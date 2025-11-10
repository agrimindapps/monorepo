import 'package:core/core.dart' hide Column;

import '../entities/diagnostico_entity.dart';
import '../services/search/i_diagnosticos_search_service.dart';

/// Use Case para buscar diagnósticos com filtros
/// Responsabilidade única: Orquestrar busca com filtros
@injectable
class SearchDiagnosticosUseCase {
  final IDiagnosticosSearchService _searchService;

  const SearchDiagnosticosUseCase(this._searchService);

  /// Busca diagnósticos usando filtros estruturados
  ///
  /// Parâmetros:
  /// - [filters]: Objeto com critérios de filtro (defensivo, cultura, praga, etc)
  ///
  /// Retorna: Either com List&lt;DiagnosticoEntity&gt; ou Failure
  Future<Either<Failure, List<DiagnosticoEntity>>> call(
    DiagnosticoSearchFilters filters,
  ) async {
    try {
      return await _searchService.searchWithFilters(filters);
    } catch (e) {
      return Left(
        CacheFailure(
          'Erro ao buscar diagnósticos com filtros: ${e.toString()}',
        ),
      );
    }
  }

  /// Busca diagnósticos por padrão de texto
  ///
  /// Parâmetros:
  /// - [pattern]: Texto para buscar (será procurado em defensivo, cultura, praga)
  ///
  /// Retorna: Either com List&lt;DiagnosticoEntity&gt; ou Failure
  Future<Either<Failure, List<DiagnosticoEntity>>> searchByPattern(
    String pattern,
  ) async {
    try {
      if (pattern.isEmpty) {
        return const Left(CacheFailure('Padrão de busca não pode estar vazio'));
      }

      return await _searchService.searchByPattern(pattern);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao buscar diagnósticos por padrão: ${e.toString()}'),
      );
    }
  }
}
