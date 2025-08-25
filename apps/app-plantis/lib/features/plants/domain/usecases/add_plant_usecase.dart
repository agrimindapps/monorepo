import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/data/models/planta_config_model.dart';
import '../../../tasks/domain/usecases/generate_initial_tasks_usecase.dart';
import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

class AddPlantUseCase implements UseCase<Plant, AddPlantParams> {
  final PlantsRepository repository;
  final GenerateInitialTasksUseCase? generateInitialTasksUseCase;

  AddPlantUseCase(this.repository, {this.generateInitialTasksUseCase});

  @override
  Future<Either<Failure, Plant>> call(AddPlantParams params) async {
    // Validate plant data
    final validationResult = _validatePlant(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Create plant with timestamps
    final now = DateTime.now();
    final plant = Plant(
      id: params.id ?? _generateId(),
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
    );

    // Salvar planta primeiro
    final plantResult = await repository.addPlant(plant);

    return plantResult.fold((failure) => Left(failure), (savedPlant) async {
      // Gerar tarefas automáticas se o use case estiver disponível e há configuração
      if (generateInitialTasksUseCase != null && savedPlant.config != null) {
        await _generateInitialTasks(savedPlant);
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

  /// Gera tarefas iniciais para a planta recém-cadastrada
  Future<void> _generateInitialTasks(Plant plant) async {
    if (generateInitialTasksUseCase == null || plant.config == null) {
      return;
    }

    try {
      // Converter PlantConfig para PlantaConfigModel
      final configModel = _convertToPlantaConfigModel(plant);

      final params = GenerateInitialTasksParams.create(
        plantaId: plant.id,
        config: configModel,
        plantingDate: plant.plantingDate ?? plant.createdAt,
        userId: plant.userId,
      );

      final result = await generateInitialTasksUseCase!(params);

      // Log do resultado (não bloqueia o fluxo principal)
      result.fold(
        (failure) => debugPrint(
          'Warning: Falha ao gerar tarefas iniciais: ${failure.message}',
        ),
        (tasks) => debugPrint(
          'Info: ${tasks.length} tarefas iniciais geradas para planta ${plant.name}',
        ),
      );
    } catch (e) {
      // Log do erro (não bloqueia o fluxo principal)
      debugPrint('Warning: Erro inesperado ao gerar tarefas iniciais: $e');
    }
  }

  /// Converte PlantConfig entity para PlantaConfigModel
  PlantaConfigModel _convertToPlantaConfigModel(Plant plant) {
    final config = plant.config!;

    return PlantaConfigModel.create(
      plantaId: plant.id,
      userId: plant.userId,
      aguaAtiva:
          config.wateringIntervalDays != null &&
          config.wateringIntervalDays! > 0,
      intervaloRegaDias: config.wateringIntervalDays ?? 3,
      aduboAtivo:
          config.fertilizingIntervalDays != null &&
          config.fertilizingIntervalDays! > 0,
      intervaloAdubacaoDias: config.fertilizingIntervalDays ?? 14,
      podaAtiva:
          config.pruningIntervalDays != null && config.pruningIntervalDays! > 0,
      intervaloPodaDias: config.pruningIntervalDays ?? 30,
      banhoSolAtivo: true,
      intervaloBanhoSolDias: 1,
      inspecaoPragasAtiva: true,
      intervaloInspecaoPragasDias: 7,
      // Replantio pode ser definido com base no tipo de planta ou configuração
      replantarAtivo: true,
      intervaloReplantarDias: 180, // 6 meses por padrão
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
