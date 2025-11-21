import 'package:core/core.dart' hide Column;

import '../entities/entities.dart';
import '../repositories/i_onboarding_repository.dart';
import 'complete_step_usecase.dart';

/// Parameters for SkipStepUseCase
class SkipStepParams {
  final String stepId;
  final OnboardingProgress currentProgress;

  const SkipStepParams({
    required this.stepId,
    required this.currentProgress,
  });
}

/// Use case: Skip an optional onboarding step
///
/// RN-ON003: Skip optional step flow:
/// 1. Verify step exists
/// 2. Verify step is NOT required (can only skip optional steps)
/// 3. Mark step as completed (same as complete_step)
/// 4. Log analytics event with 'skipped' flag
/// 5. Check onboarding completion status
///
/// Parameters: [SkipStepParams] with stepId and current progress
/// Returns: Updated [OnboardingProgress]
/// Failures:
/// - [ValidationFailure] if step not found
/// - [ValidationFailure] if step is required (cannot skip)
/// - [CacheFailure] if storage save fails
class SkipStepUseCase implements UseCase<OnboardingProgress, SkipStepParams> {
  final IOnboardingRepository _repository;
  final IAnalyticsRepository _analytics;
  final CompleteStepUseCase _completeStepUseCase;

  SkipStepUseCase(
    this._repository,
    this._analytics,
    this._completeStepUseCase,
  );

  @override
  Future<Either<Failure, OnboardingProgress>> call(
    SkipStepParams params,
  ) async {
    try {
      // Get steps to validate step requirements
      final stepsResult = _repository.getOnboardingSteps();

      return stepsResult.fold(
        // If getting steps failed, propagate failure
        (failure) => Left(failure),
        // If steps retrieved successfully, validate and process
        (steps) async {
          // VALIDATION 1: Step exists
          final stepIndex =
              steps.indexWhere((s) => s.id == params.stepId);
          if (stepIndex == -1) {
            return Left(
              ValidationFailure('Step not found: ${params.stepId}'),
            );
          }

          final step = steps[stepIndex];

          // VALIDATION 2: Step must be optional (not required)
          if (step.isRequired) {
            return Left(
              ValidationFailure(
                'Cannot skip required step: ${params.stepId}',
              ),
            );
          }

          // Log skip event
          await _analytics.logEvent(
            'onboarding_step_skipped',
            parameters: {
              'step_id': params.stepId,
              'step_title': step.title,
              'timestamp': DateTime.now().toIso8601String(),
            },
          );

          // LOGIC: Use CompleteStepUseCase to mark as completed
          // (same as completing the step)
          final completeParams = CompleteStepParams(
            stepId: params.stepId,
            currentProgress: params.currentProgress,
          );

          return _completeStepUseCase.call(completeParams);
        },
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Failed to skip step: ${e.toString()}',
        ),
      );
    }
  }
}
