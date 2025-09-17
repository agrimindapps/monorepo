import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/data/models/planta_config_model.dart';
import '../../../../core/services/task_generation_service.dart';
import '../../../plants/domain/repositories/plants_repository.dart';
import '../../data/models/task_model.dart';
import '../entities/task.dart' as task_entity;
import '../repositories/tasks_repository.dart';

/// Use case para completar uma tarefa e gerar automaticamente a próxima
///
/// Este use case é responsável por:
/// - Marcar a tarefa atual como concluída
/// - Gerar a próxima tarefa baseado na configuração da planta
/// - Manter atomicidade da operação
/// - Integrar com o sistema de sync offline-first
/// - Calcular próxima data baseado na frequência original
class CompleteTaskWithRegenerationUseCase
    implements
        UseCase<
          TaskCompletionWithRegenerationResult,
          CompleteTaskWithRegenerationParams
        > {
  final TasksRepository tasksRepository;
  final PlantsRepository plantsRepository;
  final TaskGenerationService taskGenerationService;

  CompleteTaskWithRegenerationUseCase({
    required this.tasksRepository,
    required this.plantsRepository,
    required this.taskGenerationService,
  });

  @override
  Future<Either<Failure, TaskCompletionWithRegenerationResult>> call(
    CompleteTaskWithRegenerationParams params,
  ) async {
    try {
      // Validação dos parâmetros
      final validationResult = _validateParams(params);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Buscar tarefa atual
      final currentTaskResult = await tasksRepository.getTaskById(
        params.taskId,
      );
      if (currentTaskResult.isLeft()) {
        return Left(
          currentTaskResult.fold(
            (failure) => failure,
            (_) => throw Exception(),
          ),
        );
      }

      final currentTask = currentTaskResult.fold(
        (_) => throw Exception(),
        (task) => task,
      );

      // Buscar dados da planta para obter configuração
      final plantResult = await plantsRepository.getPlantById(
        currentTask.plantId,
      );
      if (plantResult.isLeft()) {
        return Left(
          plantResult.fold((failure) => failure, (_) => throw Exception()),
        );
      }

      final plant = plantResult.fold(
        (_) => throw Exception(),
        (plant) => plant,
      );

      // Marcar tarefa atual como concluída
      final completedTask = currentTask.copyWithTaskData(
        status: task_entity.TaskStatus.completed,
        completedAt: params.completionDate,
        completionNotes: params.notes,
      );

      final updateResult = await tasksRepository.updateTask(completedTask);
      if (updateResult.isLeft()) {
        return Left(
          updateResult.fold((failure) => failure, (_) => throw Exception()),
        );
      }

      final savedCompletedTask = updateResult.fold(
        (_) => throw Exception(),
        (task) => task,
      );

      // Gerar próxima tarefa se a planta tem configuração
      task_entity.Task? nextTask;
      if (plant.config != null &&
          _shouldGenerateNextTask(currentTask, plant.config)) {
        final nextTaskResult = await _generateNextTask(
          currentTask,
          params.completionDate,
          plant,
        );
        if (nextTaskResult.isRight()) {
          nextTask = nextTaskResult.fold((_) => null, (task) => task);
        }
      }

      return Right(
        TaskCompletionWithRegenerationResult(
          completedTask: savedCompletedTask,
          nextTask: nextTask,
          regenerationSuccessful: nextTask != null,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure('Erro inesperado ao completar tarefa: ${e.toString()}'),
      );
    }
  }

  /// Valida os parâmetros de entrada
  ValidationFailure? _validateParams(
    CompleteTaskWithRegenerationParams params,
  ) {
    if (params.taskId.trim().isEmpty) {
      return const ValidationFailure('ID da tarefa é obrigatório');
    }

    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 1));

    if (params.completionDate.isAfter(maxFutureDate)) {
      return const ValidationFailure(
        'Data de conclusão não pode ser mais de 1 dia no futuro',
      );
    }

    final minPastDate = now.subtract(const Duration(days: 90));
    if (params.completionDate.isBefore(minPastDate)) {
      return const ValidationFailure(
        'Data de conclusão não pode ser mais de 90 dias no passado',
      );
    }

    if (params.notes != null && params.notes!.length > 500) {
      return const ValidationFailure(
        'Observações não podem ter mais de 500 caracteres',
      );
    }

    return null;
  }

  /// Determina se deve gerar próxima tarefa baseado na configuração
  bool _shouldGenerateNextTask(
    task_entity.Task currentTask,
    dynamic plantConfig,
  ) {
    // Converter tipo de task para tipo de cuidado
    final careType = _mapTaskTypeToCareType(currentTask.type);
    if (careType == null) return false;

    // Verificar se o tipo de cuidado ainda está ativo na configuração
    if (plantConfig.isCareTypeActive != null) {
      return plantConfig.isCareTypeActive(careType) as bool;
    }

    // Fallback: sempre gerar próxima tarefa se não conseguir verificar
    return true;
  }

  /// Gera próxima tarefa
  Future<Either<Failure, task_entity.Task>> _generateNextTask(
    task_entity.Task currentTask,
    DateTime completionDate,
    dynamic plant,
  ) async {
    try {
      // Converter PlantConfig para PlantaConfigModel
      final configModel = _convertToPlantaConfigModel(plant);

      // Converter Task para TaskModel para compatibilidade com o service
      final taskModel = _convertToTaskModel(currentTask);

      // Gerar próxima tarefa usando o service
      final generationResult = taskGenerationService.generateNextTask(
        completedTask: taskModel,
        completionDate: completionDate,
        config: configModel,
      );

      if (generationResult.isLeft()) {
        return Left(
          generationResult.fold((failure) => failure, (_) => throw Exception()),
        );
      }

      final nextTaskModel = generationResult.fold((_) => null, (task) => task);
      if (nextTaskModel == null) {
        return const Left(ValidationFailure('Nenhuma próxima tarefa foi gerada'));
      }

      // Converter de volta para Task entity
      final nextTask = task_entity.Task.fromModel(
        nextTaskModel,
        plantName: plant.name as String?,
      );

      // Salvar próxima tarefa
      final saveResult = await tasksRepository.addTask(nextTask);
      return saveResult;
    } catch (e) {
      return Left(
        ServerFailure('Erro ao gerar próxima tarefa: ${e.toString()}'),
      );
    }
  }

  /// Converte TaskType para string de cuidado
  String? _mapTaskTypeToCareType(task_entity.TaskType type) {
    switch (type) {
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
        return null;
    }
  }

  /// Converte Task para TaskModel (legacy compatibility)
  TaskModel _convertToTaskModel(task_entity.Task task) {
    return TaskModel(
      id: task.id,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      title: task.title,
      description: task.description,
      plantId: task.plantId,
      plantName: task.plantName,
      type: task.type,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      completedAt: task.completedAt,
      completionNotes: task.completionNotes,
      isRecurring: task.isRecurring,
      recurringIntervalDays: task.recurringIntervalDays,
      nextDueDate: task.nextDueDate,
      lastSyncAt: task.lastSyncAt,
      isDirty: task.isDirty,
      isDeleted: task.isDeleted,
      version: task.version,
      userId: task.userId,
      moduleName: task.moduleName,
    );
  }

  /// Converte PlantConfig entity para PlantaConfigModel
  PlantaConfigModel _convertToPlantaConfigModel(dynamic plant) {
    final config = plant.config;

    return PlantaConfigModel.create(
      plantaId: plant.id as String,
      userId: plant.userId as String?,
      aguaAtiva:
          (config?.wateringIntervalDays != null) &&
          ((config?.wateringIntervalDays as int?) ?? 0) > 0,
      intervaloRegaDias: (config?.wateringIntervalDays as int?) ?? 3,
      aduboAtivo:
          (config?.fertilizingIntervalDays != null) &&
          ((config?.fertilizingIntervalDays as int?) ?? 0) > 0,
      intervaloAdubacaoDias: (config?.fertilizingIntervalDays as int?) ?? 14,
      podaAtiva:
          (config?.pruningIntervalDays != null) && ((config?.pruningIntervalDays as int?) ?? 0) > 0,
      intervaloPodaDias: (config?.pruningIntervalDays as int?) ?? 30,
      banhoSolAtivo:
          (config?.sunlightIntervalDays != null) &&
          ((config?.sunlightIntervalDays as int?) ?? 0) > 0,
      intervaloBanhoSolDias: (config?.sunlightIntervalDays as int?) ?? 1,
      inspecaoPragasAtiva:
          (config?.pestInspectionIntervalDays != null) &&
          ((config?.pestInspectionIntervalDays as int?) ?? 0) > 0,
      intervaloInspecaoPragasDias: (config?.pestInspectionIntervalDays as int?) ?? 7,
      replantarAtivo: true,
      intervaloReplantarDias: 180,
    );
  }
}

