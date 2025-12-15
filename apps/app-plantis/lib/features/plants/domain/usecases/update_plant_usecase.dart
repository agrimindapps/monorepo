import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../core/data/models/planta_config_model.dart';
import '../../../tasks/domain/usecases/generate_initial_tasks_usecase.dart';
import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

class UpdatePlantUseCase implements UseCase<Plant, UpdatePlantParams> {
  UpdatePlantUseCase(this.repository, this.generateInitialTasksUseCase);

  final PlantsRepository repository;
  final GenerateInitialTasksUseCase generateInitialTasksUseCase;

  @override
  Future<Either<Failure, Plant>> call(UpdatePlantParams params) async {
    final validationResult = _validatePlant(params);
    if (validationResult != null) {
      return Left(validationResult);
    }
    final existingResult = await repository.getPlantById(params.id);

    return existingResult.fold((failure) => Left(failure), (
      existingPlant,
    ) async {
      // Detectar novos cuidados habilitados
      final newCareTypes = _detectNewCareTypes(
        existingPlant.config,
        params.config,
      );

      if (kDebugMode && newCareTypes.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            '🌱 UpdatePlantUseCase - Novos cuidados detectados: $newCareTypes',
          );
        }
      }

      final updatedPlant = existingPlant.copyWith(
        name: params.name.trim(),
        species: params.species?.trim(),
        spaceId: params.spaceId,
        imageBase64: params.imageBase64,
        imageUrls: params.imageUrls,
        plantingDate: params.plantingDate,
        notes: params.notes?.trim(),
        config: params.config,
        isFavorited: params.isFavorited,
        updatedAt: DateTime.now(),
        isDirty: true,
      );

      final updateResult = await repository.updatePlant(updatedPlant);

      return updateResult.fold((failure) => Left(failure), (savedPlant) async {
        // Gerar tarefas para os novos cuidados habilitados
        if (newCareTypes.isNotEmpty && savedPlant.config != null) {
          if (kDebugMode) {
            debugPrint(
              '🌱 UpdatePlantUseCase - Gerando tarefas para novos cuidados',
            );
          }
          await _generateTasksForNewCareTypes(savedPlant, newCareTypes);
        }
        return Right(savedPlant);
      });
    });
  }

  /// Detecta quais tipos de cuidado foram habilitados (não existiam antes)
  List<String> _detectNewCareTypes(
    PlantConfig? oldConfig,
    PlantConfig? newConfig,
  ) {
    final newCareTypes = <String>[];

    if (newConfig == null) return newCareTypes;

    // Verificar cada tipo de cuidado
    if (_isNewlyEnabled(
      oldConfig?.wateringIntervalDays,
      newConfig.wateringIntervalDays,
    )) {
      newCareTypes.add('agua');
    }
    if (_isNewlyEnabled(
      oldConfig?.fertilizingIntervalDays,
      newConfig.fertilizingIntervalDays,
    )) {
      newCareTypes.add('adubo');
    }
    if (_isNewlyEnabled(
      oldConfig?.pruningIntervalDays,
      newConfig.pruningIntervalDays,
    )) {
      newCareTypes.add('poda');
    }
    if (_isNewlyEnabled(
      oldConfig?.sunlightCheckIntervalDays,
      newConfig.sunlightCheckIntervalDays,
    )) {
      newCareTypes.add('banhoSol');
    }
    if (_isNewlyEnabled(
      oldConfig?.pestInspectionIntervalDays,
      newConfig.pestInspectionIntervalDays,
    )) {
      newCareTypes.add('inspecaoPragas');
    }
    if (_isNewlyEnabled(
      oldConfig?.replantingIntervalDays,
      newConfig.replantingIntervalDays,
    )) {
      newCareTypes.add('replantar');
    }

    return newCareTypes;
  }

  /// Verifica se um cuidado foi habilitado (não tinha valor e agora tem)
  bool _isNewlyEnabled(int? oldValue, int? newValue) {
    return (oldValue == null || oldValue <= 0) &&
        (newValue != null && newValue > 0);
  }

  /// Gera tarefas apenas para os novos tipos de cuidado (usando Task system unificado)
  Future<void> _generateTasksForNewCareTypes(
    Plant plant,
    List<String> careTypes,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🌱 _generateTasksForNewCareTypes - plant: ${plant.name}, careTypes: $careTypes',
        );
      }

      // Criar um PlantaConfigModel filtrado apenas com os cuidados novos
      final fullConfig = PlantaConfigModel.fromPlantConfig(
        plantaId: plant.id,
        plantConfig: plant.config,
      );

      // Criar config filtrada apenas com os novos cuidados
      final filteredConfig = PlantaConfigModel(
        id: fullConfig.id,
        plantaId: plant.id,
        aguaAtiva: careTypes.contains('agua') && fullConfig.aguaAtiva,
        intervaloRegaDias: careTypes.contains('agua')
            ? fullConfig.intervaloRegaDias
            : 0,
        aduboAtivo: careTypes.contains('adubo') && fullConfig.aduboAtivo,
        intervaloAdubacaoDias: careTypes.contains('adubo')
            ? fullConfig.intervaloAdubacaoDias
            : 0,
        podaAtiva: careTypes.contains('poda') && fullConfig.podaAtiva,
        intervaloPodaDias: careTypes.contains('poda')
            ? fullConfig.intervaloPodaDias
            : 0,
        banhoSolAtivo:
            careTypes.contains('banhoSol') && fullConfig.banhoSolAtivo,
        intervaloBanhoSolDias: careTypes.contains('banhoSol')
            ? fullConfig.intervaloBanhoSolDias
            : 0,
        inspecaoPragasAtiva:
            careTypes.contains('inspecaoPragas') &&
            fullConfig.inspecaoPragasAtiva,
        intervaloInspecaoPragasDias: careTypes.contains('inspecaoPragas')
            ? fullConfig.intervaloInspecaoPragasDias
            : 0,
        replantarAtivo:
            careTypes.contains('replantar') && fullConfig.replantarAtivo,
        intervaloReplantarDias: careTypes.contains('replantar')
            ? fullConfig.intervaloReplantarDias
            : 0,
      );

      if (kDebugMode) {
        debugPrint(
          '🌱 _generateTasksForNewCareTypes - filteredConfig.activeCareTypes: ${filteredConfig.activeCareTypes}',
        );
      }

      if (filteredConfig.activeCareTypes.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ _generateTasksForNewCareTypes - Nenhum cuidado ativo na config filtrada',
          );
        }
        return;
      }

      // Gerar Tasks usando o sistema unificado
      final tasksResult = await generateInitialTasksUseCase.call(
        GenerateInitialTasksParams(
          plantaId: plant.id,
          config: filteredConfig,
          plantingDate: plant.plantingDate,
        ),
      );

      tasksResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ _generateTasksForNewCareTypes - Falha ao gerar Tasks: ${failure.message}',
            );
          }
        },
        (generatedTasks) {
          if (kDebugMode) {
            debugPrint(
              '✅ _generateTasksForNewCareTypes - ${generatedTasks.length} Tasks geradas',
            );
          }
        },
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ _generateTasksForNewCareTypes - Erro: $e');
        debugPrint('Stack: $stack');
      }
    }
  }

  ValidationFailure? _validatePlant(UpdatePlantParams params) {
    if (params.id.trim().isEmpty) {
      return const ValidationFailure('ID da planta é obrigatório');
    }

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
}

class UpdatePlantParams {
  final String id;
  final String name;
  final String? species;
  final String? spaceId;
  final String? imageBase64;
  final List<String>? imageUrls;
  final DateTime? plantingDate;
  final String? notes;
  final PlantConfig? config;
  final bool? isFavorited;

  const UpdatePlantParams({
    required this.id,
    required this.name,
    this.species,
    this.spaceId,
    this.imageBase64,
    this.imageUrls,
    this.plantingDate,
    this.notes,
    this.config,
    this.isFavorited,
  });
}
