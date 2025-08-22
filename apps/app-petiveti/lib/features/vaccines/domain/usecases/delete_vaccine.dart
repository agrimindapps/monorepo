import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/vaccine_repository.dart';

class DeleteVaccine implements UseCase<void, String> {
  final VaccineRepository repository;

  DeleteVaccine(this.repository);

  @override
  Future<Either<Failure, void>> call(String vaccineId) async {
    if (vaccineId.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'ID da vacina é obrigatório'));
    }

    return await repository.deleteVaccine(vaccineId);
  }
}