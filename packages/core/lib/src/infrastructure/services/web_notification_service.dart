import 'package:flutter/foundation.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';

/// Implementação mock do serviço de notificações para web
class WebNotificationService implements INotificationRepository {
  static final WebNotificationService _instance =
      WebNotificationService._internal();
  factory WebNotificationService() => _instance;
  WebNotificationService._internal();

  bool _isInitialized = false;

  @override
  Future<bool> initialize({
    List<NotificationChannelEntity>? defaultChannels,
  }) async {
    if (_isInitialized) return true;

    if (kDebugMode) {
      debugPrint(
        '🌐 WebNotificationService: Mock initialization for web platform',
      );
    }

    _isInitialized = true;
    return true;
  }

  @override
  Future<NotificationPermissionEntity> getPermissionStatus() async {
    return const NotificationPermissionEntity(
      isGranted: false,
      canShowAlerts: false,
      canShowBadges: false,
      canPlaySounds: false,
      canScheduleExactAlarms: false,
      shouldShowRationale: false,
      isPermanentlyDenied: false,
    );
  }

  @override
  Future<NotificationPermissionEntity> requestPermission() async {
    if (kDebugMode) {
      debugPrint(
        '🌐 WebNotificationService: Mock permission request (always denied for web)',
      );
    }

    return const NotificationPermissionEntity(
      isGranted: false,
      canShowAlerts: false,
      canShowBadges: false,
      canPlaySounds: false,
      canScheduleExactAlarms: false,
      shouldShowRationale: false,
      isPermanentlyDenied: false,
    );
  }

  @override
  Future<bool> openNotificationSettings() async {
    if (kDebugMode) {
      debugPrint(
        '🌐 WebNotificationService: Cannot open notification settings on web',
      );
    }
    return false;
  }

  @override
  Future<bool> createNotificationChannel(
    NotificationChannelEntity channel,
  ) async {
    if (kDebugMode) {
      debugPrint(
        '🌐 WebNotificationService: Mock channel creation: ${channel.id}',
      );
    }
    return true;
  }

  @override
  Future<bool> deleteNotificationChannel(String channelId) async {
    if (kDebugMode) {
      debugPrint(
        '🌐 WebNotificationService: Mock channel deletion: $channelId',
      );
    }
    return true;
  }

  @override
  Future<List<NotificationChannelEntity>> getNotificationChannels() async {
    return <NotificationChannelEntity>[];
  }

  @override
  Future<bool> showNotification(NotificationEntity notification) async {
    if (kDebugMode) {
      debugPrint(
        '🌐 WebNotificationService: Mock notification shown: ${notification.title}',
      );
    }
    return true;
  }

  @override
  Future<bool> scheduleNotification(NotificationEntity notification) async {
    if (kDebugMode) {
      debugPrint(
        '🌐 WebNotificationService: Mock notification scheduled: ${notification.title}',
      );
    }
    return true;
  }

  @override
  Future<bool> schedulePeriodicNotification(
    NotificationEntity notification,
    Duration repeatInterval,
  ) async {
    if (kDebugMode) {
      debugPrint(
        '🌐 WebNotificationService: Mock periodic notification scheduled: ${notification.title}',
      );
    }
    return true;
  }

  @override
  Future<bool> cancelNotification(int notificationId) async {
    if (kDebugMode) {
      debugPrint(
        '🌐 WebNotificationService: Mock notification cancelled: $notificationId',
      );
    }
    return true;
  }

  @override
  Future<bool> cancelAllNotifications() async {
    if (kDebugMode) {
      debugPrint('🌐 WebNotificationService: Mock all notifications cancelled');
    }
    return true;
  }

  @override
  Future<List<PendingNotificationEntity>> getPendingNotifications() async {
    return <PendingNotificationEntity>[];
  }

  @override
  Future<List<PendingNotificationEntity>> getActiveNotifications() async {
    return <PendingNotificationEntity>[];
  }

  @override
  void setNotificationTapCallback(NotificationTapCallback callback) {}

  @override
  void setNotificationActionCallback(NotificationActionCallback callback) {}

  @override
  Future<bool> isNotificationScheduled(int notificationId) async {
    return false;
  }

  @override
  int generateNotificationId(String identifier) {
    return identifier.hashCode;
  }

  @override
  int dateTimeToTimestamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  @override
  DateTime timestampToDateTime(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  @override
  Future<bool> canScheduleExactNotifications() async {
    return false;
  }

  @override
  Future<bool> requestExactNotificationPermission() async {
    return false;
  }
}
