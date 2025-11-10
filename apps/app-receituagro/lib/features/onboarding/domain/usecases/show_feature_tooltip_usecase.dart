import 'package:core/core.dart' hide Column;

import '../repositories/i_onboarding_repository.dart';

/// Parameters for ShowFeatureTooltipUseCase
class ShowFeatureTooltipParams {
  final String tooltipId;
  final Map<String, dynamic>? context;

  const ShowFeatureTooltipParams({
    required this.tooltipId,
    this.context,
  });
}

/// Use case: Mark a feature tooltip as shown
///
/// RN-FT001: Show feature tooltip with tracking:
/// 1. Verify tooltip exists
/// 2. Check if tooltip has already been shown (idempotent)
/// 3. Mark tooltip as shown in persistent storage
/// 4. Log analytics event with context
/// 5. Allow UI to display tooltip overlay
///
/// Parameters: [ShowFeatureTooltipParams] with tooltipId and optional context
/// Returns: void (successful execution)
/// Failures:
/// - [ValidationFailure] if tooltip not found
/// - [CacheFailure] if storage save fails
class ShowFeatureTooltipUseCase
    implements UseCase<void, ShowFeatureTooltipParams> {
  final IOnboardingRepository _repository;
  final IAnalyticsRepository _analytics;

  ShowFeatureTooltipUseCase(
    this._repository,
    this._analytics,
  );

  @override
  Future<Either<Failure, void>> call(
    ShowFeatureTooltipParams params,
  ) async {
    try {
      // Get all tooltips to validate tooltip exists
      final tooltipsResult = _repository.getFeatureTooltips();

      return tooltipsResult.fold(
        // If getting tooltips failed, propagate failure
        (failure) => Left(failure),
        // If tooltips retrieved successfully
        (tooltips) async {
          // VALIDATION 1: Tooltip exists
          final tooltipIndex =
              tooltips.indexWhere((t) => t.id == params.tooltipId);
          if (tooltipIndex == -1) {
            return Left(
              ValidationFailure(
                'Tooltip not found: ${params.tooltipId}',
              ),
            );
          }

          final tooltip = tooltips[tooltipIndex];

          // Check if tooltip already shown (for idempotency)
          final shownResult =
              await _repository.getShownTooltips();

          return shownResult.fold(
            // If getting shown tooltips failed, propagate failure
            (failure) => Left(failure),
            // If retrieved successfully
            (shownTooltips) async {
              // Skip if already shown (idempotent operation)
              if (shownTooltips.contains(params.tooltipId)) {
                return const Right(null);
              }

              // PERSISTENCE: Mark tooltip as shown
              final markResult =
                  await _repository
                      .markTooltipShown(params.tooltipId);

              return markResult.fold(
                // If marking failed, propagate failure
                (failure) => Left(failure),
                // If marking succeeded, log event
                (_) async {
                  await _analytics.logEvent(
                    'feature_tooltip_shown',
                    parameters: {
                      'tooltip_id': params.tooltipId,
                      'tooltip_title': tooltip.title,
                      'target_widget': tooltip.targetWidget,
                      'context': params.context ?? {},
                      'timestamp':
                          DateTime.now().toIso8601String(),
                    },
                  );

                  return const Right(null);
                },
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Failed to show feature tooltip: ${e.toString()}',
        ),
      );
    }
  }
}
