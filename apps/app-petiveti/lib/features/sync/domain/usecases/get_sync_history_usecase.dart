import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/sync_operation.dart';
import '../repositories/sync_repository.dart';

/// Parameters for getting sync history
class GetSyncHistoryParams {
  final int limit;
  final String? entityType;

  const GetSyncHistoryParams({
    this.limit = 50,
    this.entityType,
  });
}

/// Use case for retrieving sync operation history
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only retrieves sync history
/// - **Dependency Inversion**: Depends on repository abstraction
class GetSyncHistoryUseCase
    extends UseCase<List<SyncOperation>, GetSyncHistoryParams> {
  final ISyncRepository repository;

  GetSyncHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<SyncOperation>>> call(
    GetSyncHistoryParams params,
  ) async {
    return await repository.getSyncHistory(
      limit: params.limit,
      entityType: params.entityType,
    );
  }
}
