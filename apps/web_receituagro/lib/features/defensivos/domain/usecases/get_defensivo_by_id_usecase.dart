import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/defensivo.dart';
import '../repositories/defensivos_repository.dart';

/// Use case to get a defensivo by ID
class GetDefensivoByIdUseCase implements UseCase<Defensivo, String> {
  final DefensivosRepository repository;

  const GetDefensivoByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Defensivo>> call(String id) async {
    try {
      final result = await repository.getDefensivoById(id);

      return result.fold(
        (failure) => Left(failure),
        (defensivo) => Right(defensivo),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
