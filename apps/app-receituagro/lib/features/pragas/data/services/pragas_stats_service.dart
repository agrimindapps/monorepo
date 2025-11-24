

import '../../domain/entities/praga_entity.dart';
import '../../domain/services/i_pragas_stats_service.dart';

/// Default implementation of stats service

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
