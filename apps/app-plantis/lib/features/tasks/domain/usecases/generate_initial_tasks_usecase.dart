import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/data/models/planta_config_model.dart';
import '../../../../core/services/task_generation_service.dart';
import '../entities/task.dart' as task_entity;
import '../repositories/tasks_repository.dart';

/// Use case para gerar tarefas iniciais quando uma nova planta é cadastrada
///
/// Este use case é responsável por:
/// - Gerar tarefas baseado na configuração da planta
/// - Salvar as tarefas no repositório
/// - Manter atomicidade da operação
/// - Integrar com o sistema de sync offline-first
class GenerateInitialTasksUseCase
    implements UseCase<List<task_entity.Task>, GenerateInitialTasksParams> {
  final TasksRepository tasksRepository;
  final TaskGenerationService taskGenerationService;

  GenerateInitialTasksUseCase({
    required this.tasksRepository,
    required this.taskGenerationService,
  });

  @override
  Future<Either<Failure, List<task_entity.Task>>> call(
    GenerateInitialTasksParams params,
  ) async {
    try {
      if (kDebugMode) {
        print(
          '🔧 GenerateInitialTasksUseCase.call() - Iniciando geração de tarefas',
        );
        print('🔧 plantaId: ${params.plantaId}');
        print('🔧 activeCareTypes: ${params.config.activeCareTypes}');
        print('🔧 plantingDate: ${params.plantingDate}');
        print('🔧 userId: ${params.userId}');
      }
      final validationResult = _validateParams(params);
      if (validationResult != null) {
        if (kDebugMode) {
          print(
            '❌ GenerateInitialTasksUseCase.call() - Validação falhou: ${validationResult.message}',
          );
        }
        return Left(validationResult);
      }
      if (kDebugMode) {
        print(
          '🔧 GenerateInitialTasksUseCase.call() - Chamando taskGenerationService.generateInitialTasks',
        );
      }

      final generationResult = taskGenerationService.generateInitialTasks(
        plantaId: params.plantaId,
        config: params.config,
        plantingDate: params.plantingDate,
        userId: params.userId,
      );

      if (generationResult.isLeft()) {
        final failure = generationResult.fold(
          (failure) => failure,
          (_) => throw Exception(),
        );
        if (kDebugMode) {
          print(
            '❌ GenerateInitialTasksUseCase.call() - TaskGenerationService falhou: ${failure.message}',
          );
        }
        return Left(failure);
      }

      final taskEntities = generationResult.fold(
        (_) => <task_entity.Task>[],
        (tasks) => tasks,
      );

      if (kDebugMode) {
        print(
          '🔧 GenerateInitialTasksUseCase.call() - ${taskEntities.length} entidades de tarefa geradas',
        );
        for (int i = 0; i < taskEntities.length; i++) {
          final entity = taskEntities[i];
          print('🔧 Tarefa ${i + 1}: ${entity.title} (${entity.type.key})');
        }
      }

      if (kDebugMode) {
        print(
          '🔧 GenerateInitialTasksUseCase.call() - Salvando ${taskEntities.length} tarefas',
        );
      }
      final saveResults = await Future.wait(
        taskEntities.map((task) => tasksRepository.addTask(task)),
      );
      final failures = saveResults.where((result) => result.isLeft()).toList();
      if (failures.isNotEmpty) {
        final firstFailure = failures.first.fold(
          (failure) => failure,
          (_) => throw Exception(),
        );
        if (kDebugMode) {
          print(
            '❌ GenerateInitialTasksUseCase.call() - Falha ao salvar tarefas: ${firstFailure.message}',
          );
          print('❌ Total de falhas: ${failures.length}/${saveResults.length}');
        }
        return Left(firstFailure);
      }
      final savedTasks =
          saveResults
              .map((result) => result.fold((_) => null, (task) => task))
              .whereType<task_entity.Task>()
              .toList();

      if (kDebugMode) {
        print(
          '✅ GenerateInitialTasksUseCase.call() - ${savedTasks.length} tarefas salvas com sucesso',
        );
      }

      return Right(savedTasks);
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro inesperado ao gerar tarefas iniciais: ${e.toString()}',
        ),
      );
    }
  }

  /// Valida os parâmetros de entrada
  ValidationFailure? _validateParams(GenerateInitialTasksParams params) {
    if (params.plantaId.trim().isEmpty) {
      return const ValidationFailure('ID da planta é obrigatório');
    }

    if (params.config.activeCareTypes.isEmpty) {
      return const ValidationFailure(
        'Planta deve ter pelo menos um tipo de cuidado ativo',
      );
    }
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
