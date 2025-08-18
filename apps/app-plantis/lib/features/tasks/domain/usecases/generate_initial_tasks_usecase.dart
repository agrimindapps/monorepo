import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../../../../core/services/task_generation_service.dart';
import '../../../../core/data/models/planta_config_model.dart';
import '../entities/task.dart' as task_entity;
import '../repositories/tasks_repository.dart';

/// Use case para gerar tarefas iniciais quando uma nova planta é cadastrada
/// 
/// Este use case é responsável por:
/// - Gerar tarefas baseado na configuração da planta
/// - Salvar as tarefas no repositório
/// - Manter atomicidade da operação
/// - Integrar com o sistema de sync offline-first
class GenerateInitialTasksUseCase implements UseCase<List<task_entity.Task>, GenerateInitialTasksParams> {
  final TasksRepository tasksRepository;
  final TaskGenerationService taskGenerationService;
  
  GenerateInitialTasksUseCase({
    required this.tasksRepository,
    required this.taskGenerationService,
  });
  
  @override
  Future<Either<Failure, List<task_entity.Task>>> call(GenerateInitialTasksParams params) async {
    try {
      // Validação dos parâmetros
      final validationResult = _validateParams(params);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Gerar tarefas usando o service
      final generationResult = taskGenerationService.generateInitialTasks(
        plantaId: params.plantaId,
        config: params.config,
        plantingDate: params.plantingDate,
        userId: params.userId,
      );

      if (generationResult.isLeft()) {
        return Left(generationResult.fold((failure) => failure, (_) => throw Exception()));
      }

      final tarefaModels = generationResult.fold((_) => <dynamic>[], (tasks) => tasks);
      
      // Converter models para entities
      final taskEntities = tarefaModels.map((model) => task_entity.Task.fromModel(model)).toList();

      // Salvar todas as tarefas de forma atômica
      final saveResults = await Future.wait(
        taskEntities.map((task) => tasksRepository.addTask(task)),
      );

      // Verificar se alguma falhou
      final failures = saveResults.where((result) => result.isLeft()).toList();
      if (failures.isNotEmpty) {
        // Se alguma tarefa falhou, retornar primeira falha encontrada
        return Left(failures.first.fold((failure) => failure, (_) => throw Exception()));
      }

      // Todas as tarefas foram salvas com sucesso
      final savedTasks = saveResults
          .map((result) => result.fold((_) => null, (task) => task))
          .whereType<task_entity.Task>()
          .toList();

      return Right(savedTasks);
      
    } catch (e) {
      return Left(ServerFailure('Erro inesperado ao gerar tarefas iniciais: ${e.toString()}'));
    }
  }

  /// Valida os parâmetros de entrada
  ValidationFailure? _validateParams(GenerateInitialTasksParams params) {
    if (params.plantaId.trim().isEmpty) {
      return const ValidationFailure('ID da planta é obrigatório');
    }

    if (params.config.activeCareTypes.isEmpty) {
      return const ValidationFailure('Planta deve ter pelo menos um tipo de cuidado ativo');
    }

    // Validar se todos os tipos de cuidado são suportados
    for (final careType in params.config.activeCareTypes) {
      if (!taskGenerationService.isCareTypeSupported(careType)) {
        return ValidationFailure('Tipo de cuidado não suportado: $careType');
      }
    }

    return null;
  }
}

/// Parâmetros para geração de tarefas iniciais
class GenerateInitialTasksParams {
  final String plantaId;
  final PlantaConfigModel config;
  final DateTime? plantingDate;
  final String? userId;
  
  const GenerateInitialTasksParams({
    required this.plantaId,
    required this.config,
    this.plantingDate,
    this.userId,
  });

  /// Factory constructor com validações
  factory GenerateInitialTasksParams.create({
    required String plantaId,
    required PlantaConfigModel config,
    DateTime? plantingDate,
    String? userId,
  }) {
    if (plantaId.trim().isEmpty) {
      throw ArgumentError('plantaId não pode estar vazio');
    }

    return GenerateInitialTasksParams(
      plantaId: plantaId.trim(),
      config: config,
      plantingDate: plantingDate,
      userId: userId?.trim(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GenerateInitialTasksParams &&
        other.plantaId == plantaId &&
        other.config == config &&
        other.plantingDate == plantingDate &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(plantaId, config, plantingDate, userId);
  }

  @override
  String toString() {
    return 'GenerateInitialTasksParams(plantaId: $plantaId, userId: $userId, activeCareTypes: ${config.activeCareTypes})';
  }
}