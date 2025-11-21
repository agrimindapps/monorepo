import 'package:core/core.dart' hide Column;

import '../entities/entities.dart';
import '../repositories/i_onboarding_repository.dart';

/// Use case: Start the onboarding flow for a user
///
/// RN-ON001: When onboarding starts:
/// - Create new progress with empty completedSteps
/// - Set current step to first step ID
/// - Record start timestamp
/// - Log analytics event
/// - Save to persistent storage
///
/// Parameters: No parameters (uses NoParams pattern)
/// Returns: OnboardingProgress with initial state
/// Failures: [CacheFailure] if storage save fails
class StartOnboardingUseCase
    implements UseCase<OnboardingProgress, NoParams> {
  final IOnboardingRepository _repository;
  final IAnalyticsRepository _analytics;

  StartOnboardingUseCase(
    this._repository,
    this._analytics,
  );

  @override
  Future<Either<Failure, OnboardingProgress>> call(NoParams params) async {
    try {
      // Get available steps to determine initial state
      final stepsResult = _repository.getOnboardingSteps();

      return stepsResult.fold(
        // If getting steps failed, propagate the failure
        (failure) => Left(failure),
        // If steps retrieved successfully
        (steps) async {
          if (steps.isEmpty) {
            return const Left(
              UnexpectedFailure('No onboarding steps configured'),
            );
          }

          // Create initial progress
          final progress = OnboardingProgress(
            completedSteps: {},
            startedAt: DateTime.now(),
            completedAt: null,
            currentStep: steps.first.id,
            isCompleted: false,
          );

          // Save progress to persistent storage
          final saveResult = await _repository.saveProgress(progress);

          return saveResult.fold(
            // If saving failed, propagate the failure
            (failure) => Left(failure),
            // If saving succeeded, log event and return progress
            (_) async {
              // Log analytics event (fire-and-forget, non-blocking)
              await _analytics.logEvent(
                'onboarding_started',
                parameters: {
                  'total_steps': steps.length,
                  'timestamp': DateTime.now().toIso8601String(),
                },
              );

              return Right(progress);
            },
          );
        },
      );
    } catch (e) {
      return Left(
        UnexpectedFailure('Failed to start onboarding: ${e.toString()}'),
      );
    }
  }
}
