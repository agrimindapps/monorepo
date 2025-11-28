import 'package:dartz/dartz.dart';

import '../../error/failures.dart';
import '../../interfaces/usecase.dart';
import '../entities/recent_access.dart';
import '../repositories/recent_access_repository.dart';

/// Parameters for adding a recent access
class AddRecentAccessParams {
  final RecentAccess access;

  const AddRecentAccessParams(this.access);
}

/// Use case for adding a recent access entry
class AddRecentAccessUseCase implements UseCase<void, AddRecentAccessParams> {
  final RecentAccessRepository _repository;

  AddRecentAccessUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(AddRecentAccessParams params) async {
    return _repository.addRecentAccess(params.access);
  }
}
