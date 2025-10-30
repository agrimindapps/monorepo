import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/animal.dart';
import '../repositories/animal_repository.dart';

/// Use case for retrieving all animals
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only retrieves animals
/// - **Dependency Inversion**: Depends on repository abstraction
@lazySingleton
class GetAnimals extends UseCase<List<Animal>, NoParams> {
  final AnimalRepository repository;

  GetAnimals(this.repository);

  @override
  Future<Either<Failure, List<Animal>>> call(NoParams params) async {
    return await repository.getAnimals();
  }
}
