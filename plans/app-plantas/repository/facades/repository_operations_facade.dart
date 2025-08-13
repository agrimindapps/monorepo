// Dart imports:
import 'dart:async';

// Project imports:
import '../../database/espaco_model.dart';
import '../../database/planta_model.dart';
import '../../database/tarefa_model.dart';
import '../../services/domain/business_rules_service.dart';
import '../../services/domain/plants/planta_statistics_service.dart';
import '../../services/domain/statistics_service.dart';
import '../../services/domain/tasks/tarefa_filter_service.dart';
import '../../services/domain/tasks/tarefa_statistics_service.dart';
import '../espaco_repository.dart';
import '../planta_repository.dart';
import '../tarefa_repository.dart';

/// Repository Operations Facade
///
/// ISSUE #33: Mixed Abstraction Levels - SOLUTION
///
/// Este facade centraliza operações complexas de alto nível que anteriormente
/// estavam espalhadas pelos repositórios, criando mixed abstraction levels.
///
/// RESPONSABILIDADES:
/// - Operações complexas que envolvem múltiplos repositórios
/// - Lógica de negócio que combina dados de diferentes entidades
/// - Queries otimizadas que agregam informações de várias fontes
/// - Operações batch complexas com validações cross-entity
///
/// BENEFÍCIOS:
/// - Repositórios mantêm apenas operações CRUD básicas (low-level)
/// - Facade centraliza operações de negócio complexas (high-level)
/// - Consistent abstraction level em cada componente
/// - Melhor testabilidade e manutenibilidade
///
/// USAGE:
/// ```dart
/// final facade = RepositoryOperationsFacade.instance;
///
/// // High-level operations
/// final dashboard = await facade.getDashboardData();
/// final analytics = await facade.getAnalyticsReport();
/// final plantasComCuidados = await facade.findPlantasNeedingCareToday();
/// ```
class RepositoryOperationsFacade {
  static RepositoryOperationsFacade? _instance;
  static RepositoryOperationsFacade get instance =>
      _instance ??= RepositoryOperationsFacade._();

  // Low-level repository dependencies
  final PlantaRepository _plantaRepository = PlantaRepository.instance;
  final TarefaRepository _tarefaRepository = TarefaRepository.instance;
  final EspacoRepository _espacoRepository = EspacoRepository.instance;

  // High-level service dependencies
  final BusinessRulesService _businessRules = BusinessRulesService.instance;
  final StatisticsService _statisticsService = StatisticsService.instance;
  final PlantaStatisticsService _plantaStats = PlantaStatisticsService.instance;
  final TarefaStatisticsService _tarefaStats = TarefaStatisticsService.instance;
  final TarefaFilterService _tarefaFilter = TarefaFilterService.instance;

  RepositoryOperationsFacade._();

  // ===========================================
  // DASHBOARD & ANALYTICS OPERATIONS (HIGH-LEVEL)
  // ===========================================

  /// Obter dados completos do dashboard
  ///
  /// Agrega informações de múltiplos repositórios para criar uma visão
  /// unificada do estado da aplicação.
  Future<DashboardData> getDashboardData() async {
    // Buscar dados básicos em paralelo (otimização)
    final futures = await Future.wait([
      _plantaRepository.findAll(),
      _tarefaRepository.findAll(),
      _espacoRepository.findAll(),
    ]);

    final plantas = futures[0] as List<PlantaModel>;
    final tarefas = futures[1] as List<TarefaModel>;
    final espacos = futures[2] as List<EspacoModel>;

    // Calcular métricas agregadas usando services especializados
    final plantaStats =
        _plantaStats.calculateDetailedStatistics(plantas, tarefas);
    final tarefaStats = _tarefaStats.calculateDetailedStatistics(tarefas);
    final espacoStats = await _statisticsService.getEspacoStatistics();

    // Identificar plantas que precisam de cuidados hoje
    final plantasNeedingCare =
        await _findPlantasNeedingCareInternal(plantas, tarefas);

    return DashboardData(
      totalPlantas: plantas.length,
      totalTarefas: tarefas.length,
      totalEspacos: espacos.where((e) => e.ativo).length,
      plantasNeedingCare: plantasNeedingCare.length,
      tarefasPendentes: tarefaStats['pendentes'] ?? 0,
      tarefasAtrasadas: tarefaStats['atrasadas'] ?? 0,
      plantasPorEspaco: plantaStats['porEspaco'] as Map<String, int>,
      recentActivity: _calculateRecentActivity(plantas, tarefas),
    );
  }

