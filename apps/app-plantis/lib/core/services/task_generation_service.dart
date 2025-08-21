import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../data/models/planta_config_model.dart';
import '../data/models/legacy/tarefa_model.dart';
import '../utils/task_schedule_calculator.dart';

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
  Either<Failure, List<TarefaModel>> generateInitialTasks({
    required String plantaId,
    required PlantaConfigModel config,
    DateTime? plantingDate,
    String? userId,
  }) {
    try {
      final baseDate = plantingDate ?? DateTime.now();
      final tasks = <TarefaModel>[];

      // Para cada tipo de cuidado ativo, gera a primeira tarefa
      for (final careType in config.activeCareTypes) {
        final interval = config.getIntervalForCareType(careType);
        final careInfo = careTypeInfo[careType];

        if (careInfo == null) continue;

        final taskDate = calculateNextTaskDate(
          baseDate: baseDate,
          intervalDays: interval,
          careType: careType,
        );

        final task = TarefaModel.create(
          userId: userId,
          plantaId: plantaId,
          tipoCuidado: careType,
          dataExecucao: taskDate,
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
  Either<Failure, TarefaModel?> generateNextTask({
    required TarefaModel completedTask,
    required DateTime completionDate,
    required PlantaConfigModel config,
  }) {
    try {
      final careType = completedTask.tipoCuidado;

      // Verifica se o tipo de cuidado ainda está ativo
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

      final nextTask = TarefaModel.create(
        userId: completedTask.userId,
        plantaId: completedTask.plantaId,
        tipoCuidado: careType,
        dataExecucao: nextDate,
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

    // Usar TaskScheduleCalculator para cálculos mais avançados
    return TaskScheduleCalculator.calculateNextDate(
      baseDate: baseDate,
      intervalDays: intervalDays,
      careType: careType ?? 'agua',
      skipWeekends: false, // Configurable in future
    );
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
      return Left(ValidationFailure('ID da planta é obrigatório'));
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
    return TaskScheduleCalculator.suggestOptimalInterval(
      careType: careType,
      currentDate: currentDate,
    );
  }

  /// Valida se um intervalo é adequado para um tipo de cuidado
  bool isValidIntervalForCareType(int intervalDays, String careType) {
    return TaskScheduleCalculator.isValidInterval(intervalDays, careType);
  }

  /// Obtém estatísticas de frequência para um tipo de cuidado
  TaskFrequencyStats getFrequencyStats({
    required int intervalDays,
    required String careType,
    int periodDays = 30,
  }) {
    return TaskScheduleCalculator.calculateFrequencyStats(
      intervalDays: intervalDays,
      careType: careType,
      periodDays: periodDays,
    );
  }

  /// Calcula múltiplas datas futuras para preview
  List<DateTime> previewNextDates({
    required DateTime baseDate,
    required int intervalDays,
    required String careType,
    int count = 5,
  }) {
    return TaskScheduleCalculator.calculateMultipleDates(
      baseDate: baseDate,
      intervalDays: intervalDays,
      careType: careType,
      count: count,
    );
  }
}
