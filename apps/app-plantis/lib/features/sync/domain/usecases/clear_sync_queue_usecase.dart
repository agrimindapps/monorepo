import 'package:core/core.dart';

import '../repositories/i_sync_orchestration_repository.dart';

/// Use case for clearing completed items from the sync queue.
///
/// This use case removes successfully synced items from the queue to
/// keep it clean and manageable. It provides important safety guarantees:
///
/// Safety Rules:
/// 1. NEVER deletes pending items (items waiting to be synced)
/// 2. NEVER deletes failed items (items that need retry)
/// 3. ONLY removes successfully completed sync operations
/// 4. Cannot clear while sync is actively in progress
///
/// This ensures no data loss and maintains sync integrity.
///
/// Returns:
/// - Right(void) if queue is cleared successfully
/// - Left(Failure) if clearing fails:
///   - ValidationFailure: Cannot clear (sync in progress or has pending items)
///   - CacheFailure: Local storage error
///
/// Example:
/// ```dart
/// final result = await clearSyncQueueUseCase(NoParams());
/// result.fold(
///   (failure) {
///     if (failure is ValidationFailure) {
///       showInfo('Cannot clear: ${failure.message}');
///     } else {
///       showError('Clear failed: ${failure.message}');
///     }
///   },
///   (_) => showSuccess('Sync queue cleaned'),
/// );
/// ```
class ClearSyncQueueUseCase implements UseCase<void, NoParams> {
  final ISyncOrchestrationRepository _repository;

  const ClearSyncQueueUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    // Validation is delegated to repository which will check:
    // 1. No sync is currently in progress
    // 2. Safe to clear (only completed items will be removed)
    //
    // Repository will return ValidationFailure if:
    // - Sync is currently running
    // - There are pending operations that shouldn't be cleared

    // Delegate to repository to safely clear the queue
    return await _repository.clearSyncQueue();
  }
}
