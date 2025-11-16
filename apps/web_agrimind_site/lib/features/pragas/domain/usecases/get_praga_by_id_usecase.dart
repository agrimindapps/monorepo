import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/praga_entity.dart';
import '../repositories/pragas_repository.dart';

/// Get praga by ID use case
///
/// Retrieves a specific praga from the repository
class GetPragaByIdUseCase implements UseCase<PragaEntity, String> {
  final IPragasRepository _repository;

  GetPragaByIdUseCase(this._repository);

  @override
  Future<Either<Failure, PragaEntity>> call(String id) async {
    return await _repository.getPragaById(id);
  }
}
