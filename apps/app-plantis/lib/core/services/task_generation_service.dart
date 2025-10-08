import 'package:core/core.dart';

import '../../features/tasks/domain/entities/task.dart' as task_entity;
import '../data/models/planta_config_model.dart';

/// Serviço central para geração automática de tarefas baseado na configuração das plantas
class TaskGenerationService {
  /// Mapeia tipos de cuidado para informações de exibição
  static const Map<String, Map<String, dynamic>> careTypeInfo = {
    'agua': {
      'title': 'Regar',
      'description': 'Verificar e regar conforme necessário',
      'icon': 'water_drop',
      'priority': 'medium',
    },
    'adubo': {
      'title': 'Adubar',
      'description': 'Aplicar fertilizante ou adubo',
      'icon': 'eco',
      'priority': 'medium',
    },
    'banho_sol': {
      'title': 'Banho de Sol',
      'description': 'Expor a planta ao sol adequado',
      'icon': 'wb_sunny',
      'priority': 'low',
    },
    'inspecao_pragas': {
      'title': 'Inspeção de Pragas',
      'description': 'Verificar folhas e caule em busca de pragas',
      'icon': 'search',
      'priority': 'high',
    },
    'poda': {
      'title': 'Poda',
      'description': 'Remover folhas secas e fazer poda necessária',
      'icon': 'content_cut',
      'priority': 'medium',
    },
    'replantar': {
      'title': 'Replantio',
      'description': 'Trocar vaso ou substrato',
      'icon': 'change_circle',
      'priority': 'high',
    },
  };

