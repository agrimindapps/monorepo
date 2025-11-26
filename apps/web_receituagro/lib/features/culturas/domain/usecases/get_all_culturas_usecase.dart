import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/cultura.dart';
import '../repositories/culturas_repository.dart';

/// Use case to get all culturas
class GetAllCulturasUseCase implements UseCase<List<Cultura>, NoParams> {
  final CulturasRepository repository;

  GetAllCulturasUseCase(this.repository);

  @override
  Future<Either<Failure, List<Cultura>>> call(NoParams params) async {
    try {
      final result = await repository.getAllCulturas();
      return result.fold(
        (failure) => Left(failure),
        (culturas) {
          // Sort alphabetically by nome comum
          final sorted = List<Cultura>.from(culturas);
          sorted.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
          return Right(sorted);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Erro ao buscar culturas: $e'));
    }
  }
}
