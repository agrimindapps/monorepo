import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/praga.dart';
import '../repositories/pragas_repository.dart';

/// Use case to get all pragas
class GetAllPragasUseCase implements UseCase<List<Praga>, NoParams> {
  final PragasRepository repository;

  GetAllPragasUseCase(this.repository);

  @override
  Future<Either<Failure, List<Praga>>> call(NoParams params) async {
    try {
      final result = await repository.getAllPragas();
      return result.fold(
        (failure) => Left(failure),
        (pragas) {
          // Sort alphabetically by nome comum
          final sorted = List<Praga>.from(pragas);
          sorted.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
          return Right(sorted);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao buscar pragas: $e'));
    }
  }
}
