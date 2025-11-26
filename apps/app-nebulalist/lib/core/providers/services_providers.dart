import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../di/injection.dart' as di;
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import '../services/share_service.dart';

part 'services_providers.g.dart';

/// Provider for app-specific AnalyticsService
/// Uses GetIt for dependency injection
/// Note: Different from core's analyticsServiceProvider
@riverpod
AnalyticsService appAnalyticsService(Ref ref) {
  return di.getIt<AnalyticsService>();
}

/// Provider for ShareService
/// Uses GetIt for dependency injection
@riverpod
ShareService shareService(Ref ref) {
  return di.getIt<ShareService>();
}

/// Provider for app-specific NotificationService
/// Uses GetIt for dependency injection
@riverpod
NotificationService appNotificationService(Ref ref) {
  return di.getIt<NotificationService>();
}