  /// Obter relatório completo de analytics
  ///
  /// Gera relatório detalhado combinando métricas de todas as entidades.
  Future<AnalyticsReport> getAnalyticsReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start =
        startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    // Buscar dados filtrados por período
    final allData = await Future.wait([
      _plantaRepository.findAll(),
      _tarefaRepository.findByPeriodo(start, end),
      _espacoRepository.findAll(),
    ]);

    final plantas = allData[0] as List<PlantaModel>;
    final tarefas = allData[1] as List<TarefaModel>;
    final espacos = allData[2] as List<EspacoModel>;

    // Calcular métricas avançadas
    final completionRate = _calculateCompletionRate(tarefas);
    final careFrequency = _calculateCareFrequency(tarefas);
    final spaceUtilization = _calculateSpaceUtilization(plantas, espacos);
    final growthTrends = _calculateGrowthTrends(plantas, start, end);

    return AnalyticsReport(
      period: DateRange(start, end),
      completionRate: completionRate,
      careFrequency: careFrequency,
      spaceUtilization: spaceUtilization,
      growthTrends: growthTrends,
      recommendations: _generateRecommendations(plantas, tarefas, espacos),
    );
  }

  // ===========================================
  // COMPLEX QUERY OPERATIONS (HIGH-LEVEL)
  // ===========================================

  /// Encontrar plantas que precisam de cuidados hoje
  ///
  /// Operação complexa que combina dados de plantas e tarefas,
  /// aplicando regras de negócio sofisticadas.
  Future<List<PlantaWithCareInfo>> findPlantasNeedingCareToday() async {
    final plantas = await _plantaRepository.findAll();
    final tarefas = await _tarefaRepository.findAll();

    return _findPlantasNeedingCareInternal(plantas, tarefas);
  }

  /// Encontrar plantas com tarefas atrasadas
  ///
  /// Query cross-entity que identifica plantas com tarefas vencidas.
  Future<List<PlantaWithOverdueTasks>> findPlantasComTarefasAtrasadas() async {
    final plantas = await _plantaRepository.findAll();
    final tarefasAtrasadas = await _tarefaRepository.findAtrasadas();

    final result = <PlantaWithOverdueTasks>[];

    for (final planta in plantas) {
      final tarefasPlanta =
          tarefasAtrasadas.where((t) => t.plantaId == planta.id).toList();
      if (tarefasPlanta.isNotEmpty) {
        result.add(PlantaWithOverdueTasks(
          planta: planta,
          overdueTasks: tarefasPlanta,
          daysOverdue: _calculateDaysOverdue(tarefasPlanta),
        ));
      }
    }

    // Ordenar por urgência (mais dias atrasados primeiro)
    result.sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));

    return result;
  }

  /// Buscar plantas por múltiplos critérios
  ///
  /// Query avançada que combina filtros de espaço, tipo de cuidado e status.
  Future<List<PlantaModel>> findPlantasByMultipleCriteria({
    String? espacoId,
    String? tipoCuidado,
    bool? needsCare,
    bool? hasOverdueTasks,
  }) async {
    var plantas = await _plantaRepository.findAll();

    // Aplicar filtros sequencialmente
    if (espacoId != null) {
      plantas = plantas.where((p) => p.espacoId == espacoId).toList();
    }

    if (needsCare != null || hasOverdueTasks != null || tipoCuidado != null) {
      final tarefas = await _tarefaRepository.findAll();

      plantas = plantas.where((planta) {
        final tarefasPlanta = tarefas.where((t) => t.plantaId == planta.id);

        if (tipoCuidado != null) {
          final hasType =
              tarefasPlanta.any((t) => t.tipoCuidado == tipoCuidado);
          if (!hasType) return false;
        }

        if (needsCare == true) {
          final hasToday =
              tarefasPlanta.any((t) => _businessRules.isTarefaForToday(t));
          if (!hasToday) return false;
        }

        if (hasOverdueTasks == true) {
          final hasOverdue =
              tarefasPlanta.any((t) => _businessRules.isTarefaOverdue(t));
          if (!hasOverdue) return false;
        }

        return true;
      }).toList();
    }

    return plantas;
  }

  // ===========================================
  // BATCH OPERATIONS (HIGH-LEVEL)
  // ===========================================

  /// Mover múltiplas plantas para novo espaço com validação
  ///
  /// Operação batch complexa que valida regras de negócio antes da execução.
  Future<BatchOperationResult> moveMultiplePlantasToSpace(
    List<String> plantaIds,
    String novoEspacoId,
  ) async {
    final results = <String, OperationResult>{};

    // Validar espaço de destino
    final espaco = await _espacoRepository.findById(novoEspacoId);
    if (espaco == null || !espaco.ativo) {
      return BatchOperationResult(
        success: false,
        totalOperations: plantaIds.length,
        successfulOperations: 0,
        failedOperations: plantaIds.length,
        results: {
          for (String id in plantaIds)
            id: const OperationResult.error('Espaço inválido')
        },
      );
    }

    // Executar operações individualmente
    for (final plantaId in plantaIds) {
      try {
        final planta = await _plantaRepository.findById(plantaId);
        if (planta == null) {
          results[plantaId] = const OperationResult.error('Planta não encontrada');
          continue;
        }

        // Validar regras de negócio
        final canMove =
            await _businessRules.canMovePlantaToSpace(planta.id, espaco.id);
        if (!canMove) {
          results[plantaId] = const OperationResult.error(
              'Movimento não permitido pelas regras de negócio');
          continue;
        }

        // Executar movimento
        await _plantaRepository.moverParaEspaco(plantaId, novoEspacoId);
        results[plantaId] = const OperationResult.success();
      } catch (e) {
        results[plantaId] = OperationResult.error(e.toString());
      }
    }

    final successful = results.values.where((r) => r.success).length;

    return BatchOperationResult(
      success: successful == plantaIds.length,
      totalOperations: plantaIds.length,
      successfulOperations: successful,
      failedOperations: plantaIds.length - successful,
      results: results,
    );
  }

  /// Completar múltiplas tarefas com validação cross-entity
  ///
  /// Operação batch que valida e completa tarefas, atualizando estatísticas.
  Future<BatchOperationResult> completeMultipleTarefas(
    List<String> tarefaIds, {
    String? observacoes,
  }) async {
    final results = <String, OperationResult>{};

    for (final tarefaId in tarefaIds) {
      try {
        final tarefa = await _tarefaRepository.findById(tarefaId);
        if (tarefa == null) {
          results[tarefaId] = const OperationResult.error('Tarefa não encontrada');
          continue;
        }

        if (tarefa.concluida) {
          results[tarefaId] = const OperationResult.error('Tarefa já concluída');
          continue;
        }

        // Validar se a planta ainda existe
        final planta = await _plantaRepository.findById(tarefa.plantaId);
        if (planta == null) {
          results[tarefaId] =
              const OperationResult.error('Planta associada não encontrada');
          continue;
        }

        // Executar conclusão
        await _tarefaRepository.marcarConcluida(tarefaId,
            observacoes: observacoes);
        results[tarefaId] = const OperationResult.success();
      } catch (e) {
        results[tarefaId] = OperationResult.error(e.toString());
      }
    }

    final successful = results.values.where((r) => r.success).length;

    return BatchOperationResult(
      success: successful == tarefaIds.length,
      totalOperations: tarefaIds.length,
      successfulOperations: successful,
      failedOperations: tarefaIds.length - successful,
      results: results,
    );
  }

  // ===========================================
  // PRIVATE HELPER METHODS
  // ===========================================

  Future<List<PlantaWithCareInfo>> _findPlantasNeedingCareInternal(
    List<PlantaModel> plantas,
    List<TarefaModel> tarefas,
  ) async {
    final result = <PlantaWithCareInfo>[];

    for (final planta in plantas) {
      final tarefasPlanta =
          tarefas.where((t) => t.plantaId == planta.id).toList();
      final tarefasHoje =
          tarefasPlanta.where((t) => _businessRules.isTarefaForToday(t)).toList();
      final tarefasAtrasadas =
          tarefasPlanta.where((t) => _businessRules.isTarefaOverdue(t)).toList();

      if (tarefasHoje.isNotEmpty || tarefasAtrasadas.isNotEmpty) {
        result.add(PlantaWithCareInfo(
          planta: planta,
          todayTasks: tarefasHoje,
          overdueTasks: tarefasAtrasadas,
          urgencyScore: _calculateUrgencyScore(tarefasHoje, tarefasAtrasadas),
        ));
      }
    }

    // Ordenar por urgência
    result.sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));

    return result;
  }

  int _calculateDaysOverdue(List<TarefaModel> tarefas) {
    if (tarefas.isEmpty) return 0;

    final hoje = DateTime.now();
    final oldestOverdue = tarefas.map((t) => t.dataExecucao).reduce(
          (a, b) => a.isBefore(b) ? a : b,
        );

    return hoje.difference(oldestOverdue).inDays;
  }

  double _calculateCompletionRate(List<TarefaModel> tarefas) {
    if (tarefas.isEmpty) return 0.0;

    final concluidas = tarefas.where((t) => t.concluida).length;
    return (concluidas / tarefas.length) * 100;
  }

  Map<String, double> _calculateCareFrequency(List<TarefaModel> tarefas) {
    final frequency = <String, int>{};

    for (final tarefa in tarefas) {
      frequency[tarefa.tipoCuidado] = (frequency[tarefa.tipoCuidado] ?? 0) + 1;
    }

    final total = tarefas.length;
    return frequency.map((key, value) => MapEntry(key, (value / total) * 100));
  }

  Map<String, double> _calculateSpaceUtilization(
    List<PlantaModel> plantas,
    List<EspacoModel> espacos,
  ) {
    final utilization = <String, double>{};

    for (final espaco in espacos.where((e) => e.ativo)) {
      final plantasNoEspaco =
          plantas.where((p) => p.espacoId == espaco.id).length;
      // Assumindo capacidade média de 10 plantas por espaço
      utilization[espaco.nome] = (plantasNoEspaco / 10) * 100;
    }

    return utilization;
  }

  Map<String, int> _calculateGrowthTrends(
    List<PlantaModel> plantas,
    DateTime start,
    DateTime end,
  ) {
    final trends = <String, int>{};
    final monthlyGrowth = <String, int>{};

    for (final planta in plantas) {
      final createdAt = DateTime.fromMillisecondsSinceEpoch(planta.createdAt);
      if (createdAt.isAfter(start) && createdAt.isBefore(end)) {
        final monthKey =
            '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
        monthlyGrowth[monthKey] = (monthlyGrowth[monthKey] ?? 0) + 1;
      }
    }

    return monthlyGrowth;
  }

  List<String> _generateRecommendations(
    List<PlantaModel> plantas,
    List<TarefaModel> tarefas,
    List<EspacoModel> espacos,
  ) {
    final recommendations = <String>[];

    // Verificar plantas sem cuidados recentes
    final plantasSemCuidados = plantas.where((planta) {
      final tarefasPlanta = tarefas.where((t) => t.plantaId == planta.id);
      final ultimaTarefa = tarefasPlanta.isEmpty
          ? null
          : tarefasPlanta
              .reduce((a, b) => a.dataExecucao.isAfter(b.dataExecucao) ? a : b);

      return ultimaTarefa == null ||
          DateTime.now().difference(ultimaTarefa.dataExecucao).inDays > 7;
    }).length;

    if (plantasSemCuidados > 0) {
      recommendations
          .add('$plantasSemCuidados plantas precisam de mais atenção');
    }

    // Verificar espaços subutilizados
    final espacosSubutilizados = espacos.where((espaco) {
      final plantasNoEspaco =
          plantas.where((p) => p.espacoId == espaco.id).length;
      return plantasNoEspaco < 2 && espaco.ativo;
    }).length;

    if (espacosSubutilizados > 0) {
      recommendations.add('$espacosSubutilizados espaços estão subutilizados');
    }

    return recommendations;
  }

  List<RecentActivity> _calculateRecentActivity(
    List<PlantaModel> plantas,
    List<TarefaModel> tarefas,
  ) {
    final activities = <RecentActivity>[];
    final agora = DateTime.now();
    final ultimaSemana = agora.subtract(const Duration(days: 7));

    // Plantas criadas recentemente
    final plantasRecentes = plantas.where((p) {
      final createdAt = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
      return createdAt.isAfter(ultimaSemana);
    }).length;

    if (plantasRecentes > 0) {
      activities.add(RecentActivity(
        type: 'plantas_created',
        count: plantasRecentes,
        description: '$plantasRecentes plantas adicionadas',
      ));
    }

    // Tarefas concluídas recentemente
    final tarefasRecentes = tarefas.where((t) {
      return t.concluida &&
          t.dataConclusao != null &&
          t.dataConclusao!.isAfter(ultimaSemana);
    }).length;

    if (tarefasRecentes > 0) {
      activities.add(RecentActivity(
        type: 'tasks_completed',
        count: tarefasRecentes,
        description: '$tarefasRecentes tarefas concluídas',
      ));
    }

    return activities;
  }

  double _calculateUrgencyScore(
    List<TarefaModel> todayTasks,
    List<TarefaModel> overdueTasks,
  ) {
    double score = 0.0;

    // Tarefas de hoje: 1 ponto cada
    score += todayTasks.length * 1.0;

    // Tarefas atrasadas: 2 pontos cada + dias de atraso
    for (final tarefa in overdueTasks) {
      final diasAtraso = DateTime.now().difference(tarefa.dataExecucao).inDays;
      score += 2.0 + (diasAtraso * 0.5);
    }

    return score;
  }

  /// Limpar recursos
  Future<void> dispose() async {
    // Facade não gerencia recursos próprios, apenas coordena
    // Os repositories e services são gerenciados pelos seus próprios lifecycles
  }
}

