import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/defensivo.dart';
import '../repositories/defensivos_repository.dart';

/// Use case to get all defensivos
@injectable
class GetAllDefensivosUseCase implements UseCase<List<Defensivo>, NoParams> {
  final DefensivosRepository repository;

  const GetAllDefensivosUseCase(this.repository);

  @override
  Future<Either<Failure, List<Defensivo>>> call(NoParams params) async {
    try {
      final result = await repository.getAllDefensivos();

      return result.fold(
        (failure) => Left(failure),
        (defensivos) {
          // Sort by name (business logic)
          final sorted = List<Defensivo>.from(defensivos);
          sorted.sort((a, b) => a.nomeComum.compareTo(b.nomeComum));
          return Right(sorted);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
