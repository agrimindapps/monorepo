import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../tasks/domain/usecases/generate_initial_tasks_usecase.dart';
import '../entities/plant.dart';
import '../repositories/plants_repository.dart';
import '../repositories/plant_tasks_repository.dart';
import '../services/plant_task_generator.dart';
import '../../../../core/auth/auth_state_notifier.dart';
import '../../../../core/data/models/planta_config_model.dart';

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

  factory TaskGenerationResult.failure(String message, Failure? failure, [dynamic exception, StackTrace? stackTrace]) {
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
  final PlantsRepository repository;
  final GenerateInitialTasksUseCase? generateInitialTasksUseCase;
  final PlantTaskGenerator plantTaskGenerator;
  final PlantTasksRepository? plantTasksRepository;

  AddPlantUseCase(
    this.repository, {
    this.generateInitialTasksUseCase,
    PlantTaskGenerator? plantTaskGenerator,
    this.plantTasksRepository,
  }) : plantTaskGenerator = plantTaskGenerator ?? PlantTaskGenerator();

  @override
  Future<Either<Failure, Plant>> call(AddPlantParams params) async {
    if (kDebugMode) {
      print('🌱 AddPlantUseCase.call() - Iniciando adição de planta');
      print('🌱 AddPlantUseCase.call() - params.name: ${params.name}');
      print('🌱 AddPlantUseCase.call() - params.id: ${params.id}');
    }

    // Validate plant data
    final validationResult = _validatePlant(params);
    if (validationResult != null) {
      if (kDebugMode) {
        print('❌ AddPlantUseCase.call() - Validação falhou: ${validationResult.message}');
      }
      return Left(validationResult);
    }

    // Create plant with timestamps
    final now = DateTime.now();
    final generatedId = params.id ?? _generateId();
    
    if (kDebugMode) {
      print('🌱 AddPlantUseCase.call() - Criando planta com id: $generatedId');
    }
    
    // Get current user ID from auth state notifier
    final currentUser = AuthStateNotifier.instance.currentUser;
    if (currentUser == null) {
      return const Left(AuthFailure('Usuário não está autenticado'));
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
      print('🌱 AddPlantUseCase.call() - Chamando repository.addPlant()');
    }

    // Salvar planta primeiro
    final plantResult = await repository.addPlant(plant);

    return plantResult.fold((failure) {
      if (kDebugMode) {
        print('❌ AddPlantUseCase.call() - Repository.addPlant falhou: ${failure.message}');
      }
      return Left(failure);
    }, (savedPlant) async {
      if (kDebugMode) {
        print('✅ AddPlantUseCase.call() - Repository.addPlant sucesso:');
        print('   - savedPlant.id: ${savedPlant.id}');
        print('   - savedPlant.name: ${savedPlant.name}');
        print('   - savedPlant.createdAt: ${savedPlant.createdAt}');
      }

      // Gerar tarefas automáticas se há configuração
      if (savedPlant.config != null) {
        if (kDebugMode) {
          print('🌱 AddPlantUseCase.call() - Gerando tarefas iniciais');
          print('🌱 AddPlantUseCase.call() - Config ativa para: ${PlantaConfigModel.fromPlantConfig(plantaId: savedPlant.id, plantConfig: savedPlant.config).activeCareTypes}');
        }

        // Gerar PlantTasks automáticas (NOVA FUNCIONALIDADE CRÍTICA)
        final plantTasksResult = await _generatePlantTasksWithErrorHandling(savedPlant);

        // Gerar Tasks tradicionais se o use case estiver disponível (manter compatibilidade)
        if (generateInitialTasksUseCase != null) {
          final taskGenerationResult = await _generateInitialTasksWithErrorHandling(savedPlant);

          if (taskGenerationResult.isFailure && kDebugMode) {
            print('⚠️ AddPlantUseCase.call() - Tasks tradicionais não foram geradas, mas planta foi salva com sucesso');
          } else if (taskGenerationResult.isSuccess && kDebugMode) {
            print('✅ AddPlantUseCase.call() - ${taskGenerationResult.taskCount} tasks tradicionais geradas com sucesso');
          }
        }

        if (plantTasksResult.isFailure && kDebugMode) {
          print('⚠️ AddPlantUseCase.call() - PlantTasks não foram geradas, mas planta foi salva com sucesso');
        } else if (plantTasksResult.isSuccess && kDebugMode) {
          print('✅ AddPlantUseCase.call() - ${plantTasksResult.taskCount} PlantTasks geradas com sucesso');
        }
      }

      if (kDebugMode) {
        print('✅ AddPlantUseCase.call() - Processo completo, retornando planta');
      }
      return Right(savedPlant);
    });
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

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Gera PlantTasks automáticas com tratamento robusto de erros
  /// Retorna resultado detalhado para logging e feedback
  Future<TaskGenerationResult> _generatePlantTasksWithErrorHandling(Plant plant) async {
    try {
      if (plant.config == null) {
        if (kDebugMode) {
          print('⚠️ _generatePlantTasksWithErrorHandling - Skipping: sem configuração');
        }
        return TaskGenerationResult.skipped('Planta sem configuração de cuidados');
      }

      if (kDebugMode) {
        print('🌱 _generatePlantTasksWithErrorHandling - Iniciando geração de PlantTasks');
      }

      // Gerar PlantTasks usando o PlantTaskGenerator
      final plantTasks = plantTaskGenerator.generateTasksForPlant(plant);

      if (plantTasks.isEmpty) {
        if (kDebugMode) {
          print('⚠️ _generatePlantTasksWithErrorHandling - Nenhuma PlantTask gerada');
        }
        return TaskGenerationResult.skipped('Nenhuma configuração de cuidado ativa');
      }

      if (kDebugMode) {
        print('✅ _generatePlantTasksWithErrorHandling - SUCESSO: ${plantTasks.length} PlantTasks geradas');
        for (int i = 0; i < plantTasks.length; i++) {
          print('   - PlantTask ${i + 1}: ${plantTasks[i].title} (${plantTasks[i].type.name})');
        }
      }

      // CRÍTICO: Persistir PlantTasks em repositório
      if (plantTasksRepository != null) {
        if (kDebugMode) {
          print('💾 _generatePlantTasksWithErrorHandling - Persistindo ${plantTasks.length} PlantTasks');
        }

        final saveResult = await plantTasksRepository!.addPlantTasks(plantTasks);
        return saveResult.fold(
          (failure) {
            if (kDebugMode) {
              print('❌ _generatePlantTasksWithErrorHandling - Erro ao persistir PlantTasks: ${failure.message}');
            }
            return TaskGenerationResult.failure(
              'Erro ao persistir PlantTasks: ${failure.message}',
              failure,
            );
          },
          (savedTasks) {
            if (kDebugMode) {
              print('✅ _generatePlantTasksWithErrorHandling - ${savedTasks.length} PlantTasks persistidas com sucesso');
            }
            return TaskGenerationResult.success(savedTasks.length, savedTasks);
          },
        );
      } else {
        if (kDebugMode) {
          print('⚠️ _generatePlantTasksWithErrorHandling - PlantTasksRepository não disponível, PlantTasks não persistidas');
        }
        return TaskGenerationResult.success(plantTasks.length, plantTasks);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ _generatePlantTasksWithErrorHandling - EXCEPTION: $e');
        print('   - Stack trace: $stackTrace');
      }
      return TaskGenerationResult.failure(
        'Erro inesperado ao gerar PlantTasks: ${e.toString()}',
        null,
        e,
        stackTrace,
      );
    }
  }

  /// Gera tarefas iniciais com tratamento robusto de erros
  /// Retorna resultado detalhado para logging e feedback
  Future<TaskGenerationResult> _generateInitialTasksWithErrorHandling(Plant plant) async {
    if (generateInitialTasksUseCase == null || plant.config == null) {
      if (kDebugMode) {
        print('⚠️ _generateInitialTasksWithErrorHandling - Skipping: useCase=${generateInitialTasksUseCase != null}, config=${plant.config != null}');
      }
      return TaskGenerationResult.skipped('Use case não disponível ou sem configuração');
    }

    try {
      if (kDebugMode) {
        print('🌱 _generateInitialTasksWithErrorHandling - Iniciando conversão de config');
      }

      // Converter PlantConfig para PlantaConfigModel com validação
      final configModel = _convertToPlantaConfigModel(plant);
      
      if (configModel.activeCareTypes.isEmpty) {
        if (kDebugMode) {
          print('⚠️ _generateInitialTasksWithErrorHandling - Nenhum cuidado ativo, pulando geração');
        }
        return TaskGenerationResult.skipped('Nenhum tipo de cuidado ativo');
      }

      if (kDebugMode) {
        print('🌱 _generateInitialTasksWithErrorHandling - Criando parâmetros');
        print('   - plantaId: ${plant.id}');
        print('   - activeCareTypes: ${configModel.activeCareTypes}');
        print('   - plantingDate: ${plant.plantingDate}');
        print('   - userId: ${plant.userId}');
      }

      final params = GenerateInitialTasksParams.create(
        plantaId: plant.id,
        config: configModel,
        plantingDate: plant.plantingDate ?? plant.createdAt,
        userId: plant.userId,
      );

      if (kDebugMode) {
        print('🌱 _generateInitialTasksWithErrorHandling - Executando generateInitialTasksUseCase');
      }

      final result = await generateInitialTasksUseCase!(params);

      return result.fold(
        (failure) {
          if (kDebugMode) {
            print('❌ _generateInitialTasksWithErrorHandling - FALHA: ${failure.message}');
            print('   - Tipo: ${failure.runtimeType}');
          }
          return TaskGenerationResult.failure(failure.message, failure);
        },
        (tasks) {
          if (kDebugMode) {
            print('✅ _generateInitialTasksWithErrorHandling - SUCESSO: ${tasks.length} tarefas geradas');
            for (int i = 0; i < tasks.length; i++) {
              print('   - Tarefa ${i + 1}: ${tasks[i].title} (${tasks[i].type.key})');
            }
          }
          return TaskGenerationResult.success(tasks.length, tasks);
        },
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ _generateInitialTasksWithErrorHandling - EXCEPTION: $e');
        print('   - Stack trace: $stackTrace');
      }
      return TaskGenerationResult.failure(
        'Erro inesperado ao gerar tarefas: ${e.toString()}',
        null,
        e,
        stackTrace,
      );
    }
  }


  /// Converte PlantConfig entity para PlantaConfigModel usando o método robusto
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
