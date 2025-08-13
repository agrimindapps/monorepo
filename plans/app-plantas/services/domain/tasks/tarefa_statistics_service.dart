// Project imports:
import '../../../core/extensions/datetime_extensions.dart';

import '../../../repository/tarefa_repository.dart';

/// Serviço para estatísticas e relatórios de tarefas
/// Responsabilidade: Processamento de métricas e análises de tarefas
class TarefaStatisticsService {
  static TarefaStatisticsService? _instance;
  static TarefaStatisticsService get instance =>
      _instance ??= TarefaStatisticsService._();

  final TarefaRepository _repository = TarefaRepository.instance;

  TarefaStatisticsService._();

  /// Calcular estatísticas detalhadas das tarefas (usando dados já carregados)
  Map<String, dynamic> calculateDetailedStatistics(List<dynamic> tarefas) {
    // Converter para TarefaModel se necessário
    final tarefaModels = tarefas.cast<dynamic>().whereType<Map>().map((t) {
      // Se for Map, assumir que são dados de tarefa
      return {
        'concluida': t['concluida'] ?? false,
        'tipoCuidado': t['tipoCuidado'] ?? '',
        'dataExecucao': t['dataExecucao'] ?? DateTime.now(),
        'dataConclusao': t['dataConclusao'],
      };
    }).toList();

    if (tarefas.isNotEmpty && tarefas.first is Map) {
      // Se são Maps, processar como tal
      return _calculateFromMaps(tarefaModels);
    }

    // Se são objetos TarefaModel, processar normalmente  
    return _calculateFromObjects(tarefas.cast());
  }

  Map<String, dynamic> _calculateFromMaps(List<Map> tarefas) {
    int total = tarefas.length;
    int pendentes = 0;
    int concluidas = 0;
    int paraHoje = 0;
    int atrasadas = 0;
    int concluidasHoje = 0;

    final careTypeCounts = <String, int>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final tarefa in tarefas) {
      final tipoCuidado = tarefa['tipoCuidado'] as String? ?? '';
      final concluida = tarefa['concluida'] as bool? ?? false;
      final dataExecucao = tarefa['dataExecucao'] as DateTime? ?? DateTime.now();
      
      careTypeCounts[tipoCuidado] = (careTypeCounts[tipoCuidado] ?? 0) + 1;

      if (concluida) {
        concluidas++;
        final dataConclusao = tarefa['dataConclusao'] as DateTime? ?? dataExecucao;
        final conclusaoDate = DateTime(dataConclusao.year, dataConclusao.month, dataConclusao.day);
        if (conclusaoDate == today) {
          concluidasHoje++;
        }
      } else {
        pendentes++;
        final execucaoDate = DateTime(dataExecucao.year, dataExecucao.month, dataExecucao.day);
        
        if (execucaoDate == today) {
          paraHoje++;
        } else if (execucaoDate.isBefore(today)) {
          atrasadas++;
        }
      }
    }

