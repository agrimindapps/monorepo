import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class GetUpcomingVaccines implements UseCase<List<Vaccine>, GetUpcomingVaccinesParams> {
  final VaccineRepository repository;

  GetUpcomingVaccines(this.repository);

  @override
  Future<Either<Failure, List<Vaccine>>> call(GetUpcomingVaccinesParams params) async {
    if (params.animalId != null && params.animalId!.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do animal inválido'));
    }

    return await repository.getUpcomingVaccines(params.animalId);
  }
}

class GetUpcomingVaccinesParams {
  final String? animalId;
  
  const GetUpcomingVaccinesParams({this.animalId});
  factory GetUpcomingVaccinesParams.all() => const GetUpcomingVaccinesParams();
  factory GetUpcomingVaccinesParams.byAnimal(String animalId) => GetUpcomingVaccinesParams(animalId: animalId);
}
