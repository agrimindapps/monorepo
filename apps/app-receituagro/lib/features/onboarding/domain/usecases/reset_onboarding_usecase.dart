import 'package:core/core.dart' hide Column;

import '../repositories/i_onboarding_repository.dart';

/// Use case: Reset onboarding progress (Testing/Debug only)
///
/// RN-ON005: Reset onboarding state:
/// 1. Clear all progress data
/// 2. Clear all shown tooltips
/// 3. Log analytics event
/// 4. Allow user to restart onboarding flow
///
/// WARNING: This is a destructive operation. Use only in:
/// - Testing scenarios
/// - Debug/development
/// - User-initiated reset (settings)
///
/// Parameters: No parameters (uses NoParams pattern)
/// Returns: void (successful execution)
/// Failures: [CacheFailure] if storage operations fail
class ResetOnboardingUseCase implements UseCase<void, NoParams> {
  final IOnboardingRepository _repository;
  final IAnalyticsRepository _analytics;

  ResetOnboardingUseCase(
    this._repository,
    this._analytics,
  );

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      // PERSISTENCE: Clear progress
      final progressResetResult =
          await _repository.resetProgress();

      return progressResetResult.fold(
        // If clearing progress failed, propagate failure
        (failure) => Left(failure),
        // If progress cleared successfully
        (_) async {
          // PERSISTENCE: Clear tooltips
          final tooltipsResetResult =
              await _repository.resetTooltips();

          return tooltipsResetResult.fold(
            // If clearing tooltips failed, propagate failure
            (failure) => Left(failure),
            // If both cleared successfully, log event
            (_) async {
              await _analytics.logEvent(
                'onboarding_reset',
                parameters: {
                  'timestamp': DateTime.now().toIso8601String(),
                },
              );

              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Failed to reset onboarding: ${e.toString()}',
        ),
      );
    }
  }
}
