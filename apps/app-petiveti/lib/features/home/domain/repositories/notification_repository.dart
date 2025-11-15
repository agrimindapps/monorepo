import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/notification_summary.dart';

/// **ISP - Interface Segregation Principle**
/// Segregated repository for notifications
/// Single Responsibility: Handle notification retrieval and management
abstract class NotificationRepository {
  /// Get unread notification count
  Future<Either<Failure, int>> getUnreadCount();

  /// Get recent notifications summary
  Future<Either<Failure, List<NotificationSummary>>> getRecentNotifications({
    int limit = 10,
  });

  /// Check if there are urgent alerts
  Future<Either<Failure, bool>> hasUrgentAlerts();

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();
}
