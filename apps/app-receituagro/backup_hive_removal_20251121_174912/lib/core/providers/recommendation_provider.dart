import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/injection_container.dart' as di;
import '../../../core/services/i_recommendation_service.dart';

part 'recommendation_provider.g.dart';

/// Provider for RecommendationService (Dependency Injection via Riverpod)
/// 
/// Returns the singleton instance of IRecommendationService
/// Used by notifiers and other services that need recommendations
@riverpod
IRecommendationService recommendationService(
  RecommendationServiceRef ref,
) {
  return di.sl<IRecommendationService>();
}
