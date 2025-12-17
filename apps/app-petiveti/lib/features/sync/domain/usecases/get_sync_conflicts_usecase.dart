import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/sync_conflict.dart';
import '../repositories/sync_repository.dart';

/// Parameters for getting sync conflicts
class GetSyncConflictsParams {
  final String? entityType;

  const GetSyncConflictsParams({this.entityType});
}

/// Use case for retrieving unresolved sync conflicts
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only retrieves conflicts
/// - **Dependency Inversion**: Depends on repository abstraction
class GetSyncConflictsUseCase
    extends UseCase<List<SyncConflict>, GetSyncConflictsParams> {
  final ISyncRepository repository;

  GetSyncConflictsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SyncConflict>>> call(
    GetSyncConflictsParams params,
  ) async {
    return await repository.getSyncConflicts(
      entityType: params.entityType,
    );
  }
}
