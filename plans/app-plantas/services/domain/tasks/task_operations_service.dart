// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../database/planta_model.dart';
import '../../../database/tarefa_model.dart';
import '../../../repository/planta_repository.dart';
import '../../../repository/tarefa_repository.dart';
import 'simple_task_service.dart';

/// Service unificado para operações de tarefas
/// Consolida PlantasTaskService e TarefasManagementService
class TaskOperationsService {
  static TaskOperationsService? _instance;
  static TaskOperationsService get instance =>
      _instance ??= TaskOperationsService._();
  TaskOperationsService._();

  // Repositories
  final TarefaRepository _tarefaRepository = TarefaRepository.instance;
  final PlantaRepository _plantaRepository = PlantaRepository.instance;

  bool _isInitialized = false;

  /// Inicializar service
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _tarefaRepository.initialize();
    _isInitialized = true;
  }

  /// Buscar tarefas pendentes (substituindo PlantasTaskService.getTarefasPendentes)
  Future<List<Map<String, dynamic>>> getTarefasPendentes() async {
    await initialize();

    try {
      final tarefas = await SimpleTaskService.instance.getTodayTasks();
      final tarefasPendentes =
          tarefas.where((tarefa) => !tarefa.concluida).toList();

      // Conversão padronizada para compatibilidade com widgets
      return _convertTarefasToMap(tarefasPendentes);
    } catch (e) {
      debugPrint(
          '❌ TaskOperationsService: Erro ao buscar tarefas pendentes: $e');
      return [];
    }
  }

  /// Buscar tarefas atrasadas
  Future<List<Map<String, dynamic>>> getTarefasAtrasadas() async {
    await initialize();

    try {
      final tarefas = await SimpleTaskService.instance.getOverdueTasks();
      return _convertTarefasToMap(tarefas);
    } catch (e) {
      debugPrint(
          '❌ TaskOperationsService: Erro ao buscar tarefas atrasadas: $e');
      return [];
    }
  }

  /// Marcar tarefa como concluída com validação avançada
  /// (substituindo TarefasManagementService.concluirTarefa)
  Future<TaskOperationResult> concluirTarefa(String tarefaId,
      {String? observacoes}) async {
    await initialize();

    try {
      // Buscar tarefa
      final tarefa = await _tarefaRepository.findById(tarefaId);
      if (tarefa == null) {
        return TaskOperationResult(
          success: false,
          error: 'Tarefa não encontrada',
        );
      }

      // Validar se tarefa pode ser concluída
      if (tarefa.concluida) {
        return TaskOperationResult(
          success: false,
          error: 'Tarefa já está concluída',
        );
      }

      // Obter configuração da planta para intervalo correto
      final intervalos =
          await SimpleTaskService.instance.getPlantIntervals(tarefa.plantaId);
      final intervalo = intervalos[tarefa.tipoCuidado] ?? 7;

      // Completar tarefa usando SimpleTaskService
      await SimpleTaskService.instance
          .completeTask(tarefaId, intervalo, observacoes: observacoes);

      return TaskOperationResult(
        success: true,
        message: 'Tarefa concluída com sucesso',
      );
    } catch (e) {
      return TaskOperationResult(
        success: false,
        error: 'Erro ao concluir tarefa: $e',
      );
    }
  }

  /// Buscar plantas que precisam de cuidados
  Future<List<PlantaModel>> getPlantasComTarefasPendentes() async {
    await initialize();

    try {
      final todayTasks = await SimpleTaskService.instance.getTodayTasks();
      final overdueTasks = await SimpleTaskService.instance.getOverdueTasks();

      final plantaIds = {
        ...todayTasks.where((t) => !t.concluida).map((t) => t.plantaId),
        ...overdueTasks.where((t) => !t.concluida).map((t) => t.plantaId)
      };

      if (plantaIds.isEmpty) return [];

      return await _plantaRepository.findByIds(plantaIds.toList());
    } catch (e) {
      debugPrint(
          '❌ TaskOperationsService: Erro ao buscar plantas com tarefas: $e');
      return [];
    }
  }

  /// Obter estatísticas de tarefas
  Future<Map<String, int>> getTaskStatistics() async {
    await initialize();

    try {
      final todayTasks = await SimpleTaskService.instance.getTodayTasks();
      final overdueTasks = await SimpleTaskService.instance.getOverdueTasks();
      final completedTasks = todayTasks.where((t) => t.concluida).toList();

      return {
        'total_hoje': todayTasks.length,
        'pendentes': todayTasks.where((t) => !t.concluida).length,
        'concluidas': completedTasks.length,
        'atrasadas': overdueTasks.length,
        'plantas_afetadas': {
          ...todayTasks.map((t) => t.plantaId),
          ...overdueTasks.map((t) => t.plantaId)
        }.length,
      };
    } catch (e) {
      debugPrint('❌ TaskOperationsService: Erro ao calcular estatísticas: $e');
      return {};
    }
  }

  /// Converter TarefaModel para Map (padronizado)
  List<Map<String, dynamic>> _convertTarefasToMap(List<TarefaModel> tarefas) {
    return tarefas
        .map((tarefa) => {
              'id': tarefa.id,
              'plantaId': tarefa.plantaId,
              'tipo': tarefa.tipoCuidado,
              'tipoCuidado': tarefa.tipoCuidado,
              'dataLimite': tarefa.dataExecucao,
              'dataExecucao': tarefa.dataExecucao,
              'concluida': tarefa.concluida,
              'observacoes': tarefa.observacoes,
              'proximaData': tarefa.dataExecucao,
              'isAtrasada': tarefa.isAtrasada,
              'isParaHoje': tarefa.isParaHoje,
              'tipoCuidadoNome': tarefa.tipoCuidadoNome,
            })
        .toList();
  }
}

/// Resultado de operação de tarefa
class TaskOperationResult {
  final bool success;
  final String? error;
  final String? message;

  TaskOperationResult({
    required this.success,
    this.error,
    this.message,
  });
}
