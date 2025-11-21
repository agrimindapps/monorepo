import 'package:equatable/equatable.dart';
import '../entities/pragas_cultura_filter.dart';

/// Parâmetros para buscar pragas por cultura
class GetPragasPorCulturaParams extends Equatable {
  final String culturaId;

  const GetPragasPorCulturaParams({required this.culturaId});

  @override
  List<Object?> get props => [culturaId];
}

/// Parâmetros para filtrar pragas
class FilterPragasParams extends Equatable {
  final List<dynamic> pragas;
  final PragasCulturaFilter filter;

  const FilterPragasParams({
    required this.pragas,
    required this.filter,
  });

  @override
  List<Object?> get props => [pragas, filter];
}

/// Parâmetros para ordenar pragas
class SortPragasParams extends Equatable {
  final List<dynamic> pragas;
  final String sortBy; // 'nome', 'diagnosticos', 'ameaca'

  const SortPragasParams({
    required this.pragas,
    this.sortBy = 'ameaca',
  });

  @override
  List<Object?> get props => [pragas, sortBy];
}

/// Parâmetros para calcular estatísticas
class CalculateStatisticsParams extends Equatable {
  final List<dynamic> pragas;

  const CalculateStatisticsParams({required this.pragas});

  @override
  List<Object?> get props => [pragas];
}