  /// Gera tarefas iniciais para uma planta recém-cadastrada
  ///
  /// [plantaId] - ID da planta para qual gerar as tarefas
  /// [config] - Configuração de cuidados da planta
  /// [plantingDate] - Data de plantio/cadastro (opcional, usa data atual se null)
  /// [userId] - ID do usuário proprietário
  ///
  /// Retorna lista de tarefas geradas ou falha em caso de erro
  Either<Failure, List<task_entity.Task>> generateInitialTasks({
    required String plantaId,
    required PlantaConfigModel config,
    DateTime? plantingDate,
    String? userId,
  }) {
    try {
      final baseDate = plantingDate ?? DateTime.now();
      final tasks = <task_entity.Task>[];
      for (final careType in config.activeCareTypes) {
        final interval = config.getIntervalForCareType(careType);
        final careInfo = careTypeInfo[careType];

        if (careInfo == null) continue;

        final taskDate = calculateNextTaskDate(
          baseDate: baseDate,
          intervalDays: interval,
          careType: careType,
        );

        final task = task_entity.Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          title: _getCareTypeDisplayName(careType),
          plantId: plantaId,
          type: _mapCareTypeToTaskType(careType),
          dueDate: taskDate,
          userId: userId,
          moduleName: 'plantis',
          isDirty: true,
        );

        tasks.add(task);
      }

      return Right(tasks);
    } catch (e) {
      return Left(
        ServerFailure('Erro ao gerar tarefas iniciais: ${e.toString()}'),
      );
    }
  }

  /// Gera próxima tarefa após conclusão de uma tarefa existente
  ///
  /// [completedTask] - Tarefa que foi concluída
  /// [completionDate] - Data em que a tarefa foi concluída
  /// [config] - Configuração atual da planta
  ///
  /// Retorna nova tarefa ou falha em caso de erro
  Either<Failure, task_entity.Task?> generateNextTask({
    required task_entity.Task completedTask,
    required DateTime completionDate,
    required PlantaConfigModel config,
  }) {
    try {
      final careType = _mapTaskTypeToCareType(completedTask.type) ?? 'agua';
      if (!config.isCareTypeActive(careType)) {
        return const Right(null); // Não gera nova tarefa se desabilitado
      }

      final interval = config.getIntervalForCareType(careType);
      final careInfo = careTypeInfo[careType];

      if (careInfo == null) {
        return Left(ValidationFailure('Tipo de cuidado inválido: $careType'));
      }

      final nextDate = calculateNextTaskDate(
        baseDate: completionDate,
        intervalDays: interval,
        careType: careType,
      );

      final nextTask = task_entity.Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        title: _getCareTypeDisplayName(careType),
        plantId: completedTask.plantId,
        type: _mapCareTypeToTaskType(careType),
        dueDate: nextDate,
        userId: completedTask.userId,
        moduleName: 'plantis',
        isDirty: true,
      );

      return Right(nextTask);
    } catch (e) {
      return Left(
        ServerFailure('Erro ao gerar próxima tarefa: ${e.toString()}'),
      );
    }
  }

  /// Calcula a próxima data para uma tarefa baseado no intervalo
  ///
  /// [baseDate] - Data base para o cálculo
  /// [intervalDays] - Intervalo em dias
  /// [careType] - Tipo de cuidado (opcional para ajustes específicos)
  ///
  /// Retorna a próxima data calculada
  DateTime calculateNextTaskDate({
    required DateTime baseDate,
    required int intervalDays,
    String? careType,
  }) {
    if (intervalDays <= 0) {
      throw ArgumentError('Intervalo deve ser maior que zero');
    }
    return baseDate.add(Duration(days: intervalDays));
  }

  /// Valida se uma tarefa pode ser gerada para determinada configuração
  ///
  /// [plantaId] - ID da planta
  /// [config] - Configuração da planta
  /// [careType] - Tipo de cuidado
  ///
  /// Retorna true se válida ou falha com detalhes do erro
  Either<Failure, bool> validateTaskGeneration({
    required String plantaId,
    required PlantaConfigModel config,
    required String careType,
  }) {
    if (plantaId.isEmpty) {
      return const Left(ValidationFailure('ID da planta é obrigatório'));
    }

    if (!careTypeInfo.containsKey(careType)) {
      return Left(ValidationFailure('Tipo de cuidado inválido: $careType'));
    }

    if (!config.isCareTypeActive(careType)) {
      return Left(ValidationFailure('Tipo de cuidado desabilitado: $careType'));
    }

    final interval = config.getIntervalForCareType(careType);
    if (interval <= 0) {
      return Left(
        ValidationFailure('Intervalo inválido para $careType: $interval'),
      );
    }

    return const Right(true);
  }

  /// Calcula estatísticas de tarefas que serão geradas
  ///
  /// [config] - Configuração da planta
  /// [periodDays] - Período em dias para calcular (padrão 30 dias)
  ///
  /// Retorna mapa com estatísticas por tipo de cuidado
  Map<String, int> calculateTaskStatistics({
    required PlantaConfigModel config,
    int periodDays = 30,
  }) {
    final statistics = <String, int>{};

    for (final careType in config.activeCareTypes) {
      final interval = config.getIntervalForCareType(careType);
      if (interval > 0) {
        final tasksCount = (periodDays / interval).ceil();
        statistics[careType] = tasksCount;
      }
    }

    return statistics;
  }

  /// Obtém informações de exibição para um tipo de cuidado
  ///
  /// [careType] - Tipo de cuidado
  ///
  /// Retorna informações ou null se não encontrado
  Map<String, dynamic>? getCareTypeInfo(String careType) {
    return careTypeInfo[careType];
  }

  /// Lista todos os tipos de cuidado suportados
  List<String> get supportedCareTypes => careTypeInfo.keys.toList();

  /// Verifica se um tipo de cuidado é suportado
  bool isCareTypeSupported(String careType) {
    return careTypeInfo.containsKey(careType);
  }

  /// Sugere intervalo otimizado para um tipo de cuidado
  int suggestOptimalInterval(String careType, {DateTime? currentDate}) {
    // Intervalos padrão por tipo de cuidado
    const Map<String, int> defaultIntervals = {
      'agua': 3,
      'adubo': 30,
      'banho_sol': 7,
      'inspecao_pragas': 14,
      'poda': 60,
      'troca_substrato': 180,
    };
    return defaultIntervals[careType] ?? 7;
  }

  /// Valida se um intervalo é adequado para um tipo de cuidado
  bool isValidIntervalForCareType(int intervalDays, String careType) {
    return intervalDays > 0 && intervalDays <= 365;
  }

  /// Calcula múltiplas datas futuras para preview
  List<DateTime> previewNextDates({
    required DateTime baseDate,
    required int intervalDays,
    required String careType,
    int count = 5,
  }) {
    final List<DateTime> dates = [];
    DateTime currentDate = baseDate;
    for (int i = 0; i < count; i++) {
      currentDate = currentDate.add(Duration(days: intervalDays));
      dates.add(currentDate);
    }
    return dates;
  }

  /// Maps TaskType enum to care type string
  String? _mapTaskTypeToCareType(task_entity.TaskType taskType) {
    switch (taskType) {
      case task_entity.TaskType.watering:
        return 'agua';
      case task_entity.TaskType.fertilizing:
        return 'adubo';
      case task_entity.TaskType.pruning:
        return 'poda';
      case task_entity.TaskType.repotting:
        return 'replantar';
      case task_entity.TaskType.sunlight:
        return 'banho_sol';
      case task_entity.TaskType.pestInspection:
        return 'inspecao_pragas';
      default:
        return 'agua';
    }
  }

  /// Maps legacy care type string to modern TaskType enum
  task_entity.TaskType _mapCareTypeToTaskType(String careType) {
    switch (careType.toLowerCase()) {
      case 'regar':
      case 'rega':
        return task_entity.TaskType.watering;
      case 'adubar':
      case 'adubo':
      case 'fertilizar':
        return task_entity.TaskType.fertilizing;
      case 'podar':
      case 'poda':
        return task_entity.TaskType.pruning;
      case 'replantar':
      case 'replantio':
        return task_entity.TaskType.repotting;
      case 'limpar':
      case 'limpeza':
        return task_entity.TaskType.cleaning;
      case 'pulverizar':
        return task_entity.TaskType.spraying;
      case 'sol':
        return task_entity.TaskType.sunlight;
      case 'sombra':
        return task_entity.TaskType.shade;
      case 'inspecao_pragas':
      case 'inspeção':
        return task_entity.TaskType.pestInspection;
      default:
        return task_entity.TaskType.custom;
    }
  }

  /// Gets display name for care type
  String _getCareTypeDisplayName(String careType) {
    final taskType = _mapCareTypeToTaskType(careType);
    return taskType.displayName;
  }
}
