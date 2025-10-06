import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class GetVaccineById implements UseCase<Vaccine?, String> {
  final VaccineRepository repository;

  GetVaccineById(this.repository);

  @override
  Future<Either<Failure, Vaccine?>> call(String vaccineId) async {
    if (vaccineId.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID da vacina é obrigatório'));
    }

    return await repository.getVaccineById(vaccineId);
  }
}
