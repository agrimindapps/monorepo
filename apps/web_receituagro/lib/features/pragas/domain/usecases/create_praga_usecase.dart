import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/praga.dart';
import '../repositories/pragas_repository.dart';

class CreatePragaUseCase implements UseCase<Praga, Praga> {
  final PragasRepository repository;

  CreatePragaUseCase(this.repository);

  @override
  Future<Either<Failure, Praga>> call(Praga praga) async {
    // Validation
    if (praga.nomeComum.trim().length < 3) {
      return Left(ValidationFailure('Nome comum deve ter no mínimo 3 caracteres'));
    }

    if (praga.nomeCientifico.trim().length < 3) {
      return Left(ValidationFailure('Nome científico deve ter no mínimo 3 caracteres'));
    }

    if (praga.ordem.trim().isEmpty) {
      return Left(ValidationFailure('Ordem é obrigatória'));
    }

    if (praga.familia.trim().isEmpty) {
      return Left(ValidationFailure('Família é obrigatória'));
    }

    return repository.createPraga(praga);
  }
}