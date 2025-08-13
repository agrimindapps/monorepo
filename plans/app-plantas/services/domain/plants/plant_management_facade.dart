// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../database/planta_config_model.dart';
import '../../../database/planta_model.dart';
import '../../../repository/planta_config_repository.dart';
import '../tasks/simple_task_service.dart';
import '../tasks/task_operations_service.dart';
import 'plant_data_manager_service.dart';

/// Facade que simplifica operações complexas de gerenciamento de plantas
/// Esconde a complexidade de múltiplos services especializados
class PlantManagementFacade {
  static PlantManagementFacade? _instance;
  static PlantManagementFacade get instance =>
      _instance ??= PlantManagementFacade._();
  PlantManagementFacade._();

  // Services especializados
  final PlantDataManagerService _dataManager = PlantDataManagerService.instance;
  final TaskOperationsService _taskOperations = TaskOperationsService.instance;
  final PlantaConfigRepository _configRepository =
      PlantaConfigRepository.instance;

  bool _isInitialized = false;

  /// Inicializar facade
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Future.wait([
      _dataManager.initialize(),
      _taskOperations.initialize(),
      _configRepository.initialize(),
    ]);

    _isInitialized = true;
  }

  /// Criar planta completa com configurações e tarefas iniciais
  Future<PlantCreationResult> createCompletePlant({
    required PlantaModel planta,
    required PlantaConfigModel config,
  }) async {
    await initialize();

    try {
      // 1. Criar planta
      final plantResult = await _dataManager.createPlanta(planta);
      if (!plantResult.success) {
        return PlantCreationResult(
          success: false,
          error: plantResult.error,
        );
      }

      final plantaId = plantResult.plantaId!;

      // 2. Criar configuração
      final configWithPlantaId = config.copyWith(plantaId: plantaId);
      await _configRepository.create(configWithPlantaId);

      // 3. Criar tarefas iniciais
      final now = DateTime.now();
      await SimpleTaskService.instance.createInitialTasksForPlant(
        plantaId: plantaId,
        aguaAtiva: config.aguaAtiva,
        intervaloRegaDias: config.intervaloRegaDias,
        primeiraRega: config.aguaAtiva ? now : null,
        aduboAtivo: config.aduboAtivo,
        intervaloAdubacaoDias: config.intervaloAdubacaoDias,
        primeiraAdubacao: config.aduboAtivo ? now : null,
        banhoSolAtivo: config.banhoSolAtivo,
        intervaloBanhoSolDias: config.intervaloBanhoSolDias,
        primeiroBanhoSol: config.banhoSolAtivo ? now : null,
        inspecaoPragasAtiva: config.inspecaoPragasAtiva,
        intervaloInspecaoPragasDias: config.intervaloInspecaoPragasDias,
        primeiraInspecaoPragas: config.inspecaoPragasAtiva ? now : null,
        podaAtiva: config.podaAtiva,
        intervaloPodaDias: config.intervaloPodaDias,
        primeiraPoda: config.podaAtiva ? now : null,
        replantarAtivo: config.replantarAtivo,
        intervaloReplantarDias: config.intervaloReplantarDias,
        primeiroReplantar: config.replantarAtivo ? now : null,
      );

      debugPrint(
          '✅ PlantManagementFacade: Planta criada com configurações e tarefas');

      return PlantCreationResult(
        success: true,
        plantaId: plantaId,
        message: 'Planta criada com sucesso',
      );
    } catch (e) {
      return PlantCreationResult(
        success: false,
        error: 'Erro ao criar planta completa: $e',
      );
    }
  }

  /// Atualizar configurações de cuidados da planta
  Future<PlantUpdateResult> updatePlantCareConfig({
    required String plantaId,
    required PlantaConfigModel newConfig,
  }) async {
    await initialize();

    try {
      // Atualizar configuração
      await _configRepository.update(newConfig.id, newConfig);

      // Nota: As tarefas futuras usarão automaticamente as novas configurações
      // via SimpleTaskService.getPlantIntervals()

      return PlantUpdateResult(
        success: true,
        message: 'Configurações de cuidados atualizadas',
      );
    } catch (e) {
      return PlantUpdateResult(
        success: false,
        error: 'Erro ao atualizar configurações: $e',
      );
    }
  }

  /// Obter plantas que precisam de atenção
  Future<List<PlantSummary>> getPlantsNeedingAttention() async {
    await initialize();

    try {
      final plantas = await _taskOperations.getPlantasComTarefasPendentes();
      final tarefasPendentes = await _taskOperations.getTarefasPendentes();
      final tarefasAtrasadas = await _taskOperations.getTarefasAtrasadas();

      // Combinar informações
      final plantSummaries = <PlantSummary>[];

      for (final planta in plantas) {
        final tarefasPlanta =
            tarefasPendentes.where((t) => t['plantaId'] == planta.id).toList();
        final tarefasAtrasadasPlanta =
            tarefasAtrasadas.where((t) => t['plantaId'] == planta.id).toList();

        plantSummaries.add(PlantSummary(
          planta: planta,
          tarefasPendentes: tarefasPlanta.length,
          tarefasAtrasadas: tarefasAtrasadasPlanta.length,
          proximaTarefa: tarefasPlanta.isNotEmpty ? tarefasPlanta.first : null,
        ));
      }

      // Ordenar por urgência (atrasadas primeiro)
      plantSummaries.sort((a, b) {
        if (a.tarefasAtrasadas != b.tarefasAtrasadas) {
          return b.tarefasAtrasadas.compareTo(a.tarefasAtrasadas);
        }
        return b.tarefasPendentes.compareTo(a.tarefasPendentes);
      });

      return plantSummaries;
    } catch (e) {
      debugPrint(
          '❌ PlantManagementFacade: Erro ao buscar plantas que precisam de atenção: $e');
      return [];
    }
  }

  /// Completar tarefa de forma simplificada
  Future<TaskCompletionResult> completeTask({
    required String taskId,
    String? observacoes,
  }) async {
    await initialize();

    try {
      final result = await _taskOperations.concluirTarefa(taskId,
          observacoes: observacoes);

      return TaskCompletionResult(
        success: result.success,
        message: result.message,
        error: result.error,
      );
    } catch (e) {
      return TaskCompletionResult(
        success: false,
        error: 'Erro ao completar tarefa: $e',
      );
    }
  }

  /// Obter dashboard de estatísticas
  Future<PlantDashboard> getDashboard() async {
    await initialize();

    try {
      final stats = await _dataManager.getComprehensiveStatistics();
      final plantsNeedingAttention = await getPlantsNeedingAttention();

      return PlantDashboard(
        totalPlantas: stats['plantas']['total'] ?? 0,
        plantasComCuidados: stats['plantas']['precisaCuidados'] ?? 0,
        tarefasPendentes: stats['tarefas']['pendentes'] ?? 0,
        tarefasAtrasadas: stats['tarefas']['atrasadas'] ?? 0,
        plantasUrgentes: plantsNeedingAttention.take(5).toList(),
      );
    } catch (e) {
      debugPrint('❌ PlantManagementFacade: Erro ao gerar dashboard: $e');
      return PlantDashboard.empty();
    }
  }
}

