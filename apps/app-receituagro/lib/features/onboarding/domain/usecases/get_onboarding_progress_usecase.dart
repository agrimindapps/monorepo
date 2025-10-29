import 'package:core/core.dart';

import '../entities/entities.dart';
import '../repositories/i_onboarding_repository.dart';

/// Use case: Get current user onboarding progress
///
/// RN-ON004: Query current progress:
/// - Load progress from persistent storage
/// - Return null if no progress found (user hasn't started)
/// - No side effects (read-only operation)
///
/// Parameters: No parameters (uses NoParams pattern)
/// Returns: [OnboardingProgress?] or null if not started
/// Failures: [CacheFailure] if storage read fails
class GetOnboardingProgressUseCase
    implements UseCase<OnboardingProgress?, NoParams> {
  final IOnboardingRepository _repository;

  GetOnboardingProgressUseCase(this._repository);

  @override
  Future<Either<Failure, OnboardingProgress?>> call(NoParams params) async {
    try {
      // Load progress from persistent storage
      // Returns null if no progress found
      return await _repository.getProgress();
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Failed to get onboarding progress: ${e.toString()}',
        ),
      );
    }
  }
}
