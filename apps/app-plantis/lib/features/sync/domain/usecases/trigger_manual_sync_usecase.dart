import 'package:core/core.dart';

import '../entities/sync_result.dart';
import '../repositories/i_sync_orchestration_repository.dart';

/// Use case for triggering a manual bidirectional sync operation.
///
/// This use case orchestrates a complete sync cycle:
/// 1. Validates that sync can be performed
/// 2. Pushes pending local changes to remote
/// 3. Pulls remote changes and applies them locally
/// 4. Reports conflicts and errors
///
/// Validation includes:
/// - (Optional) Network connectivity check if available
///
/// Returns:
/// - Right(PlantisSyncResult) with sync details (processed items, conflicts, errors)
/// - Left(Failure) if sync fails:
///   - NetworkFailure: No internet connection
///   - ServerFailure: Remote server error
///   - CacheFailure: Local storage error
///
/// Example:
/// ```dart
/// final result = await triggerManualSyncUseCase(NoParams());
/// result.fold(
///   (failure) => showError(failure.message),
///   (syncResult) {
///     if (syncResult.hasConflicts) {
///       showConflictDialog(syncResult.itemsWithConflicts);
///     } else {
///       showSuccess('Synced ${syncResult.itemsProcessed} items');
///     }
///   },
/// );
/// ```
class TriggerManualSyncUseCase
    implements UseCase<PlantisSyncResult, NoParams> {
  final ISyncOrchestrationRepository _repository;

  const TriggerManualSyncUseCase(this._repository);

  @override
  Future<Either<Failure, PlantisSyncResult>> call(NoParams params) async {
    // Validation: Could check network connectivity here if service is available
    // For now, we delegate to repository which will handle network checks

    // Delegate to repository to perform the sync
    return await _repository.sync();
  }
}