    return {
      'total': total,
      'pendentes': pendentes,
      'concluidas': concluidas,
      'paraHoje': paraHoje,
      'atrasadas': atrasadas,
      'concluidasHoje': concluidasHoje,
      'careTypeCounts': careTypeCounts,
    };
  }

  Map<String, dynamic> _calculateFromObjects(List tarefas) {
    // Implementação para objetos reais (quando disponível)
    return {
      'total': tarefas.length,
      'pendentes': 0,
      'concluidas': 0,
      'paraHoje': 0,
      'atrasadas': 0,
      'concluidasHoje': 0,
      'careTypeCounts': <String, int>{},
    };
  }

  /// Obter estatísticas completas das tarefas
  Future<TarefaStatistics> getCompleteStatistics() async {
    final tarefas = await _repository.findAll();

    int total = tarefas.length;
    int pendentes = 0;
    int concluidas = 0;
    int paraHoje = 0;
    int atrasadas = 0;
    int futuras = 0;
    int concluidasHoje = 0;

    final careTypeCounts = <String, int>{};
    final careTypeCompletedCounts = <String, int>{};

    for (final tarefa in tarefas) {
      // Contar por tipo de cuidado
      careTypeCounts[tarefa.tipoCuidado] =
          (careTypeCounts[tarefa.tipoCuidado] ?? 0) + 1;

      if (tarefa.concluida) {
        concluidas++;
        careTypeCompletedCounts[tarefa.tipoCuidado] =
            (careTypeCompletedCounts[tarefa.tipoCuidado] ?? 0) + 1;

        // Verificar se foi concluída hoje
        final dataConclusao = tarefa.dataConclusao ?? tarefa.dataExecucao;
        if (dataConclusao.isToday) {
          concluidasHoje++;
        }
      } else {
        pendentes++;

        if (tarefa.dataExecucao.isToday) {
          paraHoje++;
        } else if (tarefa.dataExecucao.isBeforeToday) {
          atrasadas++;
        } else {
          futuras++;
        }
      }
    }

    return TarefaStatistics(
      total: total,
      pendentes: pendentes,
      concluidas: concluidas,
      paraHoje: paraHoje,
      atrasadas: atrasadas,
      futuras: futuras,
      concluidasHoje: concluidasHoje,
      careTypeCounts: careTypeCounts,
      careTypeCompletedCounts: careTypeCompletedCounts,
    );
  }

  /// Obter estatísticas por período
  Future<PeriodStatistics> getStatisticsByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final tarefas = await _repository.findAll();

    final tarefasNoPeriodo = tarefas
        .where((tarefa) => tarefa.dataExecucao.isBetween(startDate, endDate))
        .toList();

    int agendadas = tarefasNoPeriodo.length;
    int concluidas = tarefasNoPeriodo.where((t) => t.concluida).length;
    int pendentes = agendadas - concluidas;
    double taxaConclusao = agendadas > 0 ? (concluidas / agendadas) * 100 : 0.0;

    // Agrupar por tipo de cuidado
    final porTipoCuidado = <String, PeriodCareTypeStats>{};

    for (final tarefa in tarefasNoPeriodo) {
      final tipo = tarefa.tipoCuidado;
      final stats = porTipoCuidado[tipo] ?? PeriodCareTypeStats(tipo: tipo);

      porTipoCuidado[tipo] = PeriodCareTypeStats(
        tipo: tipo,
        total: stats.total + 1,
        concluidas: stats.concluidas + (tarefa.concluida ? 1 : 0),
        pendentes: stats.pendentes + (tarefa.concluida ? 0 : 1),
      );
    }

    return PeriodStatistics(
      startDate: startDate,
      endDate: endDate,
      tarefasAgendadas: agendadas,
      tarefasConcluidas: concluidas,
      tarefasPendentes: pendentes,
      taxaConclusao: taxaConclusao,
      estatisticasPorTipo: porTipoCuidado,
    );
  }

  /// Obter relatório de produtividade diária
  Future<DailyProductivityReport> getDailyProductivity({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final tarefas = await _repository.findAll();

    final tarefasDoDia = tarefas.where((tarefa) {
      final taskDate = DateTime(
        tarefa.dataExecucao.year,
        tarefa.dataExecucao.month,
        tarefa.dataExecucao.day,
      );
      final targetDayOnly =
          DateTime(targetDate.year, targetDate.month, targetDate.day);
      return taskDate.isAtSameMomentAs(targetDayOnly);
    }).toList();

    final concluidas = tarefasDoDia.where((t) => t.concluida).length;
    final pendentes = tarefasDoDia.length - concluidas;

    // Calcular tarefas atrasadas para este dia
    final atrasadas = tarefas
        .where((tarefa) =>
            !tarefa.concluida &&
            tarefa.dataExecucao.isBefore(targetDate) &&
            !tarefa.dataExecucao.isToday)
        .length;

    return DailyProductivityReport(
      date: targetDate,
      tarefasAgendadas: tarefasDoDia.length,
      tarefasConcluidas: concluidas,
      tarefasPendentes: pendentes,
      tarefasAtrasadas: atrasadas,
      eficiencia: tarefasDoDia.isNotEmpty
          ? (concluidas / tarefasDoDia.length) * 100
          : 0.0,
    );
  }

  /// Obter ranking de plantas por tarefas concluídas
  Future<List<PlantTaskRanking>> getPlantCompletionRanking({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 10,
  }) async {
    final tarefas = await _repository.findAll();

    // Filtrar por período se especificado
    var filteredTasks = tarefas;
    if (startDate != null || endDate != null) {
      filteredTasks = tarefas.where((tarefa) {
        if (startDate != null && tarefa.dataExecucao.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && tarefa.dataExecucao.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();
    }

    // Agrupar por planta
    final plantStats = <String, PlantTaskStats>{};

    for (final tarefa in filteredTasks) {
      final plantaId = tarefa.plantaId;
      final stats = plantStats[plantaId] ?? PlantTaskStats(plantaId: plantaId);

      plantStats[plantaId] = PlantTaskStats(
        plantaId: plantaId,
        totalTarefas: stats.totalTarefas + 1,
        tarefasConcluidas: stats.tarefasConcluidas + (tarefa.concluida ? 1 : 0),
        tarefasPendentes: stats.tarefasPendentes + (tarefa.concluida ? 0 : 1),
      );
    }

    // Converter para ranking e ordenar
    final rankings = plantStats.values
        .map((stats) => PlantTaskRanking(
              plantaId: stats.plantaId,
              totalTarefas: stats.totalTarefas,
              tarefasConcluidas: stats.tarefasConcluidas,
              tarefasPendentes: stats.tarefasPendentes,
              taxaConclusao: stats.totalTarefas > 0
                  ? (stats.tarefasConcluidas / stats.totalTarefas) * 100
                  : 0.0,
            ))
        .toList();

    rankings.sort((a, b) => b.taxaConclusao.compareTo(a.taxaConclusao));

    return rankings.take(limit).toList();
  }

  /// Obter tendência de conclusão de tarefas (últimos N dias)
  Future<CompletionTrendReport> getCompletionTrend({int days = 7}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));

    final tarefas = await _repository.findAll();
    final dailyData = <DateTime, DailyTrendData>{};

    // Inicializar dados para todos os dias
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      dailyData[dateOnly] = DailyTrendData(date: dateOnly);
    }

    // Processar tarefas
    for (final tarefa in tarefas) {
      final taskDateOnly = DateTime(
        tarefa.dataExecucao.year,
        tarefa.dataExecucao.month,
        tarefa.dataExecucao.day,
      );

      if (dailyData.containsKey(taskDateOnly)) {
        final data = dailyData[taskDateOnly]!;
        dailyData[taskDateOnly] = DailyTrendData(
          date: taskDateOnly,
          agendadas: data.agendadas + 1,
          concluidas: data.concluidas + (tarefa.concluida ? 1 : 0),
        );
      }
    }

    final trend = dailyData.values.toList();
    trend.sort((a, b) => a.date.compareTo(b.date));

    return CompletionTrendReport(
      startDate: startDate,
      endDate: endDate,
      dailyData: trend,
    );
  }

  /// Obter estatísticas de atraso
  Future<DelayStatistics> getDelayStatistics() async {
    final tarefas = await _repository.findAll();
    final hoje = DateTime.now();

    int tarefasAtrasadas = 0;
    int totalDiasAtraso = 0;
    final atrasoPorTipo = <String, DelayByCareType>{};

    for (final tarefa in tarefas) {
      if (!tarefa.concluida && tarefa.dataExecucao.isBefore(hoje)) {
        tarefasAtrasadas++;

        final diasAtraso = hoje.difference(tarefa.dataExecucao).inDays;
        totalDiasAtraso += diasAtraso;

        final tipo = tarefa.tipoCuidado;
        final delay = atrasoPorTipo[tipo] ?? DelayByCareType(careType: tipo);

        atrasoPorTipo[tipo] = DelayByCareType(
          careType: tipo,
          count: delay.count + 1,
          totalDays: delay.totalDays + diasAtraso,
        );
      }
    }

    return DelayStatistics(
      tarefasAtrasadas: tarefasAtrasadas,
      mediaDiasAtraso:
          tarefasAtrasadas > 0 ? totalDiasAtraso / tarefasAtrasadas : 0.0,
      atrasoPorTipoCuidado: atrasoPorTipo,
    );
  }
}

