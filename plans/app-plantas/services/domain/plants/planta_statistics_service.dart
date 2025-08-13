// Project imports:
import '../../../database/planta_model.dart';
import '../../../database/tarefa_model.dart';
import '../../../repository/planta_config_repository.dart';
import '../../../repository/planta_repository.dart';
import '../tasks/simple_task_service.dart';

/// Serviço para estatísticas e relatórios de plantas
/// Responsabilidade: Processamento de métricas e análises de plantas
class PlantaStatisticsService {
  static PlantaStatisticsService? _instance;
  static PlantaStatisticsService get instance =>
      _instance ??= PlantaStatisticsService._();

  final PlantaRepository _plantaRepository = PlantaRepository.instance;
  final PlantaConfigRepository _configRepository =
      PlantaConfigRepository.instance;
  final SimpleTaskService _taskService = SimpleTaskService.instance;

  PlantaStatisticsService._();

  /// Calcular estatísticas detalhadas das plantas (usando dados já carregados)
  Map<String, dynamic> calculateDetailedStatistics(
    List<PlantaModel> plantas,
    List<TarefaModel> tarefas,
  ) {
    // Contadores por tipo de cuidado
    final careTypeCounts = <String, int>{};
    int plantsWithActiveCares = 0;
    int plantsWithoutCares = 0;

    // Categorizar plantas com/sem cuidados ativos
    for (final planta in plantas) {
      // Verificar se há tarefas para esta planta
      final plantTasks = tarefas.where((t) => t.plantaId == planta.id).toList();
      
      if (plantTasks.isEmpty) {
        plantsWithoutCares++;
        continue;
      }

      plantsWithActiveCares++;

      // Contar tipos de cuidado
      final careTypes = plantTasks.map((t) => t.tipoCuidado).toSet();
      for (final careType in careTypes) {
        careTypeCounts[careType] = (careTypeCounts[careType] ?? 0) + 1;
      }
    }

    // Analisar tarefas por data
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayTasks = tarefas.where((t) {
      final taskDate = DateTime(t.dataExecucao.year, t.dataExecucao.month, t.dataExecucao.day);
      return taskDate == today;
    }).toList();

    final overdueTasks = tarefas.where((t) {
      final taskDate = DateTime(t.dataExecucao.year, t.dataExecucao.month, t.dataExecucao.day);
      return taskDate.isBefore(today) && !t.concluida;
    }).toList();

    // Métricas de tarefas
    final todayPendingTasks = todayTasks.where((t) => !t.concluida).length;
    final todayCompletedTasks = todayTasks.where((t) => t.concluida).length;
    final overduePendingTasks = overdueTasks.length;

    // Plantas que precisam de cuidados
    final plantsWithTasksToday = todayTasks
        .where((t) => !t.concluida)
        .map((t) => t.plantaId)
        .toSet()
        .length;

    final plantsWithOverdueTasks = overdueTasks
        .map((t) => t.plantaId)
        .toSet()
        .length;

    return {
      'total': plantas.length,
      'plantsWithActiveCares': plantsWithActiveCares,
      'plantsWithoutCares': plantsWithoutCares,
      'careTypeCounts': careTypeCounts,
      'tasksToday': todayPendingTasks,
      'tasksOverdue': overduePendingTasks,
      'tasksCompletedToday': todayCompletedTasks,
      'plantsNeedingCareToday': plantsWithTasksToday,
      'plantsWithOverdueTasks': plantsWithOverdueTasks,
    };
  }

