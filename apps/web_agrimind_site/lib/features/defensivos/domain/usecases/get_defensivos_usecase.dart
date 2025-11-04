import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/defensivo_entity.dart';
import '../repositories/defensivos_repository.dart';

/// Use case to get all defensivos
///
/// Retrieves all available defensivos from the repository
@injectable
class GetDefensivosUseCase
    implements UseCase<List<DefensivoEntity>, NoParams> {
  final IDefensivosRepository _repository;

  const GetDefensivosUseCase(this._repository);

  @override
  Future<Either<Failure, List<DefensivoEntity>>> call(NoParams params) async {
    return await _repository.getDefensivos();
  }
}
