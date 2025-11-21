import 'package:equatable/equatable.dart';

/// Parâmetros para queries de pragas
/// Consolida 7 usecases em 1 genérico
abstract class GetPragasParams extends Equatable {
  const GetPragasParams();

  @override
  List<Object?> get props => [];
}

/// Busca todas as pragas
class GetAllPragasParams extends GetPragasParams {
  const GetAllPragasParams();
}

/// Busca pragas por tipo (inseto, doença, planta)
class GetPragasByTipoParams extends GetPragasParams {
  final String tipo;

  const GetPragasByTipoParams(this.tipo);

  @override
  List<Object?> get props => [tipo];
}

/// Busca praga por ID
class GetPragaByIdParams extends GetPragasParams {
  final String id;

  const GetPragaByIdParams(this.id);

  @override
  List<Object?> get props => [id];
}

/// Busca pragas de uma cultura específica
class GetPragasByCulturaParams extends GetPragasParams {
  final String culturaId;

  const GetPragasByCulturaParams(this.culturaId);

  @override
  List<Object?> get props => [culturaId];
}

/// Pesquisa pragas por nome
class SearchPragasParams extends GetPragasParams {
  final String searchTerm;

  const SearchPragasParams(this.searchTerm);

  @override
  List<Object?> get props => [searchTerm];
}

/// Busca pragas recentes (histórico de acesso)
class GetRecentPragasParams extends GetPragasParams {
  final int? limit;

  const GetRecentPragasParams({this.limit});

  @override
  List<Object?> get props => [limit];
}

/// Busca pragas sugeridas
class GetSuggestedPragasParams extends GetPragasParams {
  final int limit;

  const GetSuggestedPragasParams({this.limit = 5});

  @override
  List<Object?> get props => [limit];
}

/// Busca estatísticas de pragas
class GetPragasStatsParams extends GetPragasParams {
  const GetPragasStatsParams();
}
