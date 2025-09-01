import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/promo_repository.dart';

class TrackAnalyticsParams {
  final String event;
  final Map<String, dynamic> parameters;

  TrackAnalyticsParams({
    required this.event,
    required this.parameters,
  });
}

class TrackAnalytics implements UseCase<void, TrackAnalyticsParams> {
  final PromoRepository repository;

  TrackAnalytics(this.repository);

  @override
  Future<Either<Failure, void>> call(TrackAnalyticsParams params) async {
    return await repository.trackEvent(params.event, params.parameters);
  }
}