// ===========================================
// DATA MODELS PARA OPERATIONS FACADE
// ===========================================

class DashboardData {
  final int totalPlantas;
  final int totalTarefas;
  final int totalEspacos;
  final int plantasNeedingCare;
  final int tarefasPendentes;
  final int tarefasAtrasadas;
  final Map<String, int> plantasPorEspaco;
  final List<RecentActivity> recentActivity;

  const DashboardData({
    required this.totalPlantas,
    required this.totalTarefas,
    required this.totalEspacos,
    required this.plantasNeedingCare,
    required this.tarefasPendentes,
    required this.tarefasAtrasadas,
    required this.plantasPorEspaco,
    required this.recentActivity,
  });
}

class AnalyticsReport {
  final DateRange period;
  final double completionRate;
  final Map<String, double> careFrequency;
  final Map<String, double> spaceUtilization;
  final Map<String, int> growthTrends;
  final List<String> recommendations;

  const AnalyticsReport({
    required this.period,
    required this.completionRate,
    required this.careFrequency,
    required this.spaceUtilization,
    required this.growthTrends,
    required this.recommendations,
  });
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange(this.start, this.end);
}

class RecentActivity {
  final String type;
  final int count;
  final String description;

  const RecentActivity({
    required this.type,
    required this.count,
    required this.description,
  });
}

class PlantaWithCareInfo {
  final PlantaModel planta;
  final List<TarefaModel> todayTasks;
  final List<TarefaModel> overdueTasks;
  final double urgencyScore;

  const PlantaWithCareInfo({
    required this.planta,
    required this.todayTasks,
    required this.overdueTasks,
    required this.urgencyScore,
  });
}

class PlantaWithOverdueTasks {
  final PlantaModel planta;
  final List<TarefaModel> overdueTasks;
  final int daysOverdue;

  const PlantaWithOverdueTasks({
    required this.planta,
    required this.overdueTasks,
    required this.daysOverdue,
  });
}

class BatchOperationResult {
  final bool success;
  final int totalOperations;
  final int successfulOperations;
  final int failedOperations;
  final Map<String, OperationResult> results;

  const BatchOperationResult({
    required this.success,
    required this.totalOperations,
    required this.successfulOperations,
    required this.failedOperations,
    required this.results,
  });
}

class OperationResult {
  final bool success;
  final String? error;

  const OperationResult.success()
      : success = true,
        error = null;
  const OperationResult.error(this.error) : success = false;
}
