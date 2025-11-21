import 'package:equatable/equatable.dart';

/// Classe base abstrata para parâmetros de culturas
abstract class GetCulturasParams extends Equatable {
  const GetCulturasParams();
}

/// Parâmetros para buscar todas as culturas
class GetAllCulturasParams extends GetCulturasParams {
  const GetAllCulturasParams();

  @override
  List<Object?> get props => [];
}

/// Parâmetros para buscar culturas por grupo
class GetCulturasByGrupoParams extends GetCulturasParams {
  final String grupo;

  const GetCulturasByGrupoParams(this.grupo);

  @override
  List<Object?> get props => [grupo];
}

/// Parâmetros para buscar culturas por ID
class GetCulturaByIdParams extends GetCulturasParams {
  final String id;

  const GetCulturaByIdParams(this.id);

  @override
  List<Object?> get props => [id];
}

/// Parâmetros para pesquisar culturas
class SearchCulturasParams extends GetCulturasParams {
  final String query;

  const SearchCulturasParams(this.query);

  @override
  List<Object?> get props => [query];
}

/// Parâmetros para buscar grupos de culturas
class GetGruposCulturasParams extends GetCulturasParams {
  const GetGruposCulturasParams();

  @override
  List<Object?> get props => [];
}
