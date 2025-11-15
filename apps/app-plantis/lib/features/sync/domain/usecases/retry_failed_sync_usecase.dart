import 'package:core/core.dart';

import '../repositories/i_sync_orchestration_repository.dart';

/// Use case for retrying operations that failed during previous sync attempts.
///
/// This use case re-processes items that encountered errors during sync,
/// such as:
/// - Network timeouts
/// - Temporary server errors
/// - Transient storage issues
///
/// The use case will:
/// 1. Identify all items marked as failed
/// 2. Attempt to re-sync each failed item
/// 3. Update their status based on retry results
///
/// Returns:
/// - Right(void) if retry succeeds
/// - Left(Failure) if retry fails:
///   - ValidationFailure: No failed operations to retry
///   - NetworkFailure: No internet connection
///   - ServerFailure: Remote server error
///   - CacheFailure: Local storage error
///
/// Example:
/// ```dart
/// final result = await retryFailedSyncUseCase(NoParams());
/// result.fold(
///   (failure) {
///     if (failure is ValidationFailure) {
///       showInfo('No failed items to retry');
///     } else {
///       showError('Retry failed: ${failure.message}');
///     }
///   },
///   (_) => showSuccess('Failed items retried successfully'),
/// );
/// ```
class RetryFailedSyncUseCase implements UseCase<void, NoParams> {
  final ISyncOrchestrationRepository _repository;

  const RetryFailedSyncUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    // Validation: Repository will check if there are failed operations
    // If none exist, it will return ValidationFailure

    // Delegate to repository to retry failed operations
    return await _repository.retryFailedOperations();
  }
}
