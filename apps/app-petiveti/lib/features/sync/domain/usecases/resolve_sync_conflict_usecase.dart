import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/sync_conflict.dart';
import '../repositories/sync_repository.dart';

/// Parameters for resolving sync conflicts
class ResolveSyncConflictParams {
  final String conflictId;
  final ConflictResolution resolution;

  const ResolveSyncConflictParams({
    required this.conflictId,
    required this.resolution,
  });
}

/// Use case for resolving synchronization conflicts
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only resolves conflicts
/// - **Dependency Inversion**: Depends on repository abstraction
class ResolveSyncConflictUseCase
    extends UseCase<void, ResolveSyncConflictParams> {
  final ISyncRepository repository;

  ResolveSyncConflictUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
    ResolveSyncConflictParams params,
  ) async {
    return await repository.resolveConflict(
      params.conflictId,
      params.resolution,
    );
  }
}
