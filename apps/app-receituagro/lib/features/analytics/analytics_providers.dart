import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_providers.g.dart';

@riverpod
IAnalyticsRepository analyticsRepository(AnalyticsRepositoryRef ref) {
  return FirebaseAnalyticsService();
}

@riverpod
ICrashlyticsRepository crashlyticsRepository(CrashlyticsRepositoryRef ref) {
  return FirebaseCrashlyticsService();
}

@riverpod
IPerformanceRepository performanceRepository(PerformanceRepositoryRef ref) {
  return PerformanceService();
}
