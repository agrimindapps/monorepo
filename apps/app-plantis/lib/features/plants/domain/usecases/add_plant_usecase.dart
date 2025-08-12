import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/plant.dart';
import '../repositories/plants_repository.dart';

class AddPlantUseCase implements UseCase<Plant, AddPlantParams> {
  final PlantsRepository repository;
  
  AddPlantUseCase(this.repository);
  
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
    
    return repository.addPlant(plant);
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
      return const ValidationFailure('Espécie não pode ter mais de 100 caracteres');
    }
    
    if (params.notes != null && params.notes!.trim().length > 500) {
      return const ValidationFailure('Observações não podem ter mais de 500 caracteres');
    }
    
    return null;
  }
  
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
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