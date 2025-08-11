import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/space.dart';
import '../repositories/spaces_repository.dart';

class UpdateSpaceUseCase implements UseCase<Space, UpdateSpaceParams> {
  final SpacesRepository repository;
  
  UpdateSpaceUseCase(this.repository);
  
  @override
  Future<Either<Failure, Space>> call(UpdateSpaceParams params) async {
    // Validate space data
    final validationResult = _validateSpace(params);
    if (validationResult != null) {
      return Left(validationResult);
    }
    
    // Get existing space first
    final existingResult = await repository.getSpaceById(params.id);
    
    return existingResult.fold(
      (failure) => Left(failure),
      (existingSpace) {
        // Update space with new data and timestamp
        final updatedSpace = existingSpace.copyWith(
          name: params.name.trim(),
          description: params.description?.trim(),
          imageBase64: params.imageBase64,
          type: params.type,
          config: params.config,
          updatedAt: DateTime.now(),
          isDirty: true,
        );
        
        return repository.updateSpace(updatedSpace);
      },
    );
  }
  
  ValidationFailure? _validateSpace(UpdateSpaceParams params) {
    if (params.id.trim().isEmpty) {
      return const ValidationFailure('ID do espaço é obrigatório');
    }
    
    if (params.name.trim().isEmpty) {
      return const ValidationFailure('Nome do espaço é obrigatório');
    }
    
    if (params.name.trim().length < 2) {
      return const ValidationFailure('Nome deve ter pelo menos 2 caracteres');
    }
    
    if (params.name.trim().length > 50) {
      return const ValidationFailure('Nome não pode ter mais de 50 caracteres');
    }
    
    if (params.description != null && params.description!.trim().length > 200) {
      return const ValidationFailure('Descrição não pode ter mais de 200 caracteres');
    }
    
    if (params.config?.maxPlants != null && params.config!.maxPlants! <= 0) {
      return const ValidationFailure('Número máximo de plantas deve ser maior que 0');
    }
    
    if (params.config?.temperature != null && 
        (params.config!.temperature! < -50 || params.config!.temperature! > 60)) {
      return const ValidationFailure('Temperatura deve estar entre -50°C e 60°C');
    }
    
    if (params.config?.humidity != null && 
        (params.config!.humidity! < 0 || params.config!.humidity! > 100)) {
      return const ValidationFailure('Umidade deve estar entre 0% e 100%');
    }
    
    return null;
  }
}

class UpdateSpaceParams {
  final String id;
  final String name;
  final String? description;
  final String? imageBase64;
  final SpaceType type;
  final SpaceConfig? config;
  
  const UpdateSpaceParams({
    required this.id,
    required this.name,
    this.description,
    this.imageBase64,
    required this.type,
    this.config,
  });
}