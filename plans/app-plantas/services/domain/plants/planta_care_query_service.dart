// Dart imports:
import 'dart:async';

import '../../../core/streams/stream_manager.dart';
// Project imports:
import '../../../database/planta_model.dart';
import '../../../database/tarefa_model.dart';
import '../../../repository/planta_config_repository.dart';
import '../../../repository/planta_repository.dart';
import '../tasks/simple_task_service.dart';

/// Serviço para consultas relacionadas a cuidados de plantas
/// Responsabilidade: Streams e queries de plantas baseadas em cuidados
/// OTIMIZADO: Uso de StreamLifecycleManager para evitar memory leaks
class PlantaCareQueryService with StreamLifecycleManager {
  static PlantaCareQueryService? _instance;
  static PlantaCareQueryService get instance =>
      _instance ??= PlantaCareQueryService._();

  final PlantaRepository _plantaRepository = PlantaRepository.instance;
  final PlantaConfigRepository _configRepository =
      PlantaConfigRepository.instance;
  final SimpleTaskService _taskService = SimpleTaskService.instance;

  PlantaCareQueryService._();

  /// Dispose para limpeza de recursos
  Future<void> dispose() async {
    await disposeStreams();
  }

  /// Stream de plantas com tipo específico de cuidado ativo
  /// OTIMIZADO: Usa createManagedAsyncMapStream para evitar memory leaks
  Stream<List<PlantaModel>> watchPlantsWithActiveCare(String careType) {
    return createManagedAsyncMapStream<List<PlantaModel>, List<PlantaModel>>(
      _plantaRepository.plantasStream,
      (plantas) async {
        await _configRepository.initialize();

        final plantasComCuidado = <PlantaModel>[];

        for (final planta in plantas) {
          final config = await _configRepository.findByPlantaId(planta.id);
          if (config != null && config.isCareTypeActive(careType)) {
            plantasComCuidado.add(planta);
          }
        }

        return plantasComCuidado;
      },
      streamKey: 'plants_with_active_care_$careType',
    );
  }

  /// Stream de plantas que precisam de tipo específico de cuidado hoje
  /// OTIMIZADO: Usa createManagedAsyncMapStream para evitar memory leaks
  Stream<List<PlantaModel>> watchPlantsNeedingCareToday(String careType) {
    return createManagedAsyncMapStream<List<Object>, List<PlantaModel>>(
      _taskService.todayTasksStream,
      (tarefas) async {
        final plantaIds = tarefas
            .cast<TarefaModel>()
            .where(
                (tarefa) => tarefa.tipoCuidado == careType && !tarefa.concluida)
            .map((tarefa) => tarefa.plantaId)
            .toSet();

        if (plantaIds.isEmpty) return <PlantaModel>[];

        return await _plantaRepository.findByIds(plantaIds.toList());
      },
      streamKey: 'plants_needing_care_today_$careType',
    );
  }

  /// Buscar plantas com múltiplos tipos de cuidado ativos
  Future<List<PlantaModel>> findPlantsWithMultipleCares(List<String> careTypes,
      {bool requireAll = false}) async {
    final plantas = await _plantaRepository.findAll();
    await _configRepository.initialize();

    final plantasComCuidados = <PlantaModel>[];

    for (final planta in plantas) {
      final config = await _configRepository.findByPlantaId(planta.id);
      if (config == null) continue;

      final activeCares =
          careTypes.where((care) => config.isCareTypeActive(care)).toList();

      if (requireAll) {
        if (activeCares.length == careTypes.length) {
          plantasComCuidados.add(planta);
        }
      } else {
        if (activeCares.isNotEmpty) {
          plantasComCuidados.add(planta);
        }
      }
    }

    return plantasComCuidados;
  }

