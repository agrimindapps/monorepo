import 'package:dartz/dartz.dart';

import '../../error/failures.dart';
import '../../interfaces/usecase.dart';
import '../entities/recent_access.dart';
import '../repositories/recent_access_repository.dart';

/// Use case for getting recent defensivos
class GetRecentDefensivosUseCase
    implements UseCase<List<RecentAccess>, NoParams> {
  final RecentAccessRepository _repository;

  GetRecentDefensivosUseCase(this._repository);

  @override
  Future<Either<Failure, List<RecentAccess>>> call(NoParams params) async {
    return _repository.getRecentDefensivos();
  }
}