  /// Obter estatísticas completas das plantas
  Future<PlantaStatistics> getCompleteStatistics() async {
    final plantas = await _plantaRepository.findAll();
    await _configRepository.initialize();
    await _taskService.initialize();

    final todayTasks = await _taskService.getTodayTasks();
    final overdueTasks = await _taskService.getOverdueTasks();

    // Contadores por tipo de cuidado
    final careTypeCounts = <String, int>{};
    int plantsWithActiveCares = 0;
    int plantsWithoutCares = 0;

    // Analisar configurações de plantas
    for (final planta in plantas) {
      final config = await _configRepository.findByPlantaId(planta.id);

      if (config == null || config.activeCareTypes.isEmpty) {
        plantsWithoutCares++;
        continue;
      }

      plantsWithActiveCares++;

      // Contar tipos de cuidado ativos
      const careTypes = [
        'agua',
        'adubo',
        'banho_sol',
        'inspecao_pragas',
        'poda',
        'replantio'
      ];
      for (final careType in careTypes) {
        if (config.isCareTypeActive(careType)) {
          careTypeCounts[careType] = (careTypeCounts[careType] ?? 0) + 1;
        }
      }
    }

    // Analisar tarefas
    final todayPendingTasks =
        todayTasks.cast<TarefaModel>().where((task) => !task.concluida).length;
    final overduePendingTasks = overdueTasks
        .cast<TarefaModel>()
        .where((task) => !task.concluida)
        .length;
    final todayCompletedTasks =
        todayTasks.cast<TarefaModel>().where((task) => task.concluida).length;

    // Plantas com tarefas hoje
    final plantsWithTasksToday = todayTasks
        .cast<TarefaModel>()
        .where((task) => !task.concluida)
        .map((task) => task.plantaId)
        .toSet()
        .length;

    // Plantas com tarefas atrasadas
    final plantsWithOverdueTasks = overdueTasks
        .cast<TarefaModel>()
        .where((task) => !task.concluida)
        .map((task) => task.plantaId)
        .toSet()
        .length;

    return PlantaStatistics(
      totalPlantas: plantas.length,
      plantsWithActiveCares: plantsWithActiveCares,
      plantsWithoutCares: plantsWithoutCares,
      careTypeCounts: careTypeCounts,
      tasksToday: todayPendingTasks,
      tasksOverdue: overduePendingTasks,
      tasksCompletedToday: todayCompletedTasks,
      plantsNeedingCareToday: plantsWithTasksToday,
      plantsWithOverdueTasks: plantsWithOverdueTasks,
    );
  }

  /// Obter distribuição de plantas por espaço
  Future<Map<String, int>> getDistributionBySpace() async {
    return await _plantaRepository.countByEspaco();
  }

  /// Obter estatísticas de cuidados por tipo
  Future<Map<String, CareTypeStatistics>> getCareTypeStatistics() async {
    final plantas = await _plantaRepository.findAll();
    await _configRepository.initialize();
    await _taskService.initialize();

    final todayTasks = await _taskService.getTodayTasks();
    final overdueTasks = await _taskService.getOverdueTasks();

    const careTypes = [
      'agua',
      'adubo',
      'banho_sol',
      'inspecao_pragas',
      'poda',
      'replantio'
    ];
    final statistics = <String, CareTypeStatistics>{};

    for (final careType in careTypes) {
      int plantsWithThisCare = 0;

      // Contar plantas com este tipo de cuidado ativo
      for (final planta in plantas) {
        final config = await _configRepository.findByPlantaId(planta.id);
        if (config != null && config.isCareTypeActive(careType)) {
          plantsWithThisCare++;
        }
      }

      // Contar tarefas pendentes e concluídas para este tipo
      final todayPendingTasks = todayTasks
          .cast<TarefaModel>()
          .where((task) => task.tipoCuidado == careType && !task.concluida)
          .length;

      final todayCompletedTasks = todayTasks
          .cast<TarefaModel>()
          .where((task) => task.tipoCuidado == careType && task.concluida)
          .length;

      final overduePendingTasks = overdueTasks
          .cast<TarefaModel>()
          .where((task) => task.tipoCuidado == careType && !task.concluida)
          .length;

      statistics[careType] = CareTypeStatistics(
        plantsWithCare: plantsWithThisCare,
        tasksToday: todayPendingTasks,
        tasksCompleted: todayCompletedTasks,
        tasksOverdue: overduePendingTasks,
      );
    }

    return statistics;
  }

