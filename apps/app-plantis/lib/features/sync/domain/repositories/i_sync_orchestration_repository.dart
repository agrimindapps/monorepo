import 'package:core/core.dart';

import '../entities/conflict_item.dart';
import '../entities/sync_result.dart';
import '../entities/sync_status.dart' as plantis;

/// Repository interface for orchestrating sync operations.
///
/// This repository coordinates bidirectional sync between local and remote data,
/// handles conflict resolution, and manages the sync queue. It serves as the
/// primary contract for all sync-related data operations.
///
/// Implementations should handle:
/// - Bidirectional data synchronization (push + pull)
/// - Conflict detection and resolution
/// - Failed operation retry logic
/// - Sync status monitoring
///
/// All methods return Either<Failure, T> for consistent error handling.
abstract class ISyncOrchestrationRepository {
  /// Performs a complete bidirectional sync operation.
  ///
  /// This method:
  /// 1. Pushes all pending local changes to remote
  /// 2. Pulls remote changes and applies them locally
  /// 3. Detects and reports any conflicts
  /// 4. Updates sync status throughout the process
  ///
  /// Returns:
  /// - Right(PlantisSyncResult) with details about processed items and conflicts
  /// - Left(Failure) if sync fails:
  ///   - NetworkFailure: No internet connection
  ///   - ServerFailure: Remote server error
  ///   - CacheFailure: Local storage error
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.sync();
  /// result.fold(
  ///   (failure) => print('Sync failed: ${failure.message}'),
  ///   (syncResult) => print('Synced ${syncResult.itemsProcessed} items'),
  /// );
  /// ```
  Future<Either<Failure, PlantisSyncResult>> sync();

  /// Retries all operations that previously failed during sync.
  ///
  /// This method attempts to re-process items that encountered errors
  /// during previous sync operations. Useful for recovering from transient
  /// network issues or temporary server problems.
  ///
  /// Returns:
  /// - Right(void) if retry succeeds
  /// - Left(Failure) if retry fails:
  ///   - ValidationFailure: No failed operations to retry
  ///   - NetworkFailure: No internet connection
  ///   - ServerFailure: Remote server error
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.retryFailedOperations();
  /// result.fold(
  ///   (failure) => print('Retry failed: ${failure.message}'),
  ///   (_) => print('Failed operations retried successfully'),
  /// );
  /// ```
  Future<Either<Failure, void>> retryFailedOperations();

  /// Resolves a specific conflict using the provided strategy.
  ///
  /// This method manually resolves a conflict that was detected during sync.
  /// The resolution strategy determines which version (local/remote) to keep
  /// or how to merge them.
  ///
  /// Parameters:
  /// - [itemId]: Unique identifier of the conflicted item
  /// - [strategy]: How to resolve the conflict (newerWins, localWins, etc.)
  ///
  /// Returns:
  /// - Right(void) if conflict is resolved successfully
  /// - Left(Failure) if resolution fails:
  ///   - ValidationFailure: Invalid itemId or strategy
  ///   - CacheFailure: Conflict not found or storage error
  ///   - ServerFailure: Failed to apply resolution remotely
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.resolveConflict(
  ///   itemId: 'plant-123',
  ///   strategy: PlantisConflictStrategy.localWins,
  /// );
  /// result.fold(
  ///   (failure) => print('Resolution failed: ${failure.message}'),
  ///   (_) => print('Conflict resolved successfully'),
  /// );
  /// ```
  Future<Either<Failure, void>> resolveConflict({
    required String itemId,
    required PlantisConflictStrategy strategy,
  });

  /// Watches the sync status in real-time.
  ///
  /// This stream emits updates whenever the sync status changes,
  /// allowing UI to react to sync progress, completion, or errors.
  ///
  /// The stream will emit:
  /// - Current status immediately upon subscription
  /// - Updates when sync state changes (idle -> syncing -> success/error)
  /// - Progress updates during active sync operations
  ///
  /// Example:
  /// ```dart
  /// repository.watchSyncStatus().listen((status) {
  ///   if (status.isSyncing) {
  ///     print('Syncing: ${status.progressPercentage}%');
  ///   } else if (status.hasError) {
  ///     print('Error: ${status.errorMessage}');
  ///   }
  /// });
  /// ```
  Stream<plantis.PlantisSyncStatus> watchSyncStatus();

  /// Gets the current sync status as a snapshot.
  ///
  /// This method returns the current state without subscribing to changes.
  /// Use [watchSyncStatus] if you need real-time updates.
  ///
  /// Returns:
  /// - Right(PlantisSyncStatus) with current sync state
  /// - Left(Failure) if status cannot be retrieved:
  ///   - CacheFailure: Local storage error
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.getCurrentSyncStatus();
  /// result.fold(
  ///   (failure) => print('Failed to get status'),
  ///   (status) => print('Pending items: ${status.pendingCount}'),
  /// );
  /// ```
  Future<Either<Failure, plantis.PlantisSyncStatus>> getCurrentSyncStatus();

  /// Clears all successfully synced items from the sync queue.
  ///
  /// This method removes completed sync operations to keep the queue clean.
  /// It NEVER deletes pending or failed items - only successfully synced ones.
  ///
  /// Returns:
  /// - Right(void) if queue is cleared successfully
  /// - Left(Failure) if clearing fails:
  ///   - ValidationFailure: Cannot clear while sync is in progress
  ///   - CacheFailure: Local storage error
  ///
  /// Example:
  /// ```dart
  /// final result = await repository.clearSyncQueue();
  /// result.fold(
  ///   (failure) => print('Clear failed: ${failure.message}'),
  ///   (_) => print('Sync queue cleaned'),
  /// );
  /// ```
  Future<Either<Failure, void>> clearSyncQueue();
}
