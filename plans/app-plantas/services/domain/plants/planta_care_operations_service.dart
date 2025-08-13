// Project imports:
import '../../../constants/care_type_const.dart';
import '../../../database/tarefa_model.dart';
import '../../../repository/planta_config_repository.dart';
import '../tasks/simple_task_service.dart';

/// Serviço para operações de conclusão de cuidados de plantas
/// Responsabilidade: Completar tarefas e gerenciar toggles de cuidados
class PlantaCareOperationsService {
  static PlantaCareOperationsService? _instance;
  static PlantaCareOperationsService get instance =>
      _instance ??= PlantaCareOperationsService._();

  final PlantaConfigRepository _configRepository =
      PlantaConfigRepository.instance;
  final SimpleTaskService _taskService = SimpleTaskService.instance;

  PlantaCareOperationsService._();

  /// Completar tarefa de cuidado específico
  Future<void> completeCareTast(
    String plantaId,
    String careType, {
    String? observacoes,
  }) async {
    await _taskService.initialize();

    // Buscar tarefa pendente para esta planta e tipo de cuidado
    final tarefasPlanta = await _taskService.getPendingPlantTasks(plantaId);
    final tarefa = tarefasPlanta.cast<TarefaModel>().firstWhere(
          (tarefa) => tarefa.tipoCuidado == careType && !tarefa.concluida,
          orElse: () => throw CareTaskNotFoundException(
              'Nenhuma tarefa de $careType pendente encontrada para a planta $plantaId'),
        );

    // Obter intervalo da configuração
    final intervalos = await _taskService.getPlantIntervals(plantaId);
    final intervalo = intervalos[careType] ?? _getDefaultInterval(careType);

    // Completar tarefa e agendar próxima
    await _taskService.completeTask(tarefa.id, intervalo,
        observacoes: observacoes);
  }

  /// Completar múltiplas tarefas de uma planta
  Future<Map<String, bool>> completeMultipleCares(
    String plantaId,
    List<String> careTypes, {
    String? observacoes,
  }) async {
    final results = <String, bool>{};

    for (final careType in careTypes) {
      try {
        await completeCareTast(plantaId, careType, observacoes: observacoes);
        results[careType] = true;
      } catch (e) {
        results[careType] = false;
      }
    }

    return results;
  }

  /// Ativar/desativar tipo de cuidado
  Future<void> toggleCareType(
      String plantaId, String careType, bool active) async {
    await _configRepository.initialize();

    if (active) {
      await _configRepository.activateCareType(plantaId, careType);
    } else {
      await _configRepository.deactivateCareType(plantaId, careType);
    }
  }

  /// Configurar múltiplos cuidados de uma vez
  Future<void> configurePlantCares(
    String plantaId,
    Map<String, bool> careConfig,
  ) async {
    await _configRepository.initialize();

    for (final entry in careConfig.entries) {
      await toggleCareType(plantaId, entry.key, entry.value);
    }
  }

  /// Ativar todos os cuidados básicos para uma planta
  Future<void> activateBasicCares(String plantaId) async {
    const basicCares = ['agua', 'adubo'];
    for (final care in basicCares) {
      await toggleCareType(plantaId, care, true);
    }
  }

  /// Ativar cuidados avançados para uma planta
  Future<void> activateAdvancedCares(String plantaId) async {
    const advancedCares = ['banho_sol', 'inspecao_pragas', 'poda', 'replantio'];
    for (final care in advancedCares) {
      await toggleCareType(plantaId, care, true);
    }
  }

  /// Desativar todos os cuidados de uma planta
  Future<void> deactivateAllCares(String plantaId) async {
    final allCares = CareType.values.map((type) => type.value).toList();
    for (final care in allCares) {
      await toggleCareType(plantaId, care, false);
    }
  }

  /// Obter status de todos os cuidados de uma planta
  Future<Map<String, bool>> getPlantCareStatus(String plantaId) async {
    await _configRepository.initialize();

    final config = await _configRepository.findByPlantaId(plantaId);
    if (config == null) {
      return {
        'agua': false,
        'adubo': false,
        'banho_sol': false,
        'inspecao_pragas': false,
        'poda': false,
        'replantio': false,
      };
    }

    return {
      'agua': config.aguaAtiva,
      'adubo': config.isCareTypeActive('adubo'),
      'banho_sol': config.isCareTypeActive('banho_sol'),
      'inspecao_pragas': config.isCareTypeActive('inspecao_pragas'),
      'poda': config.isCareTypeActive('poda'),
      'replantio': config.isCareTypeActive('replantio'),
    };
  }

  /// Completar todas as tarefas pendentes de uma planta para hoje
  Future<CareCompletionResult> completeAllPendingCares(
    String plantaId, {
    String? observacoes,
  }) async {
    await _taskService.initialize();

    final tarefasPendentes = await _taskService.getPendingPlantTasks(plantaId);
    final tarefasHoje = tarefasPendentes.cast<TarefaModel>().where((tarefa) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final taskDate = DateTime(
        tarefa.dataExecucao.year,
        tarefa.dataExecucao.month,
        tarefa.dataExecucao.day,
      );
      return taskDate.isBefore(today.add(const Duration(days: 1))) &&
          !tarefa.concluida;
    }).toList();

    final results = <String, bool>{};

    for (final tarefa in tarefasHoje) {
      try {
        await completeCareTast(tarefa.plantaId, tarefa.tipoCuidado,
            observacoes: observacoes);
        results[tarefa.tipoCuidado] = true;
      } catch (e) {
        results[tarefa.tipoCuidado] = false;
      }
    }

    return CareCompletionResult(
      totalTasks: tarefasHoje.length,
      completedTasks: results.values.where((success) => success).length,
      failedTasks: results.values.where((success) => !success).length,
      results: results,
    );
  }

  // Métodos auxiliares privados

  int _getDefaultInterval(String careType) {
    switch (careType) {
      case 'agua': // CareType.agua.value
        return 1;
      case 'adubo': // CareType.adubo.value
        return 7;
      case 'banho_sol': // CareType.banhoSol.value
        return 1;
      case 'inspecao_pragas': // CareType.inspecaoPragas.value
        return 7;
      case 'poda': // CareType.poda.value
        return 30;
      case 'replantio': // CareType.replantio.value
        return 365;
      default:
        return 7;
    }
  }
}

/// Resultado da operação de conclusão de cuidados
class CareCompletionResult {
  final int totalTasks;
  final int completedTasks;
  final int failedTasks;
  final Map<String, bool> results;

  const CareCompletionResult({
    required this.totalTasks,
    required this.completedTasks,
    required this.failedTasks,
    required this.results,
  });

  bool get allCompleted => failedTasks == 0;
  bool get hasFailures => failedTasks > 0;
  double get successRate =>
      totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;
}

/// Exceção para quando tarefa de cuidado não é encontrada
class CareTaskNotFoundException implements Exception {
  final String message;
  const CareTaskNotFoundException(this.message);

  @override
  String toString() => 'CareTaskNotFoundException: $message';
}