/// Parâmetros para conclusão com regeneração
class CompleteTaskWithRegenerationParams {
  final String taskId;
  final DateTime completionDate;
  final String? notes;

  const CompleteTaskWithRegenerationParams({
    required this.taskId,
    required this.completionDate,
    this.notes,
  });

  /// Factory constructor com validações
  factory CompleteTaskWithRegenerationParams.create({
    required String taskId,
    required DateTime completionDate,
    String? notes,
  }) {
    if (taskId.trim().isEmpty) {
      throw ArgumentError('taskId não pode estar vazio');
    }

    return CompleteTaskWithRegenerationParams(
      taskId: taskId.trim(),
      completionDate: completionDate,
      notes: notes?.trim(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompleteTaskWithRegenerationParams &&
        other.taskId == taskId &&
        other.completionDate == completionDate &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(taskId, completionDate, notes);
  }

  @override
  String toString() {
    return 'CompleteTaskWithRegenerationParams(taskId: $taskId, completionDate: $completionDate, notes: $notes)';
  }
}

/// Resultado da conclusão com regeneração
class TaskCompletionWithRegenerationResult {
  final task_entity.Task completedTask;
  final task_entity.Task? nextTask;
  final bool regenerationSuccessful;

  const TaskCompletionWithRegenerationResult({
    required this.completedTask,
    this.nextTask,
    required this.regenerationSuccessful,
  });

  /// Se uma próxima tarefa foi gerada
  bool get hasNextTask => nextTask != null;

  /// Data da próxima tarefa (se existir)
  DateTime? get nextTaskDate => nextTask?.dueDate;

  /// Descrição da próxima tarefa (se existir)
  String? get nextTaskDescription => nextTask?.description;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskCompletionWithRegenerationResult &&
        other.completedTask == completedTask &&
        other.nextTask == nextTask &&
        other.regenerationSuccessful == regenerationSuccessful;
  }

  @override
  int get hashCode {
    return Object.hash(completedTask, nextTask, regenerationSuccessful);
  }

  @override
  String toString() {
    return 'TaskCompletionWithRegenerationResult(completedTask: ${completedTask.id}, nextTask: ${nextTask?.id}, regenerationSuccessful: $regenerationSuccessful)';
  }
}
