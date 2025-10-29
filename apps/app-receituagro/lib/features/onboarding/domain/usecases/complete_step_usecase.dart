import 'package:core/core.dart';

import '../entities/entities.dart';
import '../repositories/i_onboarding_repository.dart';

/// Parameters for CompleteStepUseCase
class CompleteStepParams {
  final String stepId;
  final OnboardingProgress currentProgress;

  const CompleteStepParams({
    required this.stepId,
    required this.currentProgress,
  });
}

/// Use case: Mark an onboarding step as completed
///
/// RN-ON002: Complete step with validation:
/// 1. Verify step exists
/// 2. Verify all dependencies are completed
/// 3. Update progress state (mark step completed, move to next step)
/// 4. Check if all required steps are completed (onboarding completion)
/// 5. Save updated progress
/// 6. Log analytics event
///
/// Parameters: [CompleteStepParams] with stepId and current progress
/// Returns: Updated [OnboardingProgress]
/// Failures:
/// - [ValidationFailure] if step not found
/// - [ValidationFailure] if dependency not completed
/// - [CacheFailure] if storage save fails
class CompleteStepUseCase implements UseCase<OnboardingProgress, CompleteStepParams> {
  final IOnboardingRepository _repository;
  final IAnalyticsRepository _analytics;

  CompleteStepUseCase(
    this._repository,
    this._analytics,
  );

  @override
  Future<Either<Failure, OnboardingProgress>> call(
    CompleteStepParams params,
  ) async {
    try {
      // Get available steps to validate and calculate state
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

          // VALIDATION 2: All dependencies completed
          for (final depId in step.dependencies) {
            if (params.currentProgress.completedSteps[depId] != true) {
              return Left(
                ValidationFailure(
                  'Dependency not completed: $depId',
                ),
              );
            }
          }

          // LOGIC: Update progress state
          final updatedSteps =
              Map<String, bool>.from(params.currentProgress.completedSteps);
          updatedSteps[params.stepId] = true;

          // LOGIC: Determine next step
          final nextStepIndex = stepIndex + 1;
          final nextStep = nextStepIndex < steps.length
              ? steps[nextStepIndex]
              : null;

          // LOGIC: Check if onboarding is completed
          // Onboarding is complete when ALL REQUIRED steps are completed
          final requiredSteps = steps.where((s) => s.isRequired).toList();
          final completedRequiredCount = requiredSteps
              .where((s) => updatedSteps[s.id] == true)
              .length;
          final isOnboardingCompleted =
              completedRequiredCount == requiredSteps.length;

          // Create updated progress
          final updatedProgress = params.currentProgress.copyWith(
            completedSteps: updatedSteps,
            currentStep: nextStep?.id ?? '',
            isCompleted: isOnboardingCompleted,
            completedAt: isOnboardingCompleted ? DateTime.now() : null,
          );

          // PERSISTENCE: Save updated progress
          final saveResult =
              await _repository.saveProgress(updatedProgress);

          return saveResult.fold(
            // If saving failed, propagate failure
            (failure) => Left(failure),
            // If saving succeeded, log events
            (_) async {
              // Log step completion event
              await _analytics.logEvent(
                'onboarding_step_completed',
                parameters: {
                  'step_id': params.stepId,
                  'step_title': step.title,
                  'is_onboarding_completed': isOnboardingCompleted,
                  'timestamp': DateTime.now().toIso8601String(),
                },
              );

              // Log onboarding completion if all required steps done
              if (isOnboardingCompleted) {
                final duration =
                    params.currentProgress.startedAt != null
                        ? DateTime.now()
                            .difference(
                              params.currentProgress.startedAt!,
                            )
                            .inMinutes
                        : 0;

                await _analytics.logEvent(
                  'onboarding_completed',
                  parameters: {
                    'total_steps_completed':
                        updatedSteps.length,
                    'total_required_steps':
                        requiredSteps.length,
                    'duration_minutes': duration,
                    'timestamp': DateTime.now().toIso8601String(),
                  },
                );
              }

              return Right(updatedProgress);
            },
          );
        },
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Failed to complete step: ${e.toString()}',
        ),
      );
    }
  }
}
