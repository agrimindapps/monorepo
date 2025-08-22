import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class AddVaccine implements UseCase<Vaccine, AddVaccineParams> {
  final VaccineRepository repository;

  AddVaccine(this.repository);

  @override
  Future<Either<Failure, Vaccine>> call(AddVaccineParams params) async {
    if (params.vaccine.name.isEmpty) {
      return Left(ValidationFailure(message: 'Nome da vacina é obrigatório'));
    }
    
    if (params.vaccine.animalId.isEmpty) {
      return Left(ValidationFailure(message: 'Animal deve ser selecionado'));
    }

    return await repository.addVaccine(params.vaccine);
  }
}

class AddVaccineParams {
  final Vaccine vaccine;
  AddVaccineParams({required this.vaccine});
}