/// Resultado de criação de planta
class PlantCreationResult {
  final bool success;
  final String? plantaId;
  final String? error;
  final String? message;

  PlantCreationResult({
    required this.success,
    this.plantaId,
    this.error,
    this.message,
  });
}

/// Resultado de atualização de planta
class PlantUpdateResult {
  final bool success;
  final String? error;
  final String? message;

  PlantUpdateResult({
    required this.success,
    this.error,
    this.message,
  });
}

/// Resultado de conclusão de tarefa
class TaskCompletionResult {
  final bool success;
  final String? error;
  final String? message;

  TaskCompletionResult({
    required this.success,
    this.error,
    this.message,
  });
}

/// Resumo de planta com tarefas
class PlantSummary {
  final PlantaModel planta;
  final int tarefasPendentes;
  final int tarefasAtrasadas;
  final Map<String, dynamic>? proximaTarefa;

  PlantSummary({
    required this.planta,
    required this.tarefasPendentes,
    required this.tarefasAtrasadas,
    this.proximaTarefa,
  });
}

/// Dashboard de plantas
class PlantDashboard {
  final int totalPlantas;
  final int plantasComCuidados;
  final int tarefasPendentes;
  final int tarefasAtrasadas;
  final List<PlantSummary> plantasUrgentes;

  PlantDashboard({
    required this.totalPlantas,
    required this.plantasComCuidados,
    required this.tarefasPendentes,
    required this.tarefasAtrasadas,
    required this.plantasUrgentes,
  });

  factory PlantDashboard.empty() {
    return PlantDashboard(
      totalPlantas: 0,
      plantasComCuidados: 0,
      tarefasPendentes: 0,
      tarefasAtrasadas: 0,
      plantasUrgentes: [],
    );
  }
}
