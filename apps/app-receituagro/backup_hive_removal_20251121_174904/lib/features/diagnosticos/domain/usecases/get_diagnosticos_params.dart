import 'package:equatable/equatable.dart';

import '../entities/diagnostico_entity.dart';

/// Classe base abstrata para parâmetros de diagnósticos
abstract class GetDiagnosticosParams extends Equatable {
  const GetDiagnosticosParams();
}

/// Parâmetros para buscar todos os diagnósticos com paginação
class GetAllDiagnosticosParams extends GetDiagnosticosParams {
  final int? limit;
  final int? offset;

  const GetAllDiagnosticosParams({this.limit, this.offset});

  @override
  List<Object?> get props => [limit, offset];
}

/// Parâmetros para buscar diagnóstico por ID
class GetDiagnosticoByIdParams extends GetDiagnosticosParams {
  final String id;

  const GetDiagnosticoByIdParams(this.id);

  @override
  List<Object?> get props => [id];
}

/// Parâmetros para buscar recomendações por cultura e praga
class GetRecomendacoesParams extends GetDiagnosticosParams {
  final String idCultura;
  final String idPraga;
  final int limit;

  const GetRecomendacoesParams({
    required this.idCultura,
    required this.idPraga,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [idCultura, idPraga, limit];
}

/// Parâmetros para buscar diagnósticos por defensivo
class GetDiagnosticosByDefensivoParams extends GetDiagnosticosParams {
  final String idDefensivo;

  const GetDiagnosticosByDefensivoParams(this.idDefensivo);

  @override
  List<Object?> get props => [idDefensivo];
}

/// Parâmetros para buscar diagnósticos por cultura
class GetDiagnosticosByCulturaParams extends GetDiagnosticosParams {
  final String idCultura;

  const GetDiagnosticosByCulturaParams(this.idCultura);

  @override
  List<Object?> get props => [idCultura];
}

/// Parâmetros para buscar diagnósticos por praga
class GetDiagnosticosByPragaParams extends GetDiagnosticosParams {
  final String idPraga;

  const GetDiagnosticosByPragaParams(this.idPraga);

  @override
  List<Object?> get props => [idPraga];
}

/// Parâmetros para busca com filtros complexos
class SearchDiagnosticosWithFiltersParams extends GetDiagnosticosParams {
  final DiagnosticoSearchFilters filters;

  const SearchDiagnosticosWithFiltersParams(this.filters);

  @override
  List<Object?> get props => [filters];
}

/// Parâmetros para obter estatísticas de diagnósticos
class GetDiagnosticoStatsParams extends GetDiagnosticosParams {
  const GetDiagnosticoStatsParams();

  @override
  List<Object?> get props => [];
}

/// Parâmetros para validar compatibilidade
class ValidateCompatibilidadeParams extends GetDiagnosticosParams {
  final String idDefensivo;
  final String idCultura;
  final String idPraga;

  const ValidateCompatibilidadeParams({
    required this.idDefensivo,
    required this.idCultura,
    required this.idPraga,
  });

  @override
  List<Object?> get props => [idDefensivo, idCultura, idPraga];
}

/// Parâmetros para buscar por padrão
class SearchDiagnosticosByPatternParams extends GetDiagnosticosParams {
  final String pattern;

  const SearchDiagnosticosByPatternParams(this.pattern);

  @override
  List<Object?> get props => [pattern];
}

/// Parâmetros para obter dados de filtros
class GetDiagnosticoFiltersDataParams extends GetDiagnosticosParams {
  const GetDiagnosticoFiltersDataParams();

  @override
  List<Object?> get props => [];
}