// Classes auxiliares para estatísticas

class TarefaStatistics {
  final int total;
  final int pendentes;
  final int concluidas;
  final int paraHoje;
  final int atrasadas;
  final int futuras;
  final int concluidasHoje;
  final Map<String, int> careTypeCounts;
  final Map<String, int> careTypeCompletedCounts;

  const TarefaStatistics({
    required this.total,
    required this.pendentes,
    required this.concluidas,
    required this.paraHoje,
    required this.atrasadas,
    required this.futuras,
    required this.concluidasHoje,
    required this.careTypeCounts,
    required this.careTypeCompletedCounts,
  });

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'pendentes': pendentes,
      'concluidas': concluidas,
      'paraHoje': paraHoje,
      'atrasadas': atrasadas,
      'futuras': futuras,
      'concluidasHoje': concluidasHoje,
      'careTypeCounts': careTypeCounts,
      'careTypeCompletedCounts': careTypeCompletedCounts,
    };
  }
}

class PeriodStatistics {
  final DateTime startDate;
  final DateTime endDate;
  final int tarefasAgendadas;
  final int tarefasConcluidas;
  final int tarefasPendentes;
  final double taxaConclusao;
  final Map<String, PeriodCareTypeStats> estatisticasPorTipo;

  const PeriodStatistics({
    required this.startDate,
    required this.endDate,
    required this.tarefasAgendadas,
    required this.tarefasConcluidas,
    required this.tarefasPendentes,
    required this.taxaConclusao,
    required this.estatisticasPorTipo,
  });
}

