import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class GetOverdueVaccines implements UseCase<List<Vaccine>, GetOverdueVaccinesParams> {
  final VaccineRepository repository;

  GetOverdueVaccines(this.repository);

  @override
  Future<Either<Failure, List<Vaccine>>> call(GetOverdueVaccinesParams params) async {
    if (params.animalId != null && params.animalId!.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do animal inválido'));
    }

    return await repository.getOverdueVaccines(params.animalId);
  }
}

class GetOverdueVaccinesParams {
  final String? animalId;
  
  const GetOverdueVaccinesParams({this.animalId});
  factory GetOverdueVaccinesParams.all() => const GetOverdueVaccinesParams();
  factory GetOverdueVaccinesParams.byAnimal(String animalId) => GetOverdueVaccinesParams(animalId: animalId);
}