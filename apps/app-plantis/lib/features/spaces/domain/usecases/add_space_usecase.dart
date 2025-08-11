import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/space.dart';
import '../repositories/spaces_repository.dart';

class AddSpaceUseCase implements UseCase<Space, AddSpaceParams> {
  final SpacesRepository repository;
  
  AddSpaceUseCase(this.repository);
  
  @override
  Future<Either<Failure, Space>> call(AddSpaceParams params) async {
    // Validate space data
    final validationResult = _validateSpace(params);
    if (validationResult != null) {
      return Left(validationResult);
    }
    
    // Create space with timestamps
    final now = DateTime.now();
    final space = Space(
      id: params.id ?? _generateId(),
      name: params.name.trim(),
      description: params.description?.trim(),
      imageBase64: params.imageBase64,
      type: params.type,
      config: params.config,
      createdAt: now,
      updatedAt: now,
      isDirty: true,
    );
    
    return repository.addSpace(space);
  }
  
  ValidationFailure? _validateSpace(AddSpaceParams params) {
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
  
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

class AddSpaceParams {
  final String? id;
  final String name;
  final String? description;
  final String? imageBase64;
  final SpaceType type;
  final SpaceConfig? config;
  
  const AddSpaceParams({
    this.id,
    required this.name,
    this.description,
    this.imageBase64,
    required this.type,
    this.config,
  });
}