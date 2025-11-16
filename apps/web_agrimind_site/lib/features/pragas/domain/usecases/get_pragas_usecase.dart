import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/praga_entity.dart';
import '../repositories/pragas_repository.dart';

/// Get pragas use case
///
/// Retrieves all pragas from the repository
class GetPragasUseCase implements UseCase<List<PragaEntity>, NoParams> {
  final IPragasRepository _repository;

  GetPragasUseCase(this._repository);

  @override
  Future<Either<Failure, List<PragaEntity>>> call(NoParams params) async {
    return await _repository.getPragas();
  }
}
