import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class GetVaccinesByAnimal implements UseCase<List<Vaccine>, String> {
  final VaccineRepository repository;

  GetVaccinesByAnimal(this.repository);

  @override
  Future<Either<Failure, List<Vaccine>>> call(String animalId) async {
    if (animalId.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do animal é obrigatório'));
    }

    return await repository.getVaccinesByAnimal(animalId);
  }
}