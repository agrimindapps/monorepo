import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/home_aggregation_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/home_aggregation_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';

// Export state classes for use in other modules
export '../providers/home_notifiers.dart' show HomeStatusState, HomeNotificationsState, HomeStatsState;

part 'home_providers.g.dart';

// ============================================================================
// REPOSITORIES
// ============================================================================

@riverpod
HomeAggregationRepository homeAggregationRepository(
  HomeAggregationRepositoryRef ref,
) {
  return HomeAggregationRepositoryImpl();
}

@riverpod
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  return NotificationRepositoryImpl();
}

@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  return DashboardRepositoryImpl();
}
