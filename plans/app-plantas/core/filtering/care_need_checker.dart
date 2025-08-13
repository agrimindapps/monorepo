// Project imports:
import '../../database/planta_model.dart';
import '../../database/tarefa_model.dart';

/// Interface para implementar Chain of Responsibility pattern
/// para verificar se uma planta precisa de cuidados específicos hoje
///
/// Esta interface permite criar checkers modulares e extensíveis
/// para diferentes tipos de validação de cuidados de plantas
abstract class CareNeedChecker {
  /// Próximo checker na cadeia
  CareNeedChecker? _nextChecker;

  /// Definir o próximo checker na cadeia
  CareNeedChecker setNext(CareNeedChecker checker) {
    _nextChecker = checker;
    return checker;
  }

  /// Verificar se a planta precisa de cuidado baseado na lógica específica
  /// Retorna true se esta regra indica que a planta precisa de cuidado
  bool checkCareNeed(
      PlantaModel planta, List<TarefaModel> tarefas, DateTime referenceDate);

  /// Processar a verificação na cadeia
  /// Verifica a lógica atual e passa para o próximo checker se necessário
  bool process(
      PlantaModel planta, List<TarefaModel> tarefas, DateTime referenceDate) {
    // Verifica esta regra
    if (checkCareNeed(planta, tarefas, referenceDate)) {
      return true;
    }

    // Se não atende esta regra, passa para o próximo checker
    if (_nextChecker != null) {
      return _nextChecker!.process(planta, tarefas, referenceDate);
    }

    // Nenhuma regra atendida
    return false;
  }
}

/// Factory para criar cadeia de checkers configurada
class CareNeedCheckerChain {
  /// Criar cadeia padrão de checkers de cuidado
  static CareNeedChecker createDefaultChain() {
    final overdueTasks = OverdueTaskChecker();
    final todayTasks = TodayTaskChecker();
    final urgentCare = UrgentCareChecker();
    final periodicCare = PeriodicCareChecker();
    final abandonedPlant = AbandonedPlantChecker();
    final criticalCondition = CriticalConditionChecker();

    // Configurar cadeia: crítico -> urgente -> atrasado -> hoje -> periódico -> abandonado
    criticalCondition
        .setNext(urgentCare)
        .setNext(overdueTasks)
        .setNext(todayTasks)
        .setNext(periodicCare)
        .setNext(abandonedPlant);

    return criticalCondition;
  }

  /// Criar cadeia personalizada baseada em tipos de cuidado
  static CareNeedChecker createCustomChain(List<CareNeedChecker> checkers) {
    if (checkers.isEmpty) {
      throw ArgumentError('Lista de checkers não pode estar vazia');
    }

    CareNeedChecker first = checkers.first;
    CareNeedChecker current = first;

    for (int i = 1; i < checkers.length; i++) {
      current = current.setNext(checkers[i]);
    }

    return first;
  }
}

/// Checker para tarefas atrasadas
class OverdueTaskChecker extends CareNeedChecker {
  @override
  bool checkCareNeed(
      PlantaModel planta, List<TarefaModel> tarefas, DateTime referenceDate) {
    return tarefas.any((tarefa) =>
        !tarefa.concluida && tarefa.dataExecucao.isBefore(referenceDate));
  }
}

/// Checker para tarefas que devem ser feitas hoje
class TodayTaskChecker extends CareNeedChecker {
  @override
  bool checkCareNeed(
      PlantaModel planta, List<TarefaModel> tarefas, DateTime referenceDate) {
    final today =
        DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    final tomorrow = today.add(const Duration(days: 1));

    return tarefas.any((tarefa) =>
        !tarefa.concluida &&
        tarefa.dataExecucao
            .isAfter(today.subtract(const Duration(milliseconds: 1))) &&
        tarefa.dataExecucao.isBefore(tomorrow));
  }
}

/// Checker para cuidados urgentes (baseado em tipo crítico)
class UrgentCareChecker extends CareNeedChecker {
  @override
  bool checkCareNeed(
      PlantaModel planta, List<TarefaModel> tarefas, DateTime referenceDate) {
    // Tipos de cuidado considerados urgentes
    final urgentCares = ['rega', 'tratamento', 'emergencia'];

    return tarefas.any((tarefa) =>
        !tarefa.concluida &&
        urgentCares.contains(tarefa.tipoCuidado.toLowerCase()) &&
        tarefa.dataExecucao
            .isBefore(referenceDate.add(const Duration(days: 2))));
  }
}

/// Checker para cuidados periódicos que estão no prazo
class PeriodicCareChecker extends CareNeedChecker {
  @override
  bool checkCareNeed(
      PlantaModel planta, List<TarefaModel> tarefas, DateTime referenceDate) {
    final nextWeek = referenceDate.add(const Duration(days: 7));

    return tarefas.any((tarefa) =>
        !tarefa.concluida &&
        tarefa.dataExecucao
            .isAfter(referenceDate.subtract(const Duration(days: 1))) &&
        tarefa.dataExecucao.isBefore(nextWeek));
  }
}

/// Checker para plantas abandonadas (muito tempo sem cuidado)
class AbandonedPlantChecker extends CareNeedChecker {
  @override
  bool checkCareNeed(
      PlantaModel planta, List<TarefaModel> tarefas, DateTime referenceDate) {
    // Verificar se não há tarefas concluídas nos últimos 30 dias
    final monthAgo = referenceDate.subtract(const Duration(days: 30));

    final hasRecentCompletedTasks = tarefas.any(
        (tarefa) => tarefa.concluida && tarefa.dataExecucao.isAfter(monthAgo));

    // Se não tem tarefas concluídas recentes, considera que precisa de cuidado
    return !hasRecentCompletedTasks && tarefas.isNotEmpty;
  }
}

/// Checker para condições críticas da planta
class CriticalConditionChecker extends CareNeedChecker {
  @override
  bool checkCareNeed(
      PlantaModel planta, List<TarefaModel> tarefas, DateTime referenceDate) {
    // Verificar se há tarefas críticas (relacionadas a saúde) atrasadas
    final criticalTasks = ['rega', 'poda', 'tratamento', 'transplante'];

    return tarefas.any((tarefa) =>
        !tarefa.concluida &&
        criticalTasks.contains(tarefa.tipoCuidado.toLowerCase()) &&
        tarefa.dataExecucao
            .isBefore(referenceDate.subtract(const Duration(days: 3))));
  }
}
