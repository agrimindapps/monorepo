import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/promo_repository.dart';
import '../services/promo_validation_service.dart';

class TrackAnalyticsParams {
  final String event;
  final Map<String, dynamic> parameters;

  TrackAnalyticsParams({
    required this.event,
    required this.parameters,
  });
}

/// Use case for tracking analytics events
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles analytics tracking flow
/// - **Dependency Inversion**: Depends on abstractions (repository, validation service)
///
/// **Dependencies:**
/// - PromoRepository: For event tracking
/// - PromoValidationService: For event name validation
@lazySingleton
class TrackAnalytics implements UseCase<void, TrackAnalyticsParams> {
  final PromoRepository _repository;
  final PromoValidationService _validationService;

  TrackAnalytics(this._repository, this._validationService);

  @override
  Future<Either<Failure, void>> call(TrackAnalyticsParams params) async {
    // Validate event name
    final validationResult = _validationService.validateEventName(params.event);

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw StateError('Validation should not return Right'),
      );
    }

    // Track event
    return await _repository.trackEvent(params.event, params.parameters);
  }
}
