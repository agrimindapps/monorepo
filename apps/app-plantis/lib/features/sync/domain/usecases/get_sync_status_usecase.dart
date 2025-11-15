import 'package:core/core.dart';

import '../entities/sync_status.dart' as plantis;
import '../repositories/i_sync_orchestration_repository.dart';

/// Use case for retrieving the current sync status.
///
/// This use case provides a snapshot of the current sync state without
/// subscribing to real-time updates. Use this when you need the status
/// once rather than watching for changes.
///
/// For real-time updates, use [WatchSyncStatusUseCase] instead.
///
/// Returns:
/// - Right(PlantisSyncStatus) with current state, pending/failed counts, etc.
/// - Left(Failure) if status cannot be retrieved:
///   - CacheFailure: Local storage error
///
/// The returned status includes:
/// - Current state (idle, syncing, error, success)
/// - Number of pending items
/// - Number of failed items
/// - Last sync timestamp
/// - Error message if applicable
/// - Progress percentage if syncing
///
/// Example:
/// ```dart
/// final result = await getSyncStatusUseCase(NoParams());
/// result.fold(
///   (failure) => showError('Failed to get status: ${failure.message}'),
///   (status) {
///     print('State: ${status.state}');
///     print('Pending: ${status.pendingCount}');
///     print('Failed: ${status.failedCount}');
///     if (status.lastSyncAt != null) {
///       print('Last sync: ${status.lastSyncAt}');
///     }
///   },
/// );
/// ```
class GetSyncStatusUseCase
    implements UseCase<plantis.PlantisSyncStatus, NoParams> {
  final ISyncOrchestrationRepository _repository;

  const GetSyncStatusUseCase(this._repository);

  @override
  Future<Either<Failure, plantis.PlantisSyncStatus>> call(
    NoParams params,
  ) async {
    // No validation needed - this is a simple query operation

    // Delegate to repository to get current status
    return await _repository.getCurrentSyncStatus();
  }
}

/// Use case for watching sync status changes in real-time.
///
/// This use case provides a stream of sync status updates, allowing
/// UI to react to changes as they happen.
///
/// The stream emits:
/// - Current status immediately upon subscription
/// - Updates when sync state changes
/// - Progress updates during active sync
///
/// Example:
/// ```dart
/// watchSyncStatusUseCase(NoParams()).listen((status) {
///   if (status.isSyncing) {
///     showProgress(status.progressPercentage ?? 0);
///   } else if (status.hasError) {
///     showError(status.errorMessage ?? 'Unknown error');
///   } else if (status.isSuccess) {
///     showSuccess('Sync completed');
///   }
/// });
/// ```
class WatchSyncStatusUseCase {
  final ISyncOrchestrationRepository _repository;

  const WatchSyncStatusUseCase(this._repository);

  /// Watches sync status changes in real-time.
  ///
  /// Returns a stream that emits [PlantisSyncStatus] updates.
  Stream<plantis.PlantisSyncStatus> call(NoParams params) {
    return _repository.watchSyncStatus();
  }
}
