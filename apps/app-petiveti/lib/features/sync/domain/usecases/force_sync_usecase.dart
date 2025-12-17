import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/sync_repository.dart';

/// Parameters for forcing sync
class ForceSyncParams {
  final String? entityType;

  const ForceSyncParams({this.entityType});
}

/// Use case for forcing synchronization
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only triggers sync operations
/// - **Dependency Inversion**: Depends on repository abstraction
class ForceSyncUseCase extends UseCase<void, ForceSyncParams> {
  final ISyncRepository repository;

  ForceSyncUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ForceSyncParams params) async {
    if (params.entityType != null) {
      return await repository.forceSyncEntity(params.entityType!);
    } else {
      return await repository.forceSyncAll();
    }
  }
}
