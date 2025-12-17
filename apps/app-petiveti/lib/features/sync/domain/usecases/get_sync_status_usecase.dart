import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../entities/sync_status.dart';
import '../repositories/sync_repository.dart';

/// Use case for retrieving sync status for all entities
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only retrieves sync status
/// - **Dependency Inversion**: Depends on repository abstraction
class GetSyncStatusUseCase
    extends UseCase<Map<String, SyncStatus>, NoParams> {
  final ISyncRepository repository;

  GetSyncStatusUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, SyncStatus>>> call(
    NoParams params,
  ) async {
    return await repository.getSyncStatus();
  }
}
