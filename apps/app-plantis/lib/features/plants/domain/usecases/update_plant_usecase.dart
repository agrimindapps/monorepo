import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

class UpdatePlantUseCase implements UseCase<Plant, UpdatePlantParams> {
  final PlantsRepository repository;
  
  UpdatePlantUseCase(this.repository);
  
  @override
  Future<Either<Failure, Plant>> call(UpdatePlantParams params) async {
    // Validate plant data
    final validationResult = _validatePlant(params);
    if (validationResult != null) {
      return Left(validationResult);
    }
    
    // Get existing plant first
    final existingResult = await repository.getPlantById(params.id);
    
    return existingResult.fold(
      (failure) => Left(failure),
      (existingPlant) {
        // Update plant with new data and timestamp
        final updatedPlant = existingPlant.copyWith(
          name: params.name.trim(),
          species: params.species?.trim(),
          spaceId: params.spaceId,
          imageBase64: params.imageBase64,
          plantingDate: params.plantingDate,
          notes: params.notes?.trim(),
          config: params.config,
          updatedAt: DateTime.now(),
          isDirty: true,
        );
        
        return repository.updatePlant(updatedPlant);
      },
    );
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
      return const ValidationFailure('Espécie não pode ter mais de 100 caracteres');
    }
    
    if (params.notes != null && params.notes!.trim().length > 500) {
      return const ValidationFailure('Observações não podem ter mais de 500 caracteres');
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
  final DateTime? plantingDate;
  final String? notes;
  final PlantConfig? config;
  
  const UpdatePlantParams({
    required this.id,
    required this.name,
    this.species,
    this.spaceId,
    this.imageBase64,
    this.plantingDate,
    this.notes,
    this.config,
  });
}