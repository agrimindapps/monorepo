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
    return await repository.getVaccines(params.animalId);
  }
}

class GetVaccinesParams {
  final String animalId;
  GetVaccinesParams({required this.animalId});
}