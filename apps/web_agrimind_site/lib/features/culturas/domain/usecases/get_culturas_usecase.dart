import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/cultura_entity.dart';
import '../repositories/culturas_repository.dart';

/// Use case to get all culturas
///
/// Retrieves all available culturas from the repository
@injectable
class GetCulturasUseCase implements UseCase<List<CulturaEntity>, NoParams> {
  final ICulturasRepository _repository;

  const GetCulturasUseCase(this._repository);

  @override
  Future<Either<Failure, List<CulturaEntity>>> call(NoParams params) async {
    return await _repository.getCulturas();
  }
}
