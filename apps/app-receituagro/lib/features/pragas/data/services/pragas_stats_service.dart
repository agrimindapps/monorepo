import 'package:injectable/injectable.dart';

import '../../domain/entities/praga_entity.dart';

/// Service responsible for calculating statistics from pragas.
///
/// This service encapsulates statistics calculation logic, separating it from
/// the repository to improve Single Responsibility Principle (SRP) compliance.
///
/// Responsibilities:
/// - Calculate total count of pragas
/// - Count pragas by tipo (inseto, doença, planta)
/// - Count distinct famílias
/// - Generate comprehensive stats maps
abstract class IPragasStatsService {
  /// Calculate comprehensive statistics for pragas
  Map<String, int> calculateStats(List<PragaEntity> pragas);

  /// Get count of pragas by specific tipo
  int getCountByTipo(List<PragaEntity> pragas, String tipo);

  /// Get total count of pragas
  int getTotalCount(List<PragaEntity> pragas);

  /// Get count of distinct famílias
  int getFamiliasCount(List<PragaEntity> pragas);
}

/// Default implementation of stats service
@LazySingleton(as: IPragasStatsService)
class PragasStatsService implements IPragasStatsService {
  @override
  Map<String, int> calculateStats(List<PragaEntity> pragas) {
    return {
      'total': getTotalCount(pragas),
      'insetos': _countByTipoPraga(pragas, '1'),
      'doencas': _countByTipoPraga(pragas, '2'),
      'plantas': _countByTipoPraga(pragas, '3'),
      'familias': getFamiliasCount(pragas),
    };
  }

  @override
  int getCountByTipo(List<PragaEntity> pragas, String tipo) {
    if (tipo.isEmpty) {
      return 0;
    }
    return pragas.where((p) => p.tipoPraga == tipo).length;
  }

  @override
  int getTotalCount(List<PragaEntity> pragas) {
    return pragas.length;
  }

  @override
  int getFamiliasCount(List<PragaEntity> pragas) {
    return pragas
        .map((p) => p.familia)
        .where((f) => f != null && f.isNotEmpty)
        .toSet()
        .length;
  }

  /// Get count of pragas by tipo praga (1=inseto, 2=doença, 3=planta)
  int _countByTipoPraga(List<PragaEntity> pragas, String tipo) {
    return pragas.where((p) => p.tipoPraga == tipo).length;
  }
}
