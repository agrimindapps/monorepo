import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/animal.dart';
import '../repositories/animal_repository.dart';

class GetAnimalById extends UseCase<Animal?, String> {
  final AnimalRepository repository;

  GetAnimalById(this.repository);

  @override
  Future<Either<Failure, Animal?>> call(String params) async {
    if (params.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do animal é obrigatório'));
    }

    return await repository.getAnimalById(params);
  }
}
