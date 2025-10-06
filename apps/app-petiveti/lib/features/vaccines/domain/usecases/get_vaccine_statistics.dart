import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/vaccine_repository.dart';

class GetVaccineStatistics implements UseCase<Map<String, int>, GetVaccineStatisticsParams> {
  final VaccineRepository repository;

  GetVaccineStatistics(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(GetVaccineStatisticsParams params) async {
    if (params.animalId != null && params.animalId!.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID do animal inválido'));
    }

    return await repository.getVaccineStatistics(params.animalId);
  }
}

class GetVaccineStatisticsParams {
  final String? animalId;
  
  const GetVaccineStatisticsParams({this.animalId});
  factory GetVaccineStatisticsParams.all() => const GetVaccineStatisticsParams();
  factory GetVaccineStatisticsParams.byAnimal(String animalId) => GetVaccineStatisticsParams(animalId: animalId);
}