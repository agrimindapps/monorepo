// Project imports:
import '../../../repository/espaco_repository.dart';

/// Serviço para estatísticas e relatórios de Espaços
/// Responsabilidade: Processamento de estatísticas e métricas
class EspacoStatisticsService {
  static EspacoStatisticsService? _instance;
  static EspacoStatisticsService get instance =>
      _instance ??= EspacoStatisticsService._();

  final EspacoRepository _repository = EspacoRepository.instance;

  EspacoStatisticsService._();

  /// Obter estatísticas básicas dos espaços
  Future<EspacoStatistics> getBasicStatistics() async {
    final espacos = await _repository.findAll();

    int active = 0;
    int inactive = 0;
    DateTime? oldestCreation;
    DateTime? newestCreation;

    for (final espaco in espacos) {
      if (espaco.ativo) {
        active++;
      } else {
        inactive++;
      }

      final createdAt = espaco.dataCriacao;
      if (createdAt != null) {
        if (oldestCreation == null || createdAt.isBefore(oldestCreation)) {
          oldestCreation = createdAt;
        }
        if (newestCreation == null || createdAt.isAfter(newestCreation)) {
          newestCreation = createdAt;
        }
      }
    }

    return EspacoStatistics(
      total: espacos.length,
      active: active,
      inactive: inactive,
      oldestCreation: oldestCreation,
      newestCreation: newestCreation,
    );
  }

  /// Obter distribuição de espaços por status
  Future<Map<String, int>> getStatusDistribution() async {
    final stats = await getBasicStatistics();
    return {
      'ativos': stats.active,
      'inativos': stats.inactive,
    };
  }

  /// Obter estatísticas de uso por período
  Future<Map<String, dynamic>> getUsageStatsByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final espacos = await _repository.findAll();

    final createdInPeriod = espacos.where((espaco) {
      final createdAt = espaco.dataCriacao;
      return createdAt != null &&
          createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
          createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).length;

    return {
      'espacosCreatedInPeriod': createdInPeriod,
      'totalEspacos': espacos.length,
      'percentageOfTotal':
          espacos.isEmpty ? 0.0 : (createdInPeriod / espacos.length) * 100,
    };
  }

  /// Obter ranking de espaços por nome (alfabético)
  Future<List<Map<String, dynamic>>> getAlphabeticalRanking() async {
    final espacos = await _repository.findAtivos();
    espacos.sort((a, b) => a.nome.compareTo(b.nome));

    return espacos
        .map((espaco) => {
              'id': espaco.id,
              'nome': espaco.nome,
              'descricao': espaco.descricao,
              'dataCriacao': espaco.dataCriacao,
            })
        .toList();
  }
}

/// Classe para encapsular estatísticas de espaços
class EspacoStatistics {
  final int total;
  final int active;
  final int inactive;
  final DateTime? oldestCreation;
  final DateTime? newestCreation;

  const EspacoStatistics({
    required this.total,
    required this.active,
    required this.inactive,
    this.oldestCreation,
    this.newestCreation,
  });

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'oldestCreation': oldestCreation?.millisecondsSinceEpoch,
      'newestCreation': newestCreation?.millisecondsSinceEpoch,
    };
  }
}
