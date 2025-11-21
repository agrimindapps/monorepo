import 'package:equatable/equatable.dart';

/// Parâmetros para queries de defensivos
/// Consolidação de 7 usecases em 1 genérico
abstract class GetDefensivosParams extends Equatable {
  const GetDefensivosParams();

  @override
  List<Object?> get props => [];
}

/// Busca todos os defensivos
class GetAllDefensivosParams extends GetDefensivosParams {
  const GetAllDefensivosParams();
}

/// Busca defensivos por classe
class GetDefensivosByClasseParams extends GetDefensivosParams {
  final String classe;

  const GetDefensivosByClasseParams(this.classe);

  @override
  List<Object?> get props => [classe];
}

/// Busca defensivos por texto (search)
class SearchDefensivosParams extends GetDefensivosParams {
  final String query;

  const SearchDefensivosParams(this.query);

  @override
  List<Object?> get props => [query];
}

/// Busca defensivos recentes
class GetDefensivosRecentesParams extends GetDefensivosParams {
  final int limit;

  const GetDefensivosRecentesParams({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Busca estatísticas
class GetDefensivosStatsParams extends GetDefensivosParams {
  const GetDefensivosStatsParams();
}

/// Busca classes agronômicas
class GetClassesAgronomicasParams extends GetDefensivosParams {
  const GetClassesAgronomicasParams();
}

/// Busca fabricantes
class GetFabricantesParams extends GetDefensivosParams {
  const GetFabricantesParams();
}

/// Resultado genérico para qualquer tipo de busca
class GetDefensivosResult {
  final List<dynamic> data;
  final String type; // 'defensivos', 'stats', 'classes', 'fabricantes'

  GetDefensivosResult({required this.data, required this.type});
}
