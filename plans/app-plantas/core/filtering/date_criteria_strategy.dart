// Project imports:
import '../../database/tarefa_model.dart';

/// Strategy pattern para critérios de filtro por data
/// Implementa diferentes critérios de comparação de data para tarefas
abstract class DateCriteriaStrategy {
  /// Aplica o critério de filtro na lista de tarefas
  List<TarefaModel> apply(List<TarefaModel> tarefas, DateTime referenceDate);

  /// Nome do critério para cache/debug
  String get criteriaName;

  /// TTL específico para este critério (para otimização de cache)
  Duration get cacheTtl;
}

/// Critério para tarefas de hoje
class TodayCriteriaStrategy implements DateCriteriaStrategy {
  @override
  List<TarefaModel> apply(List<TarefaModel> tarefas, DateTime referenceDate) {
    final hoje =
        DateTime(referenceDate.year, referenceDate.month, referenceDate.day);

    return tarefas.where((tarefa) {
      final dataExecucao = DateTime(
        tarefa.dataExecucao.year,
        tarefa.dataExecucao.month,
        tarefa.dataExecucao.day,
      );
      return dataExecucao.isAtSameMomentAs(hoje) && !tarefa.concluida;
    }).toList();
  }

  @override
  String get criteriaName => 'today';

  @override
  Duration get cacheTtl => const Duration(hours: 6);
}

/// Critério para tarefas atrasadas
class OverdueCriteriaStrategy implements DateCriteriaStrategy {
  @override
  List<TarefaModel> apply(List<TarefaModel> tarefas, DateTime referenceDate) {
    final hoje =
        DateTime(referenceDate.year, referenceDate.month, referenceDate.day);

    return tarefas.where((tarefa) {
      final dataExecucao = DateTime(
        tarefa.dataExecucao.year,
        tarefa.dataExecucao.month,
        tarefa.dataExecucao.day,
      );
      return dataExecucao.isBefore(hoje) && !tarefa.concluida;
    }).toList();
  }

  @override
  String get criteriaName => 'overdue';

  @override
  Duration get cacheTtl => const Duration(hours: 2);
}

/// Critério para tarefas futuras
class FutureCriteriaStrategy implements DateCriteriaStrategy {
  @override
  List<TarefaModel> apply(List<TarefaModel> tarefas, DateTime referenceDate) {
    final hoje =
        DateTime(referenceDate.year, referenceDate.month, referenceDate.day);

    return tarefas.where((tarefa) {
      final dataExecucao = DateTime(
        tarefa.dataExecucao.year,
        tarefa.dataExecucao.month,
        tarefa.dataExecucao.day,
      );
      return dataExecucao.isAfter(hoje);
    }).toList();
  }

  @override
  String get criteriaName => 'future';

  @override
  Duration get cacheTtl => const Duration(hours: 4);
}

/// Factory para criar estratégias de critério de data
class DateCriteriaFactory {
  static final DateCriteriaStrategy today = TodayCriteriaStrategy();
  static final DateCriteriaStrategy overdue = OverdueCriteriaStrategy();
  static final DateCriteriaStrategy future = FutureCriteriaStrategy();

  /// Obter estratégia por nome
  static DateCriteriaStrategy? byName(String name) {
    switch (name.toLowerCase()) {
      case 'today':
        return today;
      case 'overdue':
        return overdue;
      case 'future':
        return future;
      default:
        return null;
    }
  }

  /// Listar todas as estratégias disponíveis
  static List<DateCriteriaStrategy> get allStrategies =>
      [today, overdue, future];
}
