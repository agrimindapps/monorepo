import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class GetVaccines implements UseCase<List<Vaccine>, GetVaccinesParams> {
  final VaccineRepository repository;

  GetVaccines(this.repository);

  @override
  Future<Either<Failure, List<Vaccine>>> call(GetVaccinesParams params) async {
    if (params.animalId != null && params.animalId!.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do animal inválido'));
    }

    if (params.animalId != null) {
      return await repository.getVaccinesByAnimal(params.animalId!);
    } else {
      return await repository.getVaccines();
    }
  }
}

class GetVaccinesParams {
  final String? animalId;
  
  const GetVaccinesParams({this.animalId});
  
  // Factory constructors for convenience
  factory GetVaccinesParams.all() => const GetVaccinesParams();
  factory GetVaccinesParams.byAnimal(String animalId) => GetVaccinesParams(animalId: animalId);
}