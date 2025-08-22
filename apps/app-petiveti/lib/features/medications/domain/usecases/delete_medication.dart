import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/medication_repository.dart';

class DeleteMedication implements UseCase<void, String> {
  final MedicationRepository repository;

  DeleteMedication(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    if (id.trim().isEmpty) {
      return Left(ValidationFailure(message: 'ID do medicamento é obrigatório'));
    }
    
    return await repository.deleteMedication(id);
  }
}

class DiscontinueMedication implements UseCase<void, DiscontinueMedicationParams> {
  final MedicationRepository repository;

  DiscontinueMedication(this.repository);

  @override
  Future<Either<Failure, void>> call(DiscontinueMedicationParams params) async {
    if (params.id.trim().isEmpty) {
      return Left(ValidationFailure(message: 'ID do medicamento é obrigatório'));
    }
    
    if (params.reason.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Motivo da descontinuação é obrigatório'));
    }
    
    return await repository.discontinueMedication(params.id, params.reason);
  }
}

class DiscontinueMedicationParams {
  final String id;
  final String reason;

  const DiscontinueMedicationParams({
    required this.id,
    required this.reason,
  });
}