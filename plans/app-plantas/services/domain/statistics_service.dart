// Project imports:
import '../../repository/espaco_repository.dart';
import '../../repository/planta_repository.dart';
import '../../repository/tarefa_repository.dart';
import 'plants/planta_statistics_service.dart';
import 'spaces/espaco_statistics_service.dart';
import 'tasks/tarefa_statistics_service.dart';

/// Serviço centralizado para todas as estatísticas
/// Responsabilidade: Centralizar e coordenar estatísticas de todos os domínios
class StatisticsService {
  static StatisticsService? _instance;
  static StatisticsService get instance => _instance ??= StatisticsService._();

  final EspacoRepository _espacoRepository = EspacoRepository.instance;
  final PlantaRepository _plantaRepository = PlantaRepository.instance;
  final TarefaRepository _tarefaRepository = TarefaRepository.instance;

  final EspacoStatisticsService _espacoStats = EspacoStatisticsService.instance;
  final PlantaStatisticsService _plantaStats = PlantaStatisticsService.instance;
  final TarefaStatisticsService _tarefaStats = TarefaStatisticsService.instance;

  StatisticsService._();

  /// Obter estatísticas básicas dos espaços (método moved from repository)
  Future<Map<String, int>> getEspacoStatistics() async {
    final espacos = await _espacoRepository.findAll();

    int ativos = 0;
    int inativos = 0;

    for (final espaco in espacos) {
      if (espaco.ativo) {
        ativos++;
      } else {
        inativos++;
      }
    }

    return {
      'total': espacos.length,
      'ativos': ativos,
      'inativos': inativos,
    };
  }

  /// Obter estatísticas básicas das plantas (método moved from repository)
  Future<Map<String, int>> getPlantaStatistics() async {
    // Usa o método otimizado do PlantaRepository que já usa QueryOptimizer
    return await _plantaRepository.getEstatisticas();
  }

  /// Obter estatísticas básicas das tarefas (método moved from repository)
  Future<Map<String, int>> getTarefaStatistics() async {
    // Usa o método otimizado do TarefaRepository que já usa QueryOptimizer
    return await _tarefaRepository.getEstatisticas();
  }

  /// Obter estatísticas completas (dashboard principal)
  Future<ApplicationStatistics> getCompleteStatistics() async {
    final espacoStats = await _espacoStats.getBasicStatistics();
    final plantaStats = await _plantaStats.getCompleteStatistics();
    final tarefaStats = await _tarefaStats.getCompleteStatistics();

    return ApplicationStatistics(
      espacos: espacoStats,
      plantas: plantaStats,
      tarefas: tarefaStats,
      timestamp: DateTime.now(),
    );
  }

  /// Obter estatísticas resumidas para widgets
  Future<Map<String, dynamic>> getSummaryStatistics() async {
    final espacoBasic = await getEspacoStatistics();
    final plantaBasic = await getPlantaStatistics();
    final tarefaBasic = await getTarefaStatistics();

    return {
      'espacos': espacoBasic,
      'plantas': plantaBasic,
      'tarefas': tarefaBasic,
      'resumo': {
        'espacosAtivos': espacoBasic['ativos'] ?? 0,
        'totalPlantas': plantaBasic['total'] ?? 0,
        'tarefasPendentes': tarefaBasic['pendentes'] ?? 0,
        'tarefasAtrasadas': tarefaBasic['atrasadas'] ?? 0,
      }
    };
  }

  /// Obter estatísticas por período
  Future<Map<String, dynamic>> getStatisticsByPeriod(
      DateTime startDate, DateTime endDate) async {
    // Implementação futura: estatísticas filtradas por período
    final basicStats = await getSummaryStatistics();
    return {
      ...basicStats,
      'periodo': {
        'inicio': startDate.toIso8601String(),
        'fim': endDate.toIso8601String(),
      }
    };
  }

  /// Obter tendências (para gráficos)
  Future<Map<String, List<dynamic>>> getTrends(int days) async {
    // Implementação futura: dados de tendência para gráficos
    return {
      'tarefasConcluidas': [], // Lista de valores por dia
      'novasPlantas': [], // Lista de valores por dia
      'novosEspacos': [], // Lista de valores por dia
    };
  }

  /// Obter estatísticas de produtividade
  Future<Map<String, dynamic>> getProductivityStats() async {
    final tarefaStats = await _tarefaStats.getCompleteStatistics();
    final plantaStats = await _plantaStats.getCompleteStatistics();

    final totalTarefas = tarefaStats.total;
    final tarefasConcluidas = tarefaStats.concluidas;
    final produtividade =
        totalTarefas > 0 ? (tarefasConcluidas / totalTarefas * 100).round() : 0;

    return {
      'produtividade': produtividade,
      'tarefasPorPlanta': plantaStats.totalPlantas > 0
          ? (totalTarefas / plantaStats.totalPlantas).round()
          : 0,
      'mediaConclusiaoSemanal': await _calculateWeeklyCompletion(),
    };
  }

  /// Calcular estatísticas de performance
  Future<Map<String, double>> getPerformanceStats() async {
    final tarefas = await _tarefaRepository.findAll();

    if (tarefas.isEmpty) return {'pontualidade': 0.0, 'eficiencia': 0.0};

    final tarefasConcluidas = tarefas.where((t) => t.concluida).toList();

    // Pontualidade: % de tarefas concluídas no prazo
    final noPrazo = tarefasConcluidas
        .where((t) =>
            t.dataConclusao != null &&
            !t.dataConclusao!
                .isAfter(t.dataExecucao.add(const Duration(days: 1))))
        .length;

    final pontualidade = tarefasConcluidas.isNotEmpty
        ? (noPrazo / tarefasConcluidas.length * 100)
        : 0.0;

    // Eficiência: % do total de tarefas concluídas
    final eficiencia = (tarefasConcluidas.length / tarefas.length * 100);

    return {
      'pontualidade': pontualidade,
      'eficiencia': eficiencia,
    };
  }

  /// Métodos auxiliares privados
  Future<int> _calculateWeeklyCompletion() async {
    final agora = DateTime.now();
    final semanaPassada = agora.subtract(const Duration(days: 7));

    final tarefas = await _tarefaRepository.findAll();
    final concluidasNaSemana = tarefas
        .where((t) =>
            t.concluida &&
            t.dataConclusao != null &&
            t.dataConclusao!.isAfter(semanaPassada))
        .length;

    return concluidasNaSemana;
  }
}

/// Classe para estatísticas completas da aplicação
class ApplicationStatistics {
  final dynamic espacos;
  final dynamic plantas;
  final dynamic tarefas;
  final DateTime timestamp;

  ApplicationStatistics({
    required this.espacos,
    required this.plantas,
    required this.tarefas,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'espacos': espacos,
        'plantas': plantas,
        'tarefas': tarefas,
        'timestamp': timestamp.toIso8601String(),
      };
}
