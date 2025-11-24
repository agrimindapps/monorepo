import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/pragas_repository.dart';

class DeletePragaUseCase implements UseCase<void, String> {
  final PragasRepository repository;

  DeletePragaUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String pragaId) async {
    if (pragaId.trim().isEmpty) {
      return Left(ValidationFailure('ID da praga é obrigatório'));
    }

    return repository.deletePraga(pragaId);
  }
}