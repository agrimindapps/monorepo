import 'package:core/core.dart' hide Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_providers.g.dart';

@riverpod
IAnalyticsRepository analyticsRepository(Ref ref) {
  return FirebaseAnalyticsService();
}

@riverpod
ICrashlyticsRepository crashlyticsRepository(Ref ref) {
  return FirebaseCrashlyticsService();
}

@riverpod
IPerformanceRepository performanceRepository(Ref ref) {
  return PerformanceService();
}