  /// Buscar plantas por espaço com filtro de cuidado
  Future<List<PlantaModel>> findPlantsInSpaceWithCare(
    String espacoId,
    String careType,
  ) async {
    final plantasEspaco = await _plantaRepository.findByEspaco(espacoId);
    await _configRepository.initialize();

    final plantasComCuidado = <PlantaModel>[];

    for (final planta in plantasEspaco) {
      final config = await _configRepository.findByPlantaId(planta.id);
      if (config != null && config.isCareTypeActive(careType)) {
        plantasComCuidado.add(planta);
      }
    }

    return plantasComCuidado;
  }

  /// Buscar plantas com tarefas pendentes
  Future<List<PlantaModel>> findPlantsWithPendingTasks({
    String? careType,
    bool includeOverdue = true,
  }) async {
    await _taskService.initialize();

    final todayTasks = await _taskService.getTodayTasks();
    final overdueTasks =
        includeOverdue ? await _taskService.getOverdueTasks() : <TarefaModel>[];

    final allTasks = [...todayTasks, ...overdueTasks];

    final filteredTasks = careType != null
        ? allTasks
            .cast<TarefaModel>()
            .where((task) => task.tipoCuidado == careType && !task.concluida)
        : allTasks.cast<TarefaModel>().where((task) => !task.concluida);

    final plantaIds = filteredTasks.map((task) => task.plantaId).toSet();

    return await _plantaRepository.findByIds(plantaIds.toList());
  }

  /// Buscar plantas sem nenhum cuidado ativo
  Future<List<PlantaModel>> findPlantsWithoutActiveCares() async {
    final plantas = await _plantaRepository.findAll();
    await _configRepository.initialize();

    final plantasSemCuidado = <PlantaModel>[];

    for (final planta in plantas) {
      final config = await _configRepository.findByPlantaId(planta.id);
      if (config == null || config.activeCareTypes.isEmpty) {
        plantasSemCuidado.add(planta);
      }
    }

    return plantasSemCuidado;
  }

  /// Stream combinada de plantas que precisam de qualquer cuidado hoje
  /// OTIMIZADO: Usa createManagedAsyncMapStream para evitar memory leaks
  Stream<List<PlantaModel>> get watchPlantsNeedingAnyCareToday {
    return createManagedAsyncMapStream<List<Object>, List<PlantaModel>>(
      _taskService.todayTasksStream,
      (tarefas) async {
        final plantaIds = tarefas
            .cast<TarefaModel>()
            .where((tarefa) => !tarefa.concluida)
            .map((tarefa) => tarefa.plantaId)
            .toSet();

        if (plantaIds.isEmpty) return <PlantaModel>[];

        return await _plantaRepository.findByIds(plantaIds.toList());
      },
      streamKey: 'plants_needing_any_care_today',
    );
  }

  /// Obter estatísticas de debug sobre streams gerenciadas
  Map<String, dynamic> get debugInfo => {
        ...streamDebugInfo,
        'serviceName': 'PlantaCareQueryService',
        'managedStreams': [
          'plants_with_active_care_*',
          'plants_needing_care_today_*',
          'plants_needing_any_care_today',
        ],
      };

  /// Cancelar streams específicos por tipo de cuidado
  Future<void> cancelStreamsForCareType(String careType) async {
    await cancelStreamByKey('plants_with_active_care_$careType');
    await cancelStreamByKey('plants_needing_care_today_$careType');
  }

  /// Buscar plantas por nome com filtro de cuidado específico
  Future<List<PlantaModel>> searchPlantsWithCare(
    String query,
    String careType,
  ) async {
    final plantasEncontradas = await _plantaRepository.findByNome(query);
    await _configRepository.initialize();

    final plantasComCuidado = <PlantaModel>[];

    for (final planta in plantasEncontradas) {
      final config = await _configRepository.findByPlantaId(planta.id);
      if (config != null && config.isCareTypeActive(careType)) {
        plantasComCuidado.add(planta);
      }
    }

    return plantasComCuidado;
  }
}
