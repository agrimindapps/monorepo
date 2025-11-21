import 'package:equatable/equatable.dart';
import '../entities/busca_entity.dart';

/// Parâmetros para queries de busca avançada
/// Consolida 7 usecases em 1 genérico
abstract class BuscaParams extends Equatable {
  const BuscaParams();

  @override
  List<Object?> get props => [];
}

/// Busca com filtros avançados
class BuscarComFiltrosParams extends BuscaParams {
  final BuscaFiltersEntity filters;

  const BuscarComFiltrosParams(this.filters);

  @override
  List<Object?> get props => [filters];
}

/// Busca por texto simples
class BuscarPorTextoParams extends BuscaParams {
  final String query;
  final List<String>? tipos;
  final int? limit;

  const BuscarPorTextoParams({required this.query, this.tipos, this.limit});

  @override
  List<Object?> get props => [query, tipos, limit];
}

/// Carrega metadados de busca
class GetBuscaMetadosParams extends BuscaParams {
  const GetBuscaMetadosParams();
}

/// Carrega sugestões
class GetSugestoesParams extends BuscaParams {
  final int limit;

  const GetSugestoesParams({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Busca diagnósticos com filtros específicos
class BuscarDiagnosticosParams extends BuscaParams {
  final String? culturaId;
  final String? pragaId;
  final String? defensivoId;

  const BuscarDiagnosticosParams({
    this.culturaId,
    this.pragaId,
    this.defensivoId,
  });

  @override
  List<Object?> get props => [culturaId, pragaId, defensivoId];
}

/// Carrega histórico de buscas
class GetHistoricoBuscaParams extends BuscaParams {
  final int limit;

  const GetHistoricoBuscaParams({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

/// Limpa cache de busca
class LimparCacheBuscaParams extends BuscaParams {
  const LimparCacheBuscaParams();
}