  /// Obter ranking das plantas que mais precisam de cuidados
  Future<List<PlantaCareRanking>> getPlantsNeedingMostCare(
      {int limit = 10}) async {
    final plantas = await _plantaRepository.findAll();
    await _taskService.initialize();

    final todayTasks = await _taskService.getTodayTasks();
    final overdueTasks = await _taskService.getOverdueTasks();

    final rankings = <PlantaCareRanking>[];

    for (final planta in plantas) {
      final todayTasksCount = todayTasks
          .cast<TarefaModel>()
          .where((task) => task.plantaId == planta.id && !task.concluida)
          .length;

      final overdueTasksCount = overdueTasks
          .cast<TarefaModel>()
          .where((task) => task.plantaId == planta.id && !task.concluida)
          .length;

      if (todayTasksCount > 0 || overdueTasksCount > 0) {
        rankings.add(PlantaCareRanking(
          planta: planta,
          todayTasks: todayTasksCount,
          overdueTasks: overdueTasksCount,
          totalPendingTasks: todayTasksCount + overdueTasksCount,
        ));
      }
    }

    // Ordenar por total de tarefas pendentes (atrasadas têm peso maior)
    rankings.sort((a, b) {
      final scoreA = a.overdueTasks * 2 + a.todayTasks;
      final scoreB = b.overdueTasks * 2 + b.todayTasks;
      return scoreB.compareTo(scoreA);
    });

    return rankings.take(limit).toList();
  }

  /// Obter relatório de produtividade (tarefas concluídas vs pendentes)
  Future<ProductivityReport> getProductivityReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await _taskService.initialize();

    final todayTasks = await _taskService.getTodayTasks();
    final completedTasks =
        todayTasks.cast<TarefaModel>().where((task) => task.concluida).length;
    final pendingTasks =
        todayTasks.cast<TarefaModel>().where((task) => !task.concluida).length;
    final overdueTasks = (await _taskService.getOverdueTasks())
        .cast<TarefaModel>()
        .where((task) => !task.concluida)
        .length;

    final totalScheduled = completedTasks + pendingTasks;
    final completionRate =
        totalScheduled > 0 ? (completedTasks / totalScheduled) * 100 : 0.0;

    return ProductivityReport(
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      overdueTasks: overdueTasks,
      completionRate: completionRate,
      totalScheduled: totalScheduled,
    );
  }
}

/// Classe para estatísticas completas de plantas
class PlantaStatistics {
  final int totalPlantas;
  final int plantsWithActiveCares;
  final int plantsWithoutCares;
  final Map<String, int> careTypeCounts;
  final int tasksToday;
  final int tasksOverdue;
  final int tasksCompletedToday;
  final int plantsNeedingCareToday;
  final int plantsWithOverdueTasks;

  const PlantaStatistics({
    required this.totalPlantas,
    required this.plantsWithActiveCares,
    required this.plantsWithoutCares,
    required this.careTypeCounts,
    required this.tasksToday,
    required this.tasksOverdue,
    required this.tasksCompletedToday,
    required this.plantsNeedingCareToday,
    required this.plantsWithOverdueTasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalPlantas': totalPlantas,
      'plantsWithActiveCares': plantsWithActiveCares,
      'plantsWithoutCares': plantsWithoutCares,
      'careTypeCounts': careTypeCounts,
      'tasksToday': tasksToday,
      'tasksOverdue': tasksOverdue,
      'tasksCompletedToday': tasksCompletedToday,
      'plantsNeedingCareToday': plantsNeedingCareToday,
      'plantsWithOverdueTasks': plantsWithOverdueTasks,
    };
  }
}

/// Estatísticas por tipo de cuidado
class CareTypeStatistics {
  final int plantsWithCare;
  final int tasksToday;
  final int tasksCompleted;
  final int tasksOverdue;

  const CareTypeStatistics({
    required this.plantsWithCare,
    required this.tasksToday,
    required this.tasksCompleted,
    required this.tasksOverdue,
  });
}

/// Ranking de plantas que precisam de cuidados
class PlantaCareRanking {
  final PlantaModel planta;
  final int todayTasks;
  final int overdueTasks;
  final int totalPendingTasks;

  const PlantaCareRanking({
    required this.planta,
    required this.todayTasks,
    required this.overdueTasks,
    required this.totalPendingTasks,
  });
}

/// Relatório de produtividade
class ProductivityReport {
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final double completionRate;
  final int totalScheduled;

  const ProductivityReport({
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.completionRate,
    required this.totalScheduled,
  });
}
