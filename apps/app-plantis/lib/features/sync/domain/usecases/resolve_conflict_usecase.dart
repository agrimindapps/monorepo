import 'package:core/core.dart';

import '../entities/conflict_item.dart';
import '../repositories/i_sync_orchestration_repository.dart';

/// Use case for resolving a specific sync conflict.
///
/// This use case handles manual resolution of conflicts detected during sync.
/// It validates the resolution parameters and applies the chosen strategy.
///
/// Validation rules:
/// - Item ID must not be empty
/// - Conflict strategy must be valid
///
/// Resolution strategies:
/// - newerWins: Choose version with most recent timestamp
/// - localWins: Keep local version
/// - remoteWins: Use remote version
/// - merge: Intelligently merge both versions
/// - manual: User has manually chosen resolution
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
/// final params = ResolveConflictParams(
///   itemId: 'plant-123',
///   strategy: PlantisConflictStrategy.localWins,
/// );
///
/// final result = await resolveConflictUseCase(params);
/// result.fold(
///   (failure) => showError('Resolution failed: ${failure.message}'),
///   (_) => showSuccess('Conflict resolved'),
/// );
/// ```
class ResolveConflictUseCase implements UseCase<void, ResolveConflictParams> {
  final ISyncOrchestrationRepository _repository;

  const ResolveConflictUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ResolveConflictParams params) async {
    // Validate item ID
    if (params.itemId.trim().isEmpty) {
      return const Left(
        ValidationFailure('Item ID é obrigatório para resolver conflito'),
      );
    }

    // Validate strategy (enum is always valid, but we check for completeness)
    // All ConflictStrategy values are valid, so no additional validation needed

    // Delegate to repository to resolve the conflict
    return await _repository.resolveConflict(
      itemId: params.itemId.trim(),
      strategy: params.strategy,
    );
  }
}

/// Parameters for resolving a sync conflict.
class ResolveConflictParams {
  /// Unique identifier of the item with conflict
  final String itemId;

  /// Strategy to use for resolving the conflict
  final PlantisConflictStrategy strategy;

  const ResolveConflictParams({
    required this.itemId,
    required this.strategy,
  });
}