class PeriodCareTypeStats {
  final String tipo;
  final int total;
  final int concluidas;
  final int pendentes;

  const PeriodCareTypeStats({
    required this.tipo,
    this.total = 0,
    this.concluidas = 0,
    this.pendentes = 0,
  });

  double get taxaConclusao => total > 0 ? (concluidas / total) * 100 : 0.0;
}

class DailyProductivityReport {
  final DateTime date;
  final int tarefasAgendadas;
  final int tarefasConcluidas;
  final int tarefasPendentes;
  final int tarefasAtrasadas;
  final double eficiencia;

  const DailyProductivityReport({
    required this.date,
    required this.tarefasAgendadas,
    required this.tarefasConcluidas,
    required this.tarefasPendentes,
    required this.tarefasAtrasadas,
    required this.eficiencia,
  });
}

class PlantTaskStats {
  final String plantaId;
  final int totalTarefas;
  final int tarefasConcluidas;
  final int tarefasPendentes;

  const PlantTaskStats({
    required this.plantaId,
    this.totalTarefas = 0,
    this.tarefasConcluidas = 0,
    this.tarefasPendentes = 0,
  });
}

class PlantTaskRanking {
  final String plantaId;
  final int totalTarefas;
  final int tarefasConcluidas;
  final int tarefasPendentes;
  final double taxaConclusao;

  const PlantTaskRanking({
    required this.plantaId,
    required this.totalTarefas,
    required this.tarefasConcluidas,
    required this.tarefasPendentes,
    required this.taxaConclusao,
  });
}

class CompletionTrendReport {
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyTrendData> dailyData;

  const CompletionTrendReport({
    required this.startDate,
    required this.endDate,
    required this.dailyData,
  });
}

class DailyTrendData {
  final DateTime date;
  final int agendadas;
  final int concluidas;

  const DailyTrendData({
    required this.date,
    this.agendadas = 0,
    this.concluidas = 0,
  });

  double get taxaConclusao =>
      agendadas > 0 ? (concluidas / agendadas) * 100 : 0.0;
}

class DelayStatistics {
  final int tarefasAtrasadas;
  final double mediaDiasAtraso;
  final Map<String, DelayByCareType> atrasoPorTipoCuidado;

  const DelayStatistics({
    required this.tarefasAtrasadas,
    required this.mediaDiasAtraso,
    required this.atrasoPorTipoCuidado,
  });
}

class DelayByCareType {
  final String careType;
  final int count;
  final int totalDays;

  const DelayByCareType({
    required this.careType,
    this.count = 0,
    this.totalDays = 0,
  });

  double get averageDays => count > 0 ? totalDays / count : 0.0;
}
