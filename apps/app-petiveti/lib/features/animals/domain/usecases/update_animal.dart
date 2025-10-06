import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/animal.dart';
import '../repositories/animal_repository.dart';

class UpdateAnimal extends UseCase<void, Animal> {
  final AnimalRepository repository;

  UpdateAnimal(this.repository);

  @override
  Future<Either<Failure, void>> call(Animal params) async {
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Nome do animal é obrigatório'));
    }
    
    if (params.species.name.isEmpty) {
      return const Left(ValidationFailure(message: 'Espécie é obrigatória'));
    }
    
    if (params.weight != null && params.weight! <= 0) {
      return const Left(ValidationFailure(message: 'Peso deve ser maior que zero'));
    }
    final updatedAnimal = params.copyWith(updatedAt: DateTime.now());
    
    return await repository.updateAnimal(updatedAnimal);
  }
}
