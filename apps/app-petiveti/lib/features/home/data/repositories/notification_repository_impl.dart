import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/notification_summary.dart';
import '../../domain/repositories/notification_repository.dart';

/// **DIP - Dependency Inversion Principle**
/// Implements notification repository interface
/// Single Responsibility: Handle notification retrieval and management
class NotificationRepositoryImpl implements NotificationRepository {
  // In-memory storage for notifications (temporary until backend is ready)
  final List<NotificationSummary> _notifications = [];
  final Set<String> _readNotificationIds = {};

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      // Count notifications not in read set
      final unreadCount = _notifications
          .where(
            (notification) => !_readNotificationIds.contains(notification.id),
          )
          .length;

      return Right(unreadCount);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get unread count: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationSummary>>> getRecentNotifications({
    int limit = 10,
  }) async {
    try {
      // Sort by timestamp descending and take limit
      final recent = List<NotificationSummary>.from(_notifications)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final limitedList = recent.take(limit).toList();

      return Right(limitedList);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUrgentAlerts() async {
    try {
      // Check for urgent unread notifications
      final hasUrgent = _notifications.any(
        (notification) =>
            notification.isUrgent &&
            !_readNotificationIds.contains(notification.id),
      );

      return Right(hasUrgent);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to check urgent alerts: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      // Add all notification IDs to read set
      for (final notification in _notifications) {
        _readNotificationIds.add(notification.id);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to mark as read: $e'));
    }
  }

  // ========================================================================
  // HELPER METHODS (for internal use and testing)
  // ========================================================================

  /// Add a notification (internal use - will be replaced by backend push)
  void addNotification(NotificationSummary notification) {
    _notifications.add(notification);
  }

  /// Clear all notifications (testing/reset)
  void clearAll() {
    _notifications.clear();
    _readNotificationIds.clear();
  }

  /// Mark specific notification as read
  void markAsRead(String notificationId) {
    _readNotificationIds.add(notificationId);
  }
}
