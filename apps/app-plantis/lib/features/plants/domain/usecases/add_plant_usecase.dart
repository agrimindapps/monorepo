import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/data/models/planta_config_model.dart';
import '../../../tasks/domain/usecases/generate_initial_tasks_usecase.dart';
import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

/// Resultado detalhado da geração de tarefas para logging e feedback
class TaskGenerationResult {
  final bool isSuccess;
  final bool isFailure;
  final bool isSkipped;
  final String message;
  final int taskCount;
  final dynamic tasks;
  final Failure? failure;
  final dynamic exception;
  final StackTrace? stackTrace;

  TaskGenerationResult._({
    required this.isSuccess,
    required this.isFailure,
    required this.isSkipped,
    required this.message,
    required this.taskCount,
    this.tasks,
    this.failure,
    this.exception,
    this.stackTrace,
  });

  factory TaskGenerationResult.success(int count, dynamic tasks) {
    return TaskGenerationResult._(
      isSuccess: true,
      isFailure: false,
      isSkipped: false,
      message: '$count tarefas geradas com sucesso',
      taskCount: count,
      tasks: tasks,
    );
  }

  factory TaskGenerationResult.failure(
    String message,
    Failure? failure, [
    dynamic exception,
    StackTrace? stackTrace,
  ]) {
    return TaskGenerationResult._(
      isSuccess: false,
      isFailure: true,
      isSkipped: false,
      message: message,
      taskCount: 0,
      failure: failure,
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  factory TaskGenerationResult.skipped(String reason) {
    return TaskGenerationResult._(
      isSuccess: false,
      isFailure: false,
      isSkipped: true,
      message: 'Geração pulada: $reason',
      taskCount: 0,
    );
  }
}

class AddPlantUseCase implements UseCase<Plant, AddPlantParams> {
  AddPlantUseCase(this.repository, this.generateInitialTasksUseCase);

  final PlantsRepository repository;
  final GenerateInitialTasksUseCase generateInitialTasksUseCase;

  @override
  Future<Either<Failure, Plant>> call(AddPlantParams params) async {
    if (kDebugMode) {
      debugPrint('🌱 AddPlantUseCase.call() - Iniciando adição de planta');
      debugPrint('🌱 AddPlantUseCase.call() - params.name: ${params.name}');
      debugPrint('🌱 AddPlantUseCase.call() - params.id: ${params.id}');
    }
    final validationResult = _validatePlant(params);
    if (validationResult != null) {
      if (kDebugMode) {
        debugPrint(
          '❌ AddPlantUseCase.call() - Validação falhou: ${validationResult.message}',
        );
      }
      return Left(validationResult);
    }
    final now = DateTime.now();
    final currentUser = AuthStateNotifier.instance.currentUser;
    if (currentUser == null) {
      return const Left(AuthFailure('Usuário não está autenticado'));
    }
    final generatedId =
        params.id ??
        FirebaseFirestore.instance
            .collection('users/${currentUser.id}/plants')
            .doc()
            .id;

    if (kDebugMode) {
      debugPrint(
        '🌱 AddPlantUseCase.call() - Criando planta com id: $generatedId',
      );
    }

    final plant = Plant(
      id: generatedId,
      name: params.name.trim(),
      species: params.species?.trim(),
      spaceId: params.spaceId,
      imageBase64: params.imageBase64,
      imageUrls: params.imageUrls ?? [],
      plantingDate: params.plantingDate,
      notes: params.notes?.trim(),
      config: params.config,
      createdAt: now,
      updatedAt: now,
      isDirty: true,
      userId: currentUser.id,
      moduleName: 'plantis',
    );

    if (kDebugMode) {
      debugPrint('🌱 AddPlantUseCase.call() - Chamando repository.addPlant()');
    }
    final plantResult = await repository.addPlant(plant);

    return plantResult.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
            '❌ AddPlantUseCase.call() - Repository.addPlant falhou: ${failure.message}',
          );
        }
        return Left(failure);
      },
      (savedPlant) async {
        if (kDebugMode) {
          debugPrint('✅ AddPlantUseCase.call() - Repository.addPlant sucesso:');
          debugPrint('   - savedPlant.id: ${savedPlant.id}');
          debugPrint('   - savedPlant.name: ${savedPlant.name}');
          debugPrint('   - savedPlant.createdAt: ${savedPlant.createdAt}');
        }
        if (savedPlant.config != null) {
          if (kDebugMode) {
            debugPrint('🌱 AddPlantUseCase.call() - Gerando tarefas iniciais');
            debugPrint(
              '🌱 AddPlantUseCase.call() - Config ativa para: ${PlantaConfigModel.fromPlantConfig(plantaId: savedPlant.id, plantConfig: savedPlant.config).activeCareTypes}',
            );
          }
          // Only generate unified Task system tasks (not PlantTask)
          final taskGenerationResult =
              await _generateInitialTasksWithErrorHandling(savedPlant);

          if (taskGenerationResult.isFailure && kDebugMode) {
            if (kDebugMode) {
              debugPrint(
                '⚠️ AddPlantUseCase.call() - Tasks não foram geradas, mas planta foi salva com sucesso',
              );
            }
          } else if (taskGenerationResult.isSuccess && kDebugMode) {
            if (kDebugMode) {
              debugPrint(
                '✅ AddPlantUseCase.call() - ${taskGenerationResult.taskCount} tasks geradas com sucesso',
              );
            }
          }
        }

        if (kDebugMode) {
          debugPrint(
            '✅ AddPlantUseCase.call() - Processo completo, retornando planta',
          );
        }
        return Right(savedPlant);
      },
    );
  }

  ValidationFailure? _validatePlant(AddPlantParams params) {
    if (params.name.trim().isEmpty) {
      return const ValidationFailure('Nome da planta é obrigatório');
    }

    if (params.name.trim().length < 2) {
      return const ValidationFailure('Nome deve ter pelo menos 2 caracteres');
    }

    if (params.name.trim().length > 50) {
      return const ValidationFailure('Nome não pode ter mais de 50 caracteres');
    }

    if (params.species != null && params.species!.trim().length > 100) {
      return const ValidationFailure(
        'Espécie não pode ter mais de 100 caracteres',
      );
    }

    if (params.notes != null && params.notes!.trim().length > 500) {
      return const ValidationFailure(
        'Observações não podem ter mais de 500 caracteres',
      );
    }

    return null;
  }

  /// Gera tarefas iniciais com tratamento robusto de erros
  /// Retorna resultado detalhado para logging e feedback
  Future<TaskGenerationResult> _generateInitialTasksWithErrorHandling(
    Plant plant,
  ) async {
    if (plant.config == null) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ _generateInitialTasksWithErrorHandling - Skipping: config=${plant.config != null}',
        );
      }
      return TaskGenerationResult.skipped(
        'Use case não disponível ou sem configuração',
      );
    }

    try {
      if (kDebugMode) {
        debugPrint(
          '🌱 _generateInitialTasksWithErrorHandling - Iniciando conversão de config',
        );
      }
      final configModel = _convertToPlantaConfigModel(plant);

      if (configModel.activeCareTypes.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ _generateInitialTasksWithErrorHandling - Nenhum cuidado ativo, pulando geração',
          );
        }
        return TaskGenerationResult.skipped('Nenhum tipo de cuidado ativo');
      }

      if (kDebugMode) {
        debugPrint(
          '🌱 _generateInitialTasksWithErrorHandling - Criando parâmetros',
        );
        debugPrint('   - plantaId: ${plant.id}');
        debugPrint('   - activeCareTypes: ${configModel.activeCareTypes}');
        debugPrint('   - plantingDate: ${plant.plantingDate}');
        debugPrint('   - userId: ${plant.userId}');
      }

      final params = GenerateInitialTasksParams.create(
        plantaId: plant.id,
        config: configModel,
        plantingDate: plant.plantingDate ?? plant.createdAt,
        userId: plant.userId,
      );

      if (kDebugMode) {
        debugPrint(
          '🌱 _generateInitialTasksWithErrorHandling - Executando generateInitialTasksUseCase',
        );
      }

      final result = await generateInitialTasksUseCase(params);

      return result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '❌ _generateInitialTasksWithErrorHandling - FALHA: ${failure.message}',
            );
            debugPrint('   - Tipo: ${failure.runtimeType}');
          }
          return TaskGenerationResult.failure(failure.message, failure);
        },
        (tasks) {
          if (kDebugMode) {
            debugPrint(
              '✅ _generateInitialTasksWithErrorHandling - SUCESSO: ${tasks.length} tarefas geradas',
            );
            for (int i = 0; i < tasks.length; i++) {
              debugPrint(
                '   - Tarefa ${i + 1}: ${tasks[i].title} (${tasks[i].type.key})',
              );
            }
          }
          return TaskGenerationResult.success(tasks.length, tasks);
        },
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ _generateInitialTasksWithErrorHandling - EXCEPTION: $e');
        debugPrint('   - Stack trace: $stackTrace');
      }
      return TaskGenerationResult.failure(
        'Erro inesperado ao gerar tarefas: ${e.toString()}',
        null,
        e,
        stackTrace,
      );
    }
  }

  PlantaConfigModel _convertToPlantaConfigModel(Plant plant) {
    final config = plant.config!;

    return PlantaConfigModel.fromPlantConfig(
      plantaId: plant.id,
      plantConfig: config,
      userId: plant.userId,
    );
  }
}

class AddPlantParams {
  final String? id;
  final String name;
  final String? species;
  final String? spaceId;
  final String? imageBase64;
  final List<String>? imageUrls;
  final DateTime? plantingDate;
  final String? notes;
  final PlantConfig? config;

  const AddPlantParams({
    this.id,
    required this.name,
    this.species,
    this.spaceId,
    this.imageBase64,
    this.imageUrls,
    this.plantingDate,
    this.notes,
    this.config,
  });
}
