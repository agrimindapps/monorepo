// Project imports:
import '../../database/tarefa_model.dart';
import '../extensions/datetime_extensions.dart';

/// Interface para critérios de filtro de tarefas
/// Implementa Strategy pattern para diferentes tipos de filtro por data
abstract class TarefaFilterCriteria {
  /// Aplica filtro na tarefa individual
  bool apply(TarefaModel tarefa);

  /// Descrição legível do filtro
  String get description;

  /// Cache key para otimização de performance
  String get cacheKey;
}

/// Critério para tarefas de hoje (pendentes)
class TodayTasksCriteria implements TarefaFilterCriteria {
  const TodayTasksCriteria();

  @override
  bool apply(TarefaModel tarefa) {
    if (tarefa.concluida) return false;
    return tarefa.dataExecucao.isToday;
  }

  @override
  String get description => 'Tarefas para hoje (pendentes)';

  @override
  String get cacheKey => 'today_tasks';
}

/// Critério para tarefas futuras (pendentes)
class FutureTasksCriteria implements TarefaFilterCriteria {
  const FutureTasksCriteria();

  @override
  bool apply(TarefaModel tarefa) {
    if (tarefa.concluida) return false;
    return tarefa.dataExecucao.isAfterToday;
  }

  @override
  String get description => 'Tarefas futuras (pendentes)';

  @override
  String get cacheKey => 'future_tasks';
}

/// Critério para tarefas atrasadas (pendentes)
class OverdueTasksCriteria implements TarefaFilterCriteria {
  const OverdueTasksCriteria();

  @override
  bool apply(TarefaModel tarefa) {
    if (tarefa.concluida) return false;
    return tarefa.dataExecucao.isBeforeToday;
  }

  @override
  String get description => 'Tarefas atrasadas (pendentes)';

  @override
  String get cacheKey => 'overdue_tasks';
}

/// Critério para tarefas pendentes (todas as não concluídas)
class PendingTasksCriteria implements TarefaFilterCriteria {
  const PendingTasksCriteria();

  @override
  bool apply(TarefaModel tarefa) {
    return !tarefa.concluida;
  }

  @override
  String get description => 'Tarefas pendentes (todas não concluídas)';

  @override
  String get cacheKey => 'pending_tasks';
}

/// Critério para tarefas concluídas
class CompletedTasksCriteria implements TarefaFilterCriteria {
  const CompletedTasksCriteria();

  @override
  bool apply(TarefaModel tarefa) {
    return tarefa.concluida;
  }

  @override
  String get description => 'Tarefas concluídas';

  @override
  String get cacheKey => 'completed_tasks';
}

/// Critério para tarefas por planta específica
class PlantTasksCriteria implements TarefaFilterCriteria {
  const PlantTasksCriteria(this.plantaId);

  final String plantaId;

  @override
  bool apply(TarefaModel tarefa) {
    return tarefa.plantaId == plantaId;
  }

  @override
  String get description => 'Tarefas da planta $plantaId';

  @override
  String get cacheKey => 'plant_tasks_$plantaId';
}

/// Critério para tarefas por tipo de cuidado
class CareTypeTasksCriteria implements TarefaFilterCriteria {
  const CareTypeTasksCriteria(this.tipoCuidado);

  final String tipoCuidado;

  @override
  bool apply(TarefaModel tarefa) {
    return tarefa.tipoCuidado == tipoCuidado;
  }

  @override
  String get description => 'Tarefas de $tipoCuidado';

  @override
  String get cacheKey => 'care_type_tasks_$tipoCuidado';
}

/// Critério para tarefas em período específico
class PeriodTasksCriteria implements TarefaFilterCriteria {
  const PeriodTasksCriteria(this.inicio, this.fim);

  final DateTime inicio;
  final DateTime fim;

  @override
  bool apply(TarefaModel tarefa) {
    return tarefa.dataExecucao.isBetween(inicio, fim);
  }

  @override
  String get description =>
      'Tarefas de ${inicio.day}/${inicio.month} até ${fim.day}/${fim.month}';

  @override
  String get cacheKey =>
      'period_tasks_${inicio.toIso8601String()}_${fim.toIso8601String()}';
}

/// Critério composto para combinar múltiplos filtros
class CompositeCriteria implements TarefaFilterCriteria {
  const CompositeCriteria(this.criteria, {this.useAnd = true});

  final List<TarefaFilterCriteria> criteria;
  final bool useAnd; // true = AND, false = OR

  @override
  bool apply(TarefaModel tarefa) {
    if (criteria.isEmpty) return true;

    if (useAnd) {
      // Todos critérios devem ser verdadeiros
      return criteria.every((c) => c.apply(tarefa));
    } else {
      // Pelo menos um critério deve ser verdadeiro
      return criteria.any((c) => c.apply(tarefa));
    }
  }

  @override
  String get description {
    final operator = useAnd ? ' AND ' : ' OR ';
    return criteria.map((c) => c.description).join(operator);
  }

  @override
  String get cacheKey {
    final operator = useAnd ? '_AND_' : '_OR_';
    final keys = criteria.map((c) => c.cacheKey).join(operator);
    return 'composite$operator$keys';
  }
}

/// Factory para criar critérios pré-definidos
class TarefaFilterCriteriaFactory {
  // Critérios singleton para performance
  static const TodayTasksCriteria today = TodayTasksCriteria();
  static const FutureTasksCriteria future = FutureTasksCriteria();
  static const OverdueTasksCriteria overdue = OverdueTasksCriteria();
  static const PendingTasksCriteria pending = PendingTasksCriteria();
  static const CompletedTasksCriteria completed = CompletedTasksCriteria();

  /// Criar critério por planta
  static PlantTasksCriteria forPlant(String plantaId) =>
      PlantTasksCriteria(plantaId);

  /// Criar critério por tipo de cuidado
  static CareTypeTasksCriteria forCareType(String tipoCuidado) =>
      CareTypeTasksCriteria(tipoCuidado);

  /// Criar critério por período
  static PeriodTasksCriteria forPeriod(DateTime inicio, DateTime fim) =>
      PeriodTasksCriteria(inicio, fim);

  /// Criar critério composto com AND
  static CompositeCriteria and(List<TarefaFilterCriteria> criteria) =>
      CompositeCriteria(criteria, useAnd: true);

  /// Criar critério composto com OR
  static CompositeCriteria or(List<TarefaFilterCriteria> criteria) =>
      CompositeCriteria(criteria, useAnd: false);

  /// Critérios combinados frequentes

  /// Tarefas pendentes de hoje para uma planta específica
  static CompositeCriteria todayPendingForPlant(String plantaId) =>
      and([today, forPlant(plantaId)]);

  /// Tarefas atrasadas para uma planta específica
  static CompositeCriteria overdueForPlant(String plantaId) =>
      and([overdue, forPlant(plantaId)]);

  /// Tarefas de um tipo de cuidado específico que estão atrasadas
  static CompositeCriteria overdueCareType(String tipoCuidado) =>
      and([overdue, forCareType(tipoCuidado)]);

  /// Tarefas de hoje OU atrasadas (urgentes)
  static CompositeCriteria urgent() => or([today, overdue]);

  /// Tarefas urgentes para uma planta específica
  static CompositeCriteria urgentForPlant(String plantaId) =>
      and([urgent(), forPlant(plantaId)]);
}
