import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/animal_repository.dart';

class DeleteAnimal extends UseCase<void, String> {
  final AnimalRepository repository;

  DeleteAnimal(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    if (params.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do animal é obrigatório'));
    }

    return await repository.deleteAnimal(params);
  }
